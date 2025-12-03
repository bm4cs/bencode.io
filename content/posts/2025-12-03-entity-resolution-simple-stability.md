---
layout: post
draft: true
title: "Simple Entity Resolution Stability"
slug: "entity"
date: "2025-12-03 18:58:00+1100"
lastmod: "2025-12-03 18:58:00+1100"
comments: false
categories:
  - entityresolution
  - data
  - dev
---

- [The Concept](#the-concept)
- [An Implementation](#an-implementation)
  - [1. Core types \& interfaces](#1-core-types--interfaces)
  - [2. Union–Find for Stable IDs](#2-unionfind-for-stable-ids)
  - [3. The Stable External ID Manager](#3-the-stable-external-id-manager)
  - [4. In‑memory store (for testing / to see the shape)](#4-inmemory-store-for-testing--to-see-the-shape)
  - [5. Wiring it up with your existing Senzing event processor](#5-wiring-it-up-with-your-existing-senzing-event-processor)
- [Remarks](#remarks)
- [DRAFT](#draft)
- [1. What union‑find was actually doing](#1-what-unionfind-was-actually-doing)
- [2. DB‑backed aliasing (what you actually want on Kubernetes)](#2-dbbacked-aliasing-what-you-actually-want-on-kubernetes)
  - [Table: `StableEntity`](#table-stableentity)
  - [Table: `RecordStable`](#table-recordstable)
  - [Table: `EntityStable` (optional)](#table-entitystable-optional)
- [3. C# without any in‑memory `StableIdUnionFind`](#3-c-without-any-inmemory-stableidunionfind)
  - [3.1 Core DTO + repo interfaces](#31-core-dto--repo-interfaces)
  - [3.2 Stable ID manager using only the DB](#32-stable-id-manager-using-only-the-db)
  - [How this fits into your Senzing flow](#how-this-fits-into-your-senzing-flow)
- [4. So… do you _need_ union‑find?](#4-so-do-you-need-unionfind)

## The Concept

For the "stable external ID" illusion, its not necessary to classify explicit merge/split scenarios.

A cleaner pattern for your public API is:

- Introduce your own StableEntityId (GUID, long, whatever).
- Main a DB table called `StableEntity`: `StableId -> Current Senzing entity IDs attached to this stable ID`
- When you observe a new Senzing entity (from GetEntity during AFFECTED_ENTITIES processing):

  - Look at its records; find any existing StableIds those records are already associated with.
  - If none → create a new StableId.
  - If one → attach this Senzing entity to that StableId.
  - If many → you've just discovered a merge at the stable layer → unify those StableIds (Union-Find style).

Then your external behaviour becomes:

- Client calls your API with StableId.
- Internally, you resolve that to 0, 1 or N live Senzing entity IDs:
  - 0 → the entity is gone (all records deleted).
  - 1 → simple redirect to the survivor.
  - N>1 → "this logical person has split into multiple Senzing entities; here's the list".

In this design, you don't really care if the underlying engine event on any given day was a "merge" or a "split"; you care about what stable identity the records belong to now.

## An Implementation

Nice, this is the fun part 😄
Here’s a concrete C# implementation of the **“stable external ID” layer** on top of Senzing, using the “don’t care about merges/splits, just unify stable IDs when records meet” approach.

The idea:

- You **never expose Senzing entity IDs** to your consumers.
- You expose your own **StableEntityId** (here: `Guid`).
- For each _Senzing_ entity (with its records), you:

  - Look up which stable IDs those records are already tied to.
  - If none → create a new stable ID.
  - If one → reuse that stable ID.
  - If many → **merge those stable IDs** (union‑find style) and use the canonical one.

- You store:

  - Record → StableId mapping.
  - Senzing EntityId → StableId mapping.
  - StableId alias relationships (in union‑find).

Below is one self‑contained example. You can copy/paste and then swap out the in‑memory store for your own DAL implementation.

---

### 1. Core types & interfaces

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace YourNamespace.StableIds
{
    /// <summary>
    /// Identifies a Senzing record uniquely: DATA_SOURCE + RECORD_ID.
    /// </summary>
    public readonly record struct RecordKey(string DataSource, string RecordId);

    /// <summary>
    /// Abstracts your persistence for stable-entity mappings.
    /// You will implement this using your own DB / data-access layer.
    /// </summary>
    public interface IStableIdStore
    {
        // --- Record -> StableId ---

        /// <summary>
        /// Returns the stable ID currently associated with this record, or null if none.
        /// </summary>
        Guid? GetStableIdForRecord(RecordKey record);

        /// <summary>
        /// Associate the given record with the given stable ID (upsert).
        /// </summary>
        void SetStableIdForRecord(RecordKey record, Guid stableId);

        // --- Senzing EntityId -> StableId ---

        /// <summary>
        /// Returns the stable ID currently associated with this Senzing entity, or null if none.
        /// </summary>
        Guid? GetStableIdForEntity(long entityId);

        /// <summary>
        /// Associate the given Senzing entity with the given stable ID (upsert).
        /// </summary>
        void SetStableIdForEntity(long entityId, Guid stableId);

        /// <summary>
        /// Remove the mapping for an entity that no longer exists (optional).
        /// </summary>
        void RemoveEntity(long entityId);

        /// <summary>
        /// Get all Senzing entity IDs that currently map to the given stable ID.
        /// This is how you answer "which entities represent this stable ID right now?"
        /// </summary>
        IReadOnlyCollection<long> GetEntitiesForStableId(Guid stableId);

        // --- StableId merges ---

        /// <summary>
        /// When two stable IDs are unified (fromStableId merged into toStableId),
        /// update all internal references (records, entities, etc.).
        /// After this call, fromStableId should no longer appear as the
        /// canonical stable ID in your DB.
        /// </summary>
        void MergeStableIds(Guid fromStableId, Guid toStableId);
    }
}
```

### 2. Union–Find for Stable IDs

```csharp
using System;
using System.Collections.Generic;

namespace YourNamespace.StableIds
{
    /// <summary>
    /// Simple union-find (disjoint-set) structure for Stable IDs.
    ///
    /// NOTE: In a real system you'll probably want to persist this alias mapping
    /// so that if your process restarts, old stable IDs still resolve to the
    /// same canonical ID. For brevity, this is in-memory only.
    /// </summary>
    public sealed class StableIdUnionFind
    {
        private readonly Dictionary<Guid, Guid> _parent = new();

        /// <summary>
        /// Find the canonical representative for this stable ID.
        /// Path compression is applied.
        /// </summary>
        public Guid Find(Guid id)
        {
            if (!_parent.TryGetValue(id, out Guid parent))
            {
                _parent[id] = id;
                return id;
            }

            if (parent == id) return id;

            Guid root = Find(parent);
            _parent[id] = root;
            return root;
        }

        /// <summary>
        /// Union the sets containing a and b, and return the canonical representative.
        /// The policy here is: "attach b's root under a's root".
        /// You can customize this (oldest wins, smallest GUID wins, etc.).
        /// </summary>
        public Guid Union(Guid a, Guid b)
        {
            Guid rootA = Find(a);
            Guid rootB = Find(b);

            if (rootA == rootB) return rootA;

            // Attach B under A.
            _parent[rootB] = rootA;
            return rootA;
        }
    }
}
```

### 3. The Stable External ID Manager

This is the key bit: given a Senzing entity and its records, it figures out which stable ID to use and keeps everything in sync.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace YourNamespace.StableIds
{
    /// <summary>
    /// Maintains a layer of "stable external IDs" on top of Senzing entities.
    ///
    /// - Consumers only see StableIds (Guid).
    /// - Internally, we keep track of which Senzing entity IDs and records belong to each StableId.
    /// - We don't need explicit "split" / "merge" labels from Senzing:
    ///     * When records from different stable IDs appear together in one entity,
    ///       we merge those StableIds (union-find style).
    /// </summary>
    public sealed class StableIdManager
    {
        private readonly IStableIdStore _store;
        private readonly StableIdUnionFind _unionFind;

        public StableIdManager(IStableIdStore store)
        {
            _store = store ?? throw new ArgumentNullException(nameof(store));
            _unionFind = new StableIdUnionFind();
        }

        /// <summary>
        /// Given a Senzing entity ID and the list of records that Senzing says belong
        /// to that entity *right now*, compute / update the StableId for this entity
        /// and its records.
        ///
        /// This method is the core of the "stable external ID" illusion:
        ///  - It looks up any StableIds already attached to the records
        ///  - If none -> new StableId
        ///  - If one  -> reuse it
        ///  - If many -> unify those StableIds into one canonical StableId
        ///
        /// Returns the canonical StableId for this entity after the update.
        /// </summary>
        public Guid UpdateStableIdForEntity(long entityId, IReadOnlyCollection<RecordKey> records)
        {
            if (records == null) throw new ArgumentNullException(nameof(records));

            // 1. Look at each record and find any existing stable IDs that those records
            //    are already associated with. Use the union-find to collapse aliases
            //    to canonical IDs.
            var contributingStableIds = new HashSet<Guid>();

            foreach (var record in records)
            {
                Guid? stored = _store.GetStableIdForRecord(record);
                if (stored.HasValue)
                {
                    Guid canonical = _unionFind.Find(stored.Value);
                    contributingStableIds.Add(canonical);
                }
            }

            // 2. Decide which StableId to use for this entity.
            Guid stableId;

            if (contributingStableIds.Count == 0)
            {
                // No record was ever seen before -> new logical entity.
                stableId = Guid.NewGuid();
                _unionFind.Find(stableId); // initialize
            }
            else if (contributingStableIds.Count == 1)
            {
                // All records that had a stable ID agree on a single one.
                stableId = contributingStableIds.First();
            }
            else
            {
                // Records from multiple stable IDs now coexist in the same Senzing entity.
                // From the "real world" perspective, we've just discovered that these
                // StableIds actually refer to the same person / organization.
                //
                // We unify them into a single canonical StableId via union-find.
                var enumerator = contributingStableIds.GetEnumerator();
                enumerator.MoveNext();
                stableId = enumerator.Current; // start with the first as survivor

                while (enumerator.MoveNext())
                {
                    Guid other = enumerator.Current;

                    // union-find merges sets in memory
                    Guid newRoot = _unionFind.Union(stableId, other);
                    Guid canonical = newRoot;

                    if (canonical != stableId)
                    {
                        // If the new root is not the one we started with, flip.
                        stableId = canonical;
                    }

                    // Ask the store to update all references from 'other' -> 'canonical'.
                    _store.MergeStableIds(other, canonical);
                }
            }

            // 3. At this point, 'stableId' is the canonical StableId for this entity.
            //    Ensure all records of this entity are associated with it.
            foreach (var record in records)
            {
                _store.SetStableIdForRecord(record, stableId);
            }

            // 4. Also maintain the mapping from Senzing entity ID -> StableId.
            _store.SetStableIdForEntity(entityId, stableId);

            return stableId;
        }

        /// <summary>
        /// Resolve the canonical StableId for a given Senzing entity ID.
        /// Returns null if we have never associated this entity with any StableId.
        /// </summary>
        public Guid? ResolveStableIdForEntity(long entityId)
        {
            Guid? stored = _store.GetStableIdForEntity(entityId);
            if (!stored.HasValue) return null;

            return _unionFind.Find(stored.Value);
        }

        /// <summary>
        /// Resolve the canonical StableId for a given record.
        /// Returns null if this record has never been seen before.
        /// </summary>
        public Guid? ResolveStableIdForRecord(RecordKey record)
        {
            Guid? stored = _store.GetStableIdForRecord(record);
            if (!stored.HasValue) return null;

            return _unionFind.Find(stored.Value);
        }

        /// <summary>
        /// Given an external StableId (which might be an old alias),
        /// resolve it to the canonical StableId and return all current Senzing
        /// entity IDs that belong to that logical entity.
        ///
        /// This is your "public" lookup: clients call you with StableId,
        /// you map it to the set of current Senzing entities.
        /// </summary>
        public IReadOnlyCollection<long> GetCurrentEntitiesForStableId(Guid externalStableId)
        {
            Guid canonical = _unionFind.Find(externalStableId);
            return _store.GetEntitiesForStableId(canonical);
        }

        /// <summary>
        /// Optional: use when you detect that a Senzing entity ID no longer exists
        /// (e.g., from GetEntity throwing SzNotFoundException).
        /// You usually don't need to touch the StableId here; it remains associated
        /// with whatever records survived in other entities.
        /// </summary>
        public void HandleEntityDeleted(long entityId)
        {
            _store.RemoveEntity(entityId);
            // No change to StableId itself — it's tied to records, not this entityId.
        }
    }
}
```

### 4. In‑memory store (for testing / to see the shape)

You said you already have a DAL, so this is just to show what `IStableIdStore` might look like in practice.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace YourNamespace.StableIds
{
    /// <summary>
    /// Simple in-memory implementation of IStableIdStore.
    /// Replace this with your DB-backed version.
    /// </summary>
    public sealed class InMemoryStableIdStore : IStableIdStore
    {
        // Record -> StableId
        private readonly Dictionary<RecordKey, Guid> _recordToStable = new();

        // Senzing EntityId -> StableId
        private readonly Dictionary<long, Guid> _entityToStable = new();

        public Guid? GetStableIdForRecord(RecordKey record)
        {
            return _recordToStable.TryGetValue(record, out Guid stableId)
                ? stableId
                : (Guid?)null;
        }

        public void SetStableIdForRecord(RecordKey record, Guid stableId)
        {
            _recordToStable[record] = stableId;
        }

        public Guid? GetStableIdForEntity(long entityId)
        {
            return _entityToStable.TryGetValue(entityId, out Guid stableId)
                ? stableId
                : (Guid?)null;
        }

        public void SetStableIdForEntity(long entityId, Guid stableId)
        {
            _entityToStable[entityId] = stableId;
        }

        public void RemoveEntity(long entityId)
        {
            _entityToStable.Remove(entityId);
        }

        public IReadOnlyCollection<long> GetEntitiesForStableId(Guid stableId)
        {
            // In a real DB, you'd index on StableId -> EntityId.
            // This LINQ scan is fine for an in-memory demo.
            return _entityToStable
                .Where(kvp => kvp.Value == stableId)
                .Select(kvp => kvp.Key)
                .ToList();
        }

        public void MergeStableIds(Guid fromStableId, Guid toStableId)
        {
            if (fromStableId == toStableId) return;

            // Update entity mappings: any entity pointing at fromStableId -> toStableId.
            var entitiesToUpdate = _entityToStable
                .Where(kvp => kvp.Value == fromStableId)
                .Select(kvp => kvp.Key)
                .ToList();

            foreach (long entityId in entitiesToUpdate)
            {
                _entityToStable[entityId] = toStableId;
            }

            // Update record mappings similarly.
            var recordsToUpdate = _recordToStable
                .Where(kvp => kvp.Value == fromStableId)
                .Select(kvp => kvp.Key)
                .ToList();

            foreach (RecordKey record in recordsToUpdate)
            {
                _recordToStable[record] = toStableId;
            }

            // In a real store, you might also:
            //  - keep an audit log ("from" merged into "to"),
            //  - mark "from" as deprecated but still resolvable, etc.
        }
    }
}
```

### 5. Wiring it up with your existing Senzing event processor

Assuming you’re already using the `SenzingEventProcessor` from the previous answer (or similar) that gives you post‑state per entity:

```csharp
// Somewhere in your composition root / DI setup:
var stableStore   = new InMemoryStableIdStore();            // or your DB implementation
var stableManager = new StableIdManager(stableStore);

// After you process an AddRecord/DeleteRecord/ProcessRedoRecord and have EntityDelta(s):
IReadOnlyList<EntityDelta> deltas = eventProcessor.ProcessWithInfoJson(infoJson);

// For every entity that exists after this event, update the stable ID layer.
foreach (var delta in deltas)
{
    if (delta.PostRecords.Count == 0)
    {
        // Entity no longer exists -> optional housekeeping.
        stableManager.HandleEntityDeleted(delta.EntityId);
        continue;
    }

    stableManager.UpdateStableIdForEntity(delta.EntityId, delta.PostRecords);
}

// Later, when your API is called with a stable ID:
public IReadOnlyCollection<long> GetCurrentEntities(Guid stableId)
{
    return stableManager.GetCurrentEntitiesForStableId(stableId);
}
```

## Remarks

- You never look at `delta.ChangeKind` (“merge/split/etc”) in the stable layer.
- You just repeatedly feed it **current membership** of each Senzing entity.
- The stable layer quietly maintains:

  - A **canonical StableId** per real‑world entity.
  - The mapping from StableId → current set of Senzing entities.
  - Alias relationships when separate StableIds later turn out to be the same thing.





## DRAFT

Short answer: you’re right to be suspicious of in‑memory `UnionFind` in a Kubernetes world 😊

- The _idea_ of “union‑find” **is** important (it’s just “these IDs are now the same thing → pick a canonical one”).
- The **in‑memory data structure** I showed is _not_ required, and in a scaled / multi‑pod setup it **must** be replaced by **database‑backed aliasing** anyway.

So let me:

1. Explain what role union‑find was really playing.
2. Show how you can replace it with **simple DB‑backed redirection** (exactly your “redirect merged deaths to the survivor” idea).
3. Give you C# that implements the stable‑ID approach _without_ any in‑memory union‑find.

---

## 1. What union‑find was actually doing

Conceptually, union‑find was only doing two things:

1. **Alias resolution**

   - Given a `StableId` that may have been merged, figure out the **canonical** stable ID for that logical entity.
   - E.g. if `S2` was merged into `S1`, then `Find(S2) == S1`.

2. **Unifying multiple IDs**

   - When Senzing puts records from `S1` and `S2` into the same entity, we say

     > “Okay, S1 and S2 are actually the same real person -> from now on treat them as one.”

   - That’s just:

     ```text
     union(S1, S2)  =>  “S1 is the survivor; S2 should redirect to S1”
     ```

That’s exactly the “redirect merged deaths to the survivor” you described.
Union‑find is just a nice name / pattern for **managing those redirects**, especially when merges can chain:

```text
S2 → S1
S3 → S2
S4 → S3

=> Everybody should ultimately resolve to S1.
```

You _don’t_ need a fancy in‑memory structure to do that; you can do it with a very plain DB schema.

---

## 2. DB‑backed aliasing (what you actually want on Kubernetes)

In a multi‑pod environment:

- The **DB is your source of truth** about which stable IDs are canonical.
- Each pod just:

  - Reads from the DB to resolve canonical stable IDs.
  - Writes merge decisions into the DB in a transaction.

Pattern:

### Table: `StableEntity`

```text
StableEntity
------------
StableId        (PK, Guid)
CanonicalId     (nullable Guid, FK -> StableEntity.StableId)
                - NULL or equal to StableId => this row is canonical
                - Otherwise => this StableId is an alias of CanonicalId
CreatedAt, etc. (optional metadata)
```

### Table: `RecordStable`

```text
RecordStable
------------
DataSource
RecordId         (PK with DataSource)
StableId         (FK -> StableEntity.StableId)
```

### Table: `EntityStable` (optional)

```text
EntityStable
------------
EntityId        (PK)
StableId        (FK -> StableEntity.StableId)
```

Then:

- **Resolving a stable ID** is just: chase `CanonicalId` until you hit a row where `CanonicalId` is `NULL` or equals `StableId`.
- **Merging stable IDs** is: pick a winner, update losers’ `CanonicalId` to the winner, and optionally re‑point their rows.

No in‑memory union‑find, no in‑pod state to sync. Just DB.

---

## 3. C# without any in‑memory `StableIdUnionFind`

Below is a simplified version of the previous `StableIdManager`, rewritten to:

- Use only DB‑backed aliasing.
- Treat “merge” as “set loser.CanonicalId = winner.StableId”.

### 3.1 Core DTO + repo interfaces

```csharp
using System;
using System.Collections.Generic;

namespace YourNamespace.StableIds
{
    public readonly record struct RecordKey(string DataSource, string RecordId);

    /// <summary>
    /// CRUD around StableIds and their aliasing (canonical) relationships.
    /// This will be implemented using your DB.
    /// </summary>
    public interface IStableIdRepository
    {
        // --- StableId rows ---

        /// <summary>
        /// Create a new canonical StableId row in the DB.
        /// (Typically just inserts StableId with CanonicalId = itself or NULL.)
        /// </summary>
        void CreateStable(Guid stableId);

        /// <summary>
        /// Returns the canonical ID for a given stableId if it's an alias;
        /// returns null if either:
        ///   - the stableId is canonical (CanonicalId is NULL or equals StableId)
        ///   - the row doesn't exist.
        ///
        /// In practice you might return an object with both StableId + CanonicalId,
        /// but this keeps it simple.
        /// </summary>
        Guid? GetCanonicalId(Guid stableId);

        /// <summary>
        /// Set stableId's CanonicalId to canonicalId (meaning:
        /// "stableId is now an alias of canonicalId").
        /// </summary>
        void SetCanonicalId(Guid stableId, Guid canonicalId);

        // --- Record -> StableId ---

        Guid? GetStableIdForRecord(RecordKey record);
        void SetStableIdForRecord(RecordKey record, Guid stableId);

        // --- StableId -> EntityIds (current Senzing entities) ---

        IReadOnlyCollection<long> GetEntityIdsForStable(Guid canonicalStableId);
        void SetEntityIdsForStable(Guid canonicalStableId, IReadOnlyCollection<long> entityIds);
    }
}
```

### 3.2 Stable ID manager using only the DB

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace YourNamespace.StableIds
{
    /// <summary>
    /// Stable external ID layer on top of Senzing, without any in-memory union-find.
    /// All aliasing is persisted in the database via IStableIdRepository.
    /// </summary>
    public sealed class StableIdManager
    {
        private readonly IStableIdRepository _repo;

        public StableIdManager(IStableIdRepository repo)
        {
            _repo = repo ?? throw new ArgumentNullException(nameof(repo));
        }

        /// <summary>
        /// Resolve the canonical StableId given any (possibly old/alias) StableId.
        /// This just chases CanonicalId pointers in the DB until we reach a root.
        /// </summary>
        public Guid ResolveCanonicalStableId(Guid stableId)
        {
            var seen = new HashSet<Guid>();

            while (true)
            {
                if (!seen.Add(stableId))
                {
                    // Safety against bugs / cycles in the DB.
                    throw new InvalidOperationException($"Cycle detected in StableId aliases at {stableId}");
                }

                Guid? canonical = _repo.GetCanonicalId(stableId);

                // If null or canonical == stableId => treat as root.
                if (!canonical.HasValue || canonical.Value == stableId)
                    return stableId;

                stableId = canonical.Value;
            }
        }

        /// <summary>
        /// Core operation: given the current records for a Senzing entity,
        /// find / create the StableId that should represent that entity.
        ///
        /// This is the "you don't need explicit merge/split labels" bit:
        ///  - Collect StableIds from all records
        ///  - Map them to their canonical forms
        ///  - If 0   => new StableId
        ///  - If 1   => reuse
        ///  - If &gt;1 => merge them into one survivor
        /// Then:
        ///  - Assign all records to the survivor StableId
        ///  - Update StableId -> EntityId mapping
        /// </summary>
        public Guid UpsertStableIdForEntity(long entityId, IReadOnlyCollection<RecordKey> records)
        {
            if (records == null) throw new ArgumentNullException(nameof(records));

            // 1. Discover which stable IDs these records are already tied to.
            var existingCanonicalStableIds = new HashSet<Guid>();

            foreach (var record in records)
            {
                Guid? sid = _repo.GetStableIdForRecord(record);
                if (sid.HasValue)
                {
                    var canonical = ResolveCanonicalStableId(sid.Value);
                    existingCanonicalStableIds.Add(canonical);
                }
            }

            Guid survivor;

            if (existingCanonicalStableIds.Count == 0)
            {
                // New logical entity.
                survivor = Guid.NewGuid();
                _repo.CreateStable(survivor);
            }
            else if (existingCanonicalStableIds.Count == 1)
            {
                // All records agree on a single canonical StableId.
                survivor = existingCanonicalStableIds.First();
            }
            else
            {
                // Multiple canonical StableIds now appear in the same Senzing entity.
                // => We've just discovered a "merge" at the logical level:
                //    all of those stable IDs actually refer to the same real-world entity.
                // Pick a survivor and redirect others to it.
                survivor = PickSurvivor(existingCanonicalStableIds);

                foreach (var loser in existingCanonicalStableIds)
                {
                    if (loser == survivor) continue;

                    // Set loser.CanonicalId = survivor in DB.
                    _repo.SetCanonicalId(loser, survivor);

                    // Optional (heavier, but keeps chains short):
                    //  - Rewrite all Record / Entity rows pointing at 'loser' to 'survivor'.
                    // You can choose to do that in the repo implementation or via a background job.
                }
            }

            // 2. Ensure all records for this entity point at the survivor StableId.
            foreach (var record in records)
            {
                _repo.SetStableIdForRecord(record, survivor);
            }

            // 3. Rebuild StableId -> EntityIds mapping for the survivor.
            //    In a real system you'd probably call this in your Senzing event handler,
            //    once you know the post-state entity IDs per stable ID.
            var entitiesForSurvivor = new HashSet<long>(
                _repo.GetEntityIdsForStable(survivor)
            )
            {
                entityId
            };

            _repo.SetEntityIdsForStable(survivor, entitiesForSurvivor.ToList());

            return survivor;
        }

        /// <summary>
        /// Helper to choose which StableId should be the survivor when merging.
        /// You can pick:
        ///  - smallest GUID,
        ///  - oldest row (needs CreatedAt),
        ///  - or any custom business rule.
        /// </summary>
        private static Guid PickSurvivor(HashSet<Guid> candidates)
        {
            // simplest: lowest GUID, deterministic and stable.
            Guid survivor = default;
            foreach (Guid id in candidates)
            {
                if (survivor == Guid.Empty || id.CompareTo(survivor) < 0)
                    survivor = id;
            }
            return survivor;
        }

        /// <summary>
        /// Used by your external API:
        /// given a stable ID from a client (which may be old),
        /// return the current canonical StableId and the Senzing entity IDs that represent it.
        /// </summary>
        public (Guid canonicalStableId, IReadOnlyCollection<long> entityIds) ResolveForClient(Guid externalStableId)
        {
            var canonical = ResolveCanonicalStableId(externalStableId);
            var entityIds = _repo.GetEntityIdsForStable(canonical);
            return (canonical, entityIds);
        }
    }
}
```

### How this fits into your Senzing flow

In your Senzing event handler (the bit that already knows “for entity E, these are its records”):

```csharp
// 'records' is the list of (DATA_SOURCE, RECORD_ID) from GetEntity.
Guid stableId = stableIdManager.UpsertStableIdForEntity(entityId, records);
```

In your API:

```csharp
public CustomerDto GetCustomer(string stableIdString)
{
    Guid externalStableId = Guid.Parse(stableIdString);

    var (canonical, entityIds) = _stableIdManager.ResolveForClient(externalStableId);

    // entityIds is 0..N current Senzing entities for that logical person.
    // Use them to build your DTO via GetEntity calls, etc.
}
```

No in‑memory union‑find; all the magic lives in the DB.

---

## 4. So… do you _need_ union‑find?

**In-memory union‑find?**
No. In a Kubernetes deployment you absolutely want the **DB to own all aliasing**, and you can use simple “canonical_id” columns plus a loop to resolve.

**The union‑find _idea_?**
Yes-ish, but it’s very lightweight:

- It just means: _when you see two StableIds that are the same real person, update your DB so they both resolve to a single canonical StableId, and always resolve from client‑supplied IDs to that canonical one before doing anything else._

Your “just redirect merged deaths to the survivor” is _exactly_ that.
The code above is basically a cleaned-up, DB‑backed version of that idea.

If you like, next step we can sketch concrete SQL schema + example merge transaction for, say, PostgreSQL or SQL Server, but the C# above should be enough to plug into your existing DAL and keep the complexity under control.
