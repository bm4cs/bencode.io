---
layout: post
draft: false
title: "Entity Resolution and the Instability Problem"
slug: "entity"
date: "2025-12-02 9:02:00+1100"
lastmod: "2025-12-02 9:02:00+1100"
comments: false
categories:
  - entityresolution
  - data
  - dev
---

- [The Problem](#the-problem)
- [Solution 1: Make the API record‑centric, not entity‑centric](#solution-1-make-the-api-recordcentric-not-entitycentric)
- [Solution 2: Introduce your own _stable_ external Entity ID and map it to Senzing](#solution-2-introduce-your-own-stable-external-entity-id-and-map-it-to-senzing)
  - [2.1. Public vs internal IDs](#21-public-vs-internal-ids)
  - [2.2. Handling merges](#22-handling-merges)
  - [2.3. Handling splits](#23-handling-splits)
  - [2.4. Pros / Cons](#24-pros--cons)
- [Solution 3: Provide an entity change feed (events) for downstream sync](#solution-3-provide-an-entity-change-feed-events-for-downstream-sync)
  - [3.1. Why?](#31-why)
  - [3.2. Event model](#32-event-model)
- [Solution 4: Treat entity IDs as _ephemeral handles_ with TTL semantics](#solution-4-treat-entity-ids-as-ephemeral-handles-with-ttl-semantics)
- [Solution 5: Event‑sourcing / versioned entities (for heavy compliance/audit use‑cases)](#solution-5-eventsourcing--versioned-entities-for-heavy-complianceaudit-usecases)
- [FrankenRes](#frankenres)
  - [Internals](#internals)
  - [API surface](#api-surface)
- [Detecting Splits and Merges with Senzing](#detecting-splits-and-merges-with-senzing)
  - [1. What Senzing actually provides](#1-what-senzing-actually-provides)
  - [2. Minimum state you need to track](#2-minimum-state-you-need-to-track)
  - [3. Robust per-event processing pattern](#3-robust-per-event-processing-pattern)
    - [Concurrency safeguard](#concurrency-safeguard)
  - [Split vs Merge Detection](#split-vs-merge-detection)
    - [Detecting **splits**](#detecting-splits)
  - [Detecting **merges**](#detecting-merges)
  - [A simplier way without splits and merges](#a-simplier-way-without-splits-and-merges)
- [Senzing Lifecycle Detector C# Implementation](#senzing-lifecycle-detector-c-implementation)
  - [Single-file example](#single-file-example)
  - [Usage](#usage)
- [TL;DR](#tldr)

## The Problem

The classic entity resolution gotcha: the thing that looks like a primary key (e.g. Senzing's entity ID) is actually a volatile cluster ID that can legitimately change as the engine learns. Senzing explicitly says their resolved entity ID is **not** a globally unique persistent identifier and that it's just an identifier for a grouping that may be transient. ([senzing.zendesk.com][1])

So the key is: don't allow that volatility to leak into your external contract.

Here are the main patterns people use.

## Solution 1: Make the API record‑centric, not entity‑centric

This is the simplest and often the cleanest model.

**Idea:**
External systems never get a “permanent entity ID”. Instead they:

1. **Register records** using their own stable IDs:

   - `sourceSystem` + `sourceRecordId` is the real identity.
   - You store those records in your DB and in Senzing.

2. **Resolve at read time**:

   - When a client wants “the entity this record belongs to”, the API looks it up _by record_, not by entity ID.
   - With Senzing, that means using the “get entity by record ID” type APIs (e.g. `getEntityByRecordID(datasource_code, record_id, ...)`), which Senzing explicitly supports. ([Senzing Entity Resolution AI][2])

**Example API design**

- `POST /records`

  - Body includes `{ sourceSystem, sourceRecordId, attributes... }`

- `GET /records/{sourceSystem}/{sourceRecordId}`

  - Returns that record plus a resolved entity projection.

- `GET /records/{sourceSystem}/{sourceRecordId}/entity`

  - Under the hood: call Senzing `getEntityByRecordID`.
  - Returns the _current_ entity view (records, features, related entities, etc).

**Pros**

- Entity splits/merges are naturally handled; you always get “whatever Senzing thinks right now”.
- No “broken” external IDs.
- Easy mental model: “the record is stable; the entity is a view over time”.

**Cons**

- Consumers can't store a single durable “entity ID” and reuse it forever; they must always go via record IDs (or search by attributes).
- If they want a list of all records in the same entity, they still need your service (not just a key).

This approach works really well if integrating systems mostly care about **“what's the current 360° view for this record?”** and don't need a long‑lived, globally referenced entity key.

## Solution 2: Introduce your own _stable_ external Entity ID and map it to Senzing

If consumers really _must_ have something like `CustomerId` that they can embed in their own systems, the common pattern is:

> **Create your own public entity identifier and treat Senzing's entity ID as an internal implementation detail.**

### 2.1. Public vs internal IDs

You maintain:

- `PublicEntityId` – a GUID/string you generate and expose in your API (e.g. `ENT-598ad7d…`).
- `SenzingEntityId` – the current `RES_ENT_ID` from Senzing; never exposed directly.

Internally you keep a mapping:

```text
PublicEntityId -> current SenzingEntityId
PublicEntityId -> status/history (current, merged, split, deleted)
PublicEntityId -> set of records (sourceSystem + sourceRecordId)
```

Senzing already encourages using record‑to‑entity mappings in downstream systems (e.g., “replicate a table indexed by RECORD_ID and RES_ENT_ID”). ([senzing.zendesk.com][3])

### 2.2. Handling merges

When Senzing tells you that entities A and B have merged (via its change/replication feed ([Senzing Entity Resolution AI][4])):

- Decide which `PublicEntityId` is the “survivor” (often the oldest).
- Mark the other(s) as **merged** and point them at the survivor.

So:

```text
PublicEntityId E1 -> current SenzingEntityId 123 (status: current)
PublicEntityId E2 -> (status: mergedInto E1)
```

**API behavior:**

- `GET /entities/E1` → returns current entity snapshot.
- `GET /entities/E2` → returns something like:

  ```json
  {
    "id": "E2",
    "status": "merged",
    "mergedInto": "E1"
  }
  ```

Clients can then migrate their references from `E2` to `E1`. You might also:

- Return HTTP `301` with `Location: /entities/E1`.
- Or return a 200 with `status=merged` plus `mergedInto`.

### 2.3. Handling splits

When a Senzing entity splits into two or more clusters, you:

- Mark the original `PublicEntityId` as **split**.
- Create new `PublicEntityId`s for each of the new clusters and map them to the new Senzing entity IDs.
- Link them via `"splitInto": ["E3", "E4"]`.

**API:**

```json
{
  "id": "E0",
  "status": "split",
  "splitInto": ["E3", "E4"]
}
```

Consumers then decide how to handle that (e.g. re‑attach their local references to whichever of E3/E4 makes sense).

### 2.4. Pros / Cons

**Pros**

- Consumers get a **stable external ID** which you control.
- You can expose a clean REST API with `GET /entities/{id}` and still evolve with Senzing behind the scenes.
- You can attach business history and metadata to the public entity independent of Senzing.

**Cons**

- You now own the complexity of:

  - Listening to Senzing's change stream.
  - Maintaining merge/split history.
  - Handling edge cases in mapping.

- You need a bit more schema: tables for `PublicEntity`, `EntityAlias`, `EntityHistory`, etc.

This is basically how many MDM/CRM/“customer 360” platforms are layered on top of an ER engine.

## Solution 3: Provide an entity change feed (events) for downstream sync

Regardless of whether you expose your own `PublicEntityId` or stick to record‑centric access, **an event stream is incredibly useful**.

### 3.1. Why?

Because Senzing can re‑decide past assertions as new data arrives. It's built to do that; the docs explicitly talk about revisiting earlier entity decisions as part of real‑time learning. ([Senzing Entity Resolution AI][5])

Rather than consumers discovering this only when they do a “random” lookup, you can push changes out.

### 3.2. Event model

You can expose:

- A Kafka topic, message queue, or
- `GET /entity-changes?since=cursor` style API.

Events like:

```json
{
  "type": "MERGE",
  "timestamp": "2025-12-01T10:23:45Z",
  "oldEntities": ["E2", "E5"],
  "newEntity": "E1"
}
```

```json
{
  "type": "SPLIT",
  "timestamp": "2025-12-01T11:05:00Z",
  "oldEntity": "E0",
  "newEntities": ["E3", "E4"]
}
```

```json
{
  "type": "UPDATE",
  "timestamp": "...",
  "entity": "E1",
  "changeSummary": { ... }
}
```

Downstream systems can subscribe and repair their own local references.

## Solution 4: Treat entity IDs as _ephemeral handles_ with TTL semantics

If you **don't** need a long‑term, shareable ID – maybe clients just want to:

- look up an entity,
- make a decision,
- throw it away –

then you can “embrace the chaos”.

**Contract:**

- `/entities/{entityId}` is valid now, but may become invalid later.
- When it changes, clients must re‑resolve from records or search.

Implementation details:

- Return ETags / version tokens with entity responses.
- If a client calls `GET /entities/123` and that entity has disappeared or changed dramatically due to a split/merge:

  - Return 404/410, or
  - Return a body saying `"status": "invalid", "supersededBy": [...]`.

This approach is minimal overhead but only works if nobody treats the ID as a canonical key.

## Solution 5: Event‑sourcing / versioned entities (for heavy compliance/audit use‑cases)

If you're in a world of audits, “why did we make that decision in 2023?”, or regulated domains, you can go further and **version the entity view**.

Pattern:

- Each change (merge, split, membership change, attribute change) becomes an event in your store.
- `PublicEntityId` + `version` identifies a specific historical state.
- API examples:

  - `GET /entities/{id}` → latest.
  - `GET /entities/{id}/versions/{version}` → historical snapshot.
  - `GET /entities/{id}/history` → list of changes (including merges/splits).

You can build those events off Senzing's change notifications / replication tables. ([Senzing Entity Resolution AI][4])

This is more effort, but it neatly separates:

- “What did we think at the time?” (immutable history)
- “What do we think now?” (current resolution).

## FrankenRes

As I'm designing an entity management system around Senzing, I'm planning to combine the desirable traits of a few of the solutions together.

### Internals

- **Value objects**

  - `RecordId` = `(sourceSystem, sourceRecordId)`
  - `PublicEntityId` = GUID/string.
  - `SenzingEntityId` = long (internal only).

- **Tables**

  - `Records` – your metadata + Senzing's internal record IDs.
  - `PublicEntities` – `PublicEntityId`, status, `CurrentSenzingEntityId`, etc.
  - `EntityLinks` – links for merges/splits (old → new).
  - `EntityMembership` – which records belong to which `PublicEntityId`.

- **Integration with Senzing**

  - On record add/update/remove:

    - Call Senzing add/update/delete.
    - Use `getEntityByRecordID` or similar to get the current entity state. ([Senzing Entity Resolution AI][2])

  - Run a small component that consumes Senzing's “affected entity” / replication stream to detect merges/splits and update mappings. ([Senzing Entity Resolution AI][4])

### API surface

- **Record endpoints (recommended for all consumers)**

  - `POST /records`
  - `GET /records/{source}/{id}`
  - `GET /records/{source}/{id}/entity` – fresh resolution.

- **Entity endpoints (for consumers who really want entities)**

  - `GET /entities/{publicId}` – returns:

    ```json
    {
      "id": "E1",
      "status": "current|merged|split|deleted",
      "supersededBy": ["E3"],
      "splitInto": [],
      "records": [...],
      "attributes": {...}
    }
    ```

- **Change feed**

  - `GET /entity-changes?since=cursor` or a message topic.

Document clearly:

- Senzing entity IDs are **internal and unstable**.
- `PublicEntityId` is stable, but its **meaning** (which records/attributes it aggregates) can change, and when it does you'll emit events and expose history.

## Detecting Splits and Merges with Senzing

Senzing V4 _never_ tells you “this was a merge” or “this was a split”. You only get **AFFECTED_ENTITIES** from the `AddRecord/DeleteRecord/ProcessRedoRecord` calls, and you're expected to call `GetEntity` for each and maintain your own view of what changed.

Senzing leave this problem up to you to solve, i.e. track previous entity states in your own datastore and diff it.

### 1. What Senzing actually provides

From the docs / tutorials:

- `AddRecord(...)` and `DeleteRecord(...)` with `SzWithInfo` return JSON containing `AFFECTED_ENTITIES: [ { "ENTITY_ID": ... }, ... ]`.
- `ProcessRedoRecord(...)` with `SzWithInfo` returns the same structure.
- “AFFECTED_ENTITIES is the list of entity IDs impacted by the API function.”
- Recommended pattern: for each affected entity ID, call `GetEntity(entityId, flags)` (“getEntityByEntityID()” in some docs); if the entity does **not** exist it was _moved or deleted_; if it does exist, you decide how to use the new state.
- The `GetEntity` response contains `RECORDS` (DATA_SOURCE + RECORD_ID) and other rich fields.

And importantly, they explicitly explain **why** WithInfo does _not_ tell you what type of change occurred (merge/split/etc): the engine is fully parallel, there's no guaranteed global ordering, and they don't want to force you into a strict sequential log.

So: your job is to take these primitives and build your own model of **entity lifecycle**.

### 2. Minimum state you need to track

You _don't_ need to store full historical `GetEntity` blobs to get robust merge/split detection.

The key is to track **record → entity** over time:

```text
RecordAssignment
----------------
(DATA_SOURCE, RECORD_ID) -> lastKnownEntityId
```

Optionally, you can also track:

```text
EntitySummary
-------------
EntityId -> LastKnownExists (bool), LastSeenAt (timestamp)
```

With that alone you can:

- Reconstruct which records _used_ to belong to a given entity (all rows where `lastKnownEntityId == Eold`).
- See which entity they belong to _now_ (via `GetEntity(dataSource, recordId, flags)` or by looking at the current `GetEntity(entityId)` responses).

You can still keep a denormalized snapshot of the entity if you want, but it's not essential for merge/split detection.

### 3. Robust per-event processing pattern

For every call that can change resolution (`AddRecord`, `AddOrReplaceRecord`, `DeleteRecord`, `ProcessRedoRecord`, etc., always using `SzWithInfo`):

1. **Call engine, get info JSON**

   ```csharp
   var infoJson = engine.AddRecord(ds, recordId, recordJson, SzFlag.SzWithInfo);
   var info = JsonNode.Parse(infoJson).AsObject();
   var affected = info["AFFECTED_ENTITIES"].AsArray();
   ```

2. **Build a work set for this event**

   ```text
   A = set of entity IDs in AFFECTED_ENTITIES
   ```

3. **Snapshot “before” state from your DB (no Senzing calls)**

   For each `E ∈ A`:

   - `preExists[E]` = `EntitySummary[E]?.LastKnownExists` (default false).
   - `preRecords[E]` = all `(ds, recordId)` with `RecordAssignment.lastKnownEntityId == E`.

   (This is the “what we believed” _before_ this event.)

4. **Fetch “after” state from Senzing**

   For each `E ∈ A`:

   - Try `engine.GetEntity(E, flags)`:

     - If it succeeds → `postExists[E] = true; postRecords[E] = RECORDS[] from response`.
     - If it throws `SzNotFoundException` → `postExists[E] = false; postRecords[E] = ∅`.

5. **Build a reverse map (record → new entity IDs)**

   ```text
   currentByRecord[(ds, recordId)] = set of entityIds that contain it now
   ```

   Fill this from all `postRecords[E]` where `postExists[E] == true`.

6. **Now you can classify merges/splits/deletes per _old_ entity ID Eold**

   For each `Eold ∈ A` with `preExists[Eold] == true && postExists[Eold] == false`:

   - Let `Rold = preRecords[Eold]`.
   - For each `r ∈ Rold`:

     - If `currentByRecord` has an entry → add that entityId to `nextEntities[Eold]`.
     - Else → this record has disappeared (deleted or not yet visible) → add `r` to `deletedRecords[Eold]`.

   Then:

   ```text
   if nextEntities[Eold] is empty:
       Eold fully died (all its records gone or invisible)  -> DELETE
   else if nextEntities[Eold] has exactly 1 member F:
       Eold's records have all moved into a single entity F -> MERGE (Eold -> F)
       (with possible partial deletion if deletedRecords not empty)
   else if nextEntities[Eold] has > 1 members:
       Eold's records have fanned out to multiple entities  -> SPLIT (Eold -> nextEntities[Eold])
       (again, with possible partial deletion)
   ```

   That gives you the classification **from the perspective of each retired entity**.

7. **Classify from the survivor side (optional)**

   For each `F ∈ A` with `postExists[F] == true`:

   - Let `contributors[F] = { Eold | F ∈ nextEntities[Eold] }`.

   Then:

   - If `contributors[F]` is empty and `!preExists[F]` → _birth_ (new entity only).
   - If `contributors[F]` has 1 member and `preExists[F]` → _growth/move_ (one other entity's records moved in, or records moved from Eold to F).
   - If `contributors[F]` has multiple members → _merge of those contributors into F_.

8. **Finally, update your DB**

   - For every entity `E` with `postExists[E] == true`, set `EntitySummary[E].LastKnownExists = true`, update last-seen time.
   - For every entity `E` where `postExists[E] == false`, set `LastKnownExists = false`.
   - For every `(ds, recordId)` in all `postRecords[E]`, set `RecordAssignment.lastKnownEntityId = E`.

You can hang whatever event/log model you like off the classification in steps 6–7.

#### Concurrency safeguard

Senzing's own guidance: you _may_ process affected entities in parallel, but you **must not process the same entity ID in parallel**.

So when you enqueue work from `AFFECTED_ENTITIES`, make sure updates for a given `entityId` are serialized (e.g., per-entity queue or a “keyed lock”).

### Split vs Merge Detection

#### Detecting **splits**

> _“What is the most robust way to detect split scenarios with these primitive APIs?”_

Using the pattern above, a **split** is simply:

> An entity ID Eold that previously existed and now does **not** exist, and whose previously-owned records now belong to **more than one** entity ID.

Concretely:

```text
preExists[Eold] == true
postExists[Eold] == false
|nextEntities[Eold]| > 1
```

Where `nextEntities[Eold]` is computed by walking all records that _used to_ belong to Eold and seeing which entity contains them _now_.

That automatically handles your “E100 superseded by E101 and E102” example:

- Before: `E100 = {R10, R11, R12}`
- After: `E101 = {R10}`, `E102 = {R11, R12}`, `E100` missing.
- `nextEntities[E100] = {E101, E102}` → SPLIT.

And also the variant where the old ID survives but loses records:

- Before: `E100 = {R10, R11, R12}`
- After: `E100 = {R10}`, `E101 = {R11, R12}`
- `preExists[E100] == true`, `postExists[E100] == true`
- From E100's perspective:

  - `R10` still in `E100`
  - `R11, R12` now in `E101`
  - `nextEntities[E100] = {E100, E101}` → it's both _shrunk_ and _partially split_.
    You can call this a “partial split” if you want a richer vocabulary.

You _don't_ have to special-case “split into brand new entities”; the classification uses the _record movement_, not whether the new entity has been seen before.

### Detecting **merges**

> _“I can either assume a delete or a merge has occurred when GetEntity(entityId) fails … to distinguish if a merge has occurred I'd check where those records went.”_

Exactly.

Using the same notation:

For Eold with `preExists[Eold] == true && postExists[Eold] == false`:

- If `nextEntities[Eold]` has **exactly one** element `F`:

  - All surviving records from Eold have moved into a single entity F → **merge into F**.

- If `nextEntities[Eold]` has **more than one** → **split** (maybe plus some deletion).
- If `nextEntities[Eold]` is **empty** → **delete** (everything gone).

This also handles multi-way merges:

- Before: `E1 = {A}`, `E2 = {B}`, `E3 = {C}`
- After: `E9 = {A, B, C}`, `E1,E2,E3` missing.
- For each of E1, E2, E3: `nextEntities[Ex] = {E9}` → each has **merge into E9**.
- For E9: `contributors[E9] = {E1, E2, E3}` → “merge of E1, E2, E3”.

### A simplier way without splits and merges

You _are_ taking on more than Senzing officially asks you to, but what you're doing is a valid, principled extension — not nonsense.

However, there are two important caveats:

1. **You will never get a perfect, globally ordered timeline of “true” merges/splits.**
   Senzing explicitly avoids providing a sequential event log; events for different entities can interleave, config changes can trigger `redo` processing, etc.
   What you _can_ get is a consistent stream of “here's the latest state and what disappeared / where it went”, which is usually good enough to:

   - Redirect old IDs to current ones.
   - Explain “this old entity is now represented by these N new entities”.

2. **For the “stable external ID” illusion, you actually don't need explicit merge/split labels.**

   A cleaner pattern for your public API is:

   - Introduce your own **StableEntityId** (GUID, long, whatever).
   - Maintain:

     ```text
     StableEntity
     ------------
     StableId
     -> set of current Senzing entity IDs attached to this stable ID
     ```

   - When you observe a new Senzing entity (from `GetEntity` during AFFECTED_ENTITIES processing):

     - Look at its records; find any existing StableIds those records are already associated with.
     - If **none** → create a new StableId.
     - If **one** → attach this Senzing entity to that StableId.
     - If **many** → you've just discovered a _merge_ at the stable layer → unify those StableIds (Union-Find style).

   Then your external behaviour becomes:

   - Client calls your API with **StableId**.
   - Internally, you resolve that to 0, 1 or N live Senzing entity IDs:

     - 0 → the entity is gone (all records deleted).
     - 1 → simple redirect to the survivor.
     - N>1 → “this logical person has split into multiple Senzing entities; here's the list”.

   In this design, you don't really care if the underlying engine event on any given day was a “merge” or a “split”; you care about **what stable identity the records belong to now**.

Your current delta logic is still useful if you want an audit trail or event stream (e.g. “On 2025‑11‑01, E100 split into E101 & E102”), but for the _stable-ID illusion_ you can get away with something much simpler, driven only by record-to-entity assignments.

## Senzing Lifecycle Detector C# Implementation

Here's a concrete C# implementation of the **per‑event processing pattern** we discussed, wired to:

- `SzEngine.AddRecord(..., SzWithInfo)` and `AFFECTED_ENTITIES`
- `SzEngine.GetEntity(long, SzEntityDefaultFlags)` and the `RESOLVED_ENTITY.RECORDS` array

DB pieces are **stubbed**, but the core data structures (`preExists`, `preRecords`, `postExists`, `postRecords`, `currentByRecord`, `deletedRecords`, `nextEntities`, etc.) are fully wired and commented.

### Single-file example

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Nodes;
using Senzing.Sdk;
// optional, but convenient so we can write SzWithInfo, SzEntityDefaultFlags directly:
using static Senzing.Sdk.SzFlag;

namespace YourNamespace.Senzing
{
    /// <summary>
    /// Simple value object for identifying a record in Senzing.
    /// </summary>
    public readonly record struct RecordKey(string DataSource, string RecordId);

    /// <summary>
    /// Coarse-grained classification of how an entity changed during a single event.
    /// You can expand this to whatever vocabulary you want.
    /// </summary>
    public enum EntityChangeKind
    {
        Unknown = 0,
        Birth,          // did not exist before, exists now
        Death,          // existed before, now gone, records also gone
        MergeInto,      // this entity ID disappeared, records moved into one other entity
        SplitInto,      // this entity ID disappeared, records fanned out to multiple entities
        Shrink,         // same ID, lost records only
        Grow,           // same ID, gained records only
        Changed,        // same ID, both lost and gained records (partial split/merge)
        Unchanged       // same set of records
    }

    /// <summary>
    /// Summary of how a given entity ID changed in one WithInfo event.
    /// </summary>
    public sealed class EntityChangeSummary
    {
        public long EntityId { get; init; }

        public bool PreExists { get; init; }
        public bool PostExists { get; init; }

        public IReadOnlyList<RecordKey> PreRecords { get; init; } = Array.Empty<RecordKey>();
        public IReadOnlyList<RecordKey> PostRecords { get; init; } = Array.Empty<RecordKey>();

        /// <summary>
        /// For an entity that disappeared, which entity IDs now own its records.
        /// (If 0 -> delete, 1 -> merge, >1 -> split.)
        /// </summary>
        public IReadOnlyCollection<long> NextEntities { get; init; } = Array.Empty<long>();

        /// <summary>
        /// Records that used to belong to this entity but are no longer present anywhere
        /// (as far as we can see right after this event).
        /// </summary>
        public IReadOnlyList<RecordKey> DeletedRecords { get; init; } = Array.Empty<RecordKey>();

        public EntityChangeKind ChangeKind { get; init; }

        /// <summary>
        /// Optional: entities that contributed records into this entity.
        /// Useful to describe merges from the survivor's point of view.
        /// </summary>
        public IReadOnlyCollection<long> Contributors { get; init; } = Array.Empty<long>();
    }

    /// <summary>
    /// Abstraction for your persistence of "last known entity state".
    /// Implement this using your own DB / ORM layer.
    /// </summary>
    public interface IEntityStateRepository
    {
        /// <summary>
        /// Returns true if we previously knew this entity ID to exist.
        /// If it's completely unknown, return false.
        /// </summary>
        bool WasKnownToExist(long entityId);

        /// <summary>
        /// Returns the last known records for this entity ID.
        /// If we have no history for it, return an empty list.
        /// </summary>
        IReadOnlyList<RecordKey> GetKnownRecords(long entityId);

        /// <summary>
        /// Update our snapshot of an entity's state after processing an event.
        /// If exists == false, you can either delete the row or mark as not-existing.
        /// </summary>
        void SaveEntitySnapshot(long entityId, bool exists, IReadOnlyList<RecordKey> records);
    }

    /// <summary>
    /// Wraps SzEngine and applies the "robust per-event processing pattern"
    /// for AddRecord/DeleteRecord/ProcessRedoRecord WithInfo payloads.
    /// </summary>
    public sealed class SenzingEventProcessor
    {
        private readonly SzEngine _engine;
        private readonly IEntityStateRepository _stateRepo;

        public SenzingEventProcessor(SzEngine engine, IEntityStateRepository stateRepo)
        {
            _engine = engine ?? throw new ArgumentNullException(nameof(engine));
            _stateRepo = stateRepo ?? throw new ArgumentNullException(nameof(stateRepo));
        }

        #region Public entry points around SzEngine

        public IReadOnlyList<EntityChangeSummary> ProcessAddRecord(
            string dataSource,
            string recordId,
            string recordJson)
        {
            // Call Senzing AddRecord with SZ_WITH_INFO to get AFFECTED_ENTITIES. :contentReference[oaicite:2]{index=2}
            string infoJson = _engine.AddRecord(dataSource, recordId, recordJson, SzWithInfo);
            return ProcessWithInfoPayload(infoJson, "AddRecord");
        }

        public IReadOnlyList<EntityChangeSummary> ProcessDeleteRecord(
            string dataSource,
            string recordId)
        {
            // Same idea for DeleteRecord. :contentReference[oaicite:3]{index=3}
            string infoJson = _engine.DeleteRecord(dataSource, recordId, SzWithInfo);
            return ProcessWithInfoPayload(infoJson, "DeleteRecord");
        }

        public IReadOnlyList<EntityChangeSummary> ProcessRedoRecord(string redoRecordJson)
        {
            // And for ProcessRedoRecord (redo stream). :contentReference[oaicite:4]{index=4}
            string infoJson = _engine.ProcessRedoRecord(redoRecordJson, SzWithInfo);
            return ProcessWithInfoPayload(infoJson, "ProcessRedoRecord");
        }

        #endregion

        #region Core per-event algorithm

        private IReadOnlyList<EntityChangeSummary> ProcessWithInfoPayload(
            string infoJson,
            string operationName)
        {
            if (string.IsNullOrWhiteSpace(infoJson))
            {
                // Nothing to do (e.g., flags didn't include SZ_WITH_INFO).
                return Array.Empty<EntityChangeSummary>();
            }

            // 1. Parse the WithInfo JSON and extract AFFECTED_ENTITIES.
            JsonObject? infoObject = JsonNode.Parse(infoJson)?.AsObject()
                                     ?? throw new ArgumentException("Invalid JSON in info payload.", nameof(infoJson));

            var affectedIds = ExtractAffectedEntityIds(infoObject);

            if (affectedIds.Count == 0)
            {
                return Array.Empty<EntityChangeSummary>();
            }

            // 2. Pre-state from *our* DB: preExists, preRecords.
            var preExists = new Dictionary<long, bool>();
            var preRecords = new Dictionary<long, List<RecordKey>>();

            foreach (long entityId in affectedIds)
            {
                bool existed = _stateRepo.WasKnownToExist(entityId);
                preExists[entityId] = existed;

                var records = _stateRepo.GetKnownRecords(entityId)?.ToList()
                              ?? new List<RecordKey>();

                preRecords[entityId] = records;
            }

            // 3. Post-state from Senzing GetEntity: postExists, postRecords.
            var postExists = new Dictionary<long, bool>();
            var postRecords = new Dictionary<long, List<RecordKey>>();

            foreach (long entityId in affectedIds)
            {
                try
                {
                    // GetEntity by entity ID. :contentReference[oaicite:5]{index=5}
                    string entityJson = _engine.GetEntity(entityId, SzEntityDefaultFlags);

                    List<RecordKey> records = ExtractRecordKeysFromEntityJson(entityJson);

                    postExists[entityId] = true;
                    postRecords[entityId] = records;
                }
                catch (SzNotFoundException)
                {
                    // Entity ID is no longer valid.
                    postExists[entityId] = false;
                    postRecords[entityId] = new List<RecordKey>();
                }
            }

            // 4. Build currentByRecord: (DATA_SOURCE, RECORD_ID) -> set of entity IDs that own it now.
            var currentByRecord = new Dictionary<RecordKey, HashSet<long>>();

            foreach (var kvp in postRecords)
            {
                long entityId = kvp.Key;
                foreach (RecordKey record in kvp.Value)
                {
                    if (!currentByRecord.TryGetValue(record, out var set))
                    {
                        set = new HashSet<long>();
                        currentByRecord[record] = set;
                    }
                    set.Add(entityId);
                }
            }

            // 5. For entities that *used* to exist, figure out where their records went:
            //    deletedRecords + nextEntities.
            var deletedRecords = new Dictionary<long, List<RecordKey>>();
            var nextEntities = new Dictionary<long, HashSet<long>>();

            foreach (long entityId in affectedIds)
            {
                bool existedBefore = preExists.TryGetValue(entityId, out var ex) && ex;
                if (!existedBefore)
                {
                    continue; // Nothing to compare.
                }

                List<RecordKey> oldRecords = preRecords[entityId];

                var nextSet = new HashSet<long>();
                var deletedList = new List<RecordKey>();

                foreach (RecordKey record in oldRecords)
                {
                    if (currentByRecord.TryGetValue(record, out var ownersNow) &&
                        ownersNow.Count > 0)
                    {
                        // Typically a record belongs to exactly one entity, but we don't assume.
                        foreach (long owner in ownersNow)
                        {
                            nextSet.Add(owner);
                        }
                    }
                    else
                    {
                        // We don't see this record in any entity now -> treat as deleted.
                        deletedList.Add(record);
                    }
                }

                if (nextSet.Count > 0)
                {
                    nextEntities[entityId] = nextSet;
                }

                if (deletedList.Count > 0)
                {
                    deletedRecords[entityId] = deletedList;
                }
            }

            // 6. Build contributors: for each entity that exists now, which old entity IDs fed into it?
            var contributors = new Dictionary<long, HashSet<long>>();

            foreach (var kvp in nextEntities)
            {
                long from = kvp.Key;
                foreach (long to in kvp.Value)
                {
                    if (!contributors.TryGetValue(to, out var set))
                    {
                        set = new HashSet<long>();
                        contributors[to] = set;
                    }
                    set.Add(from);
                }
            }

            // 7. Classify change kind for each affected entity ID.
            var results = new List<EntityChangeSummary>();

            foreach (long entityId in affectedIds)
            {
                bool existedBefore = preExists.TryGetValue(entityId, out var exBefore) && exBefore;
                bool existsNow = postExists.TryGetValue(entityId, out var exNow) && exNow;

                List<RecordKey> before = preRecords.TryGetValue(entityId, out var pr)
                    ? pr
                    : new List<RecordKey>();

                List<RecordKey> after = postRecords.TryGetValue(entityId, out var po)
                    ? po
                    : new List<RecordKey>();

                HashSet<long> nextSet = nextEntities.TryGetValue(entityId, out var ns)
                    ? ns
                    : new HashSet<long>();

                List<RecordKey> deleted = deletedRecords.TryGetValue(entityId, out var dr)
                    ? dr
                    : new List<RecordKey>();

                // Default classification.
                EntityChangeKind kind = EntityChangeKind.Unknown;

                if (!existedBefore && existsNow)
                {
                    // Newly created entity ID.
                    kind = EntityChangeKind.Birth;
                }
                else if (existedBefore && !existsNow)
                {
                    // Entity ID disappeared.
                    if (nextSet.Count == 0)
                    {
                        // No surviving records anywhere (or not visible yet) -> death/delete.
                        kind = EntityChangeKind.Death;
                    }
                    else if (nextSet.Count == 1)
                    {
                        // All surviving records moved into a single entity -> merge.
                        kind = EntityChangeKind.MergeInto;
                    }
                    else
                    {
                        // Surviving records fanned out across multiple entities -> split.
                        kind = EntityChangeKind.SplitInto;
                    }
                }
                else if (existedBefore && existsNow)
                {
                    // Same entity ID, but we may have gained or lost records.
                    var oldSet = new HashSet<RecordKey>(before);
                    var newSet = new HashSet<RecordKey>(after);

                    bool lostAny = oldSet.Except(newSet).Any();
                    bool gainedAny = newSet.Except(oldSet).Any();

                    if (!lostAny && !gainedAny)
                    {
                        kind = EntityChangeKind.Unchanged;
                    }
                    else if (gainedAny && !lostAny)
                    {
                        kind = EntityChangeKind.Grow;
                    }
                    else if (!gainedAny && lostAny)
                    {
                        kind = EntityChangeKind.Shrink;
                    }
                    else
                    {
                        // Both: some records left, some came in.
                        kind = EntityChangeKind.Changed;
                    }
                }

                // Contributors (from survivor's perspective).
                HashSet<long> contributorSet = contributors.TryGetValue(entityId, out var cs)
                    ? cs
                    : new HashSet<long>();

                var summary = new EntityChangeSummary
                {
                    EntityId = entityId,
                    PreExists = existedBefore,
                    PostExists = existsNow,
                    PreRecords = before,
                    PostRecords = after,
                    NextEntities = nextSet,
                    DeletedRecords = deleted,
                    ChangeKind = kind,
                    Contributors = contributorSet
                };

                results.Add(summary);
            }

            // 8. Persist our new snapshot of entity -> records.
            foreach (long entityId in affectedIds)
            {
                bool existsNow = postExists.TryGetValue(entityId, out var exNow) && exNow;
                List<RecordKey> nowRecords = postRecords.TryGetValue(entityId, out var list)
                    ? list
                    : new List<RecordKey>();

                _stateRepo.SaveEntitySnapshot(entityId, existsNow, nowRecords);
            }

            // At this point you could also publish the EntityChangeSummary list
            // to an event stream, stable-ID layer, etc.
            return results;
        }

        #endregion

        #region Helper methods

        /// <summary>
        /// Extracts entity IDs from the AFFECTED_ENTITIES array
        /// in an AddRecord/DeleteRecord/ProcessRedoRecord WithInfo response.
        /// </summary>
        private static HashSet<long> ExtractAffectedEntityIds(JsonObject infoObject)
        {
            var result = new HashSet<long>();

            JsonArray? affectedArr = infoObject["AFFECTED_ENTITIES"]?.AsArray();
            if (affectedArr == null) return result;

            foreach (JsonNode? node in affectedArr)
            {
                JsonObject? obj = node?.AsObject();
                if (obj == null) continue;

                long id = obj["ENTITY_ID"]?.GetValue<long>() ?? 0L;
                if (id > 0)
                {
                    result.Add(id);
                }
            }

            return result;
        }

        /// <summary>
        /// Parses a GetEntity(...) JSON response and returns the list of record keys
        /// in RESOLVED_ENTITY.RECORDS[*].(DATA_SOURCE, RECORD_ID). :contentReference[oaicite:6]{index=6}
        /// </summary>
        private static List<RecordKey> ExtractRecordKeysFromEntityJson(string entityJson)
        {
            var result = new List<RecordKey>();

            if (string.IsNullOrWhiteSpace(entityJson))
                return result;

            JsonObject? root = JsonNode.Parse(entityJson)?.AsObject();
            if (root == null) return result;

            JsonObject? resolved = root["RESOLVED_ENTITY"]?.AsObject();
            if (resolved == null) return result;

            JsonArray? recordsArr = resolved["RECORDS"]?.AsArray();
            if (recordsArr == null) return result;

            foreach (JsonNode? node in recordsArr)
            {
                JsonObject? rec = node?.AsObject();
                if (rec == null) continue;

                string? ds = rec["DATA_SOURCE"]?.GetValue<string>();
                string? rid = rec["RECORD_ID"]?.GetValue<string>();

                if (!string.IsNullOrEmpty(ds) && !string.IsNullOrEmpty(rid))
                {
                    result.Add(new RecordKey(ds!, rid!));
                }
            }

            return result;
        }

        #endregion
    }
}
```

### Usage

In your service:

```csharp
// Somewhere during startup:
SzEnvironment env = /* obtain from Senzing setup */;
SzEngine engine = env.GetEngine();
IEntityStateRepository stateRepo = new MyEntityStateRepository(/* your DB stuff */);

var processor = new SenzingEventProcessor(engine, stateRepo);

// Adding a record:
var changes = processor.ProcessAddRecord("CUSTOMERS", "12345", recordJson);

// 'changes' now tells you, per entity ID:
// - did it appear/disappear
// - old vs new record membership
// - whether it merged/split/shrank/grew
// - where its records moved to (NextEntities)
// - which old entities fed into each survivor (Contributors)
```

You can then plug `EntityChangeSummary` into your **stable ID layer**:

- For merges: unify StableIds that contributed into the same survivor.
- For splits: map the old StableId to multiple new Senzing entities, etc.

## TL;DR

- **Never** expose Senzing's raw entity IDs as “the” ID – they're defined by Senzing itself as transient cluster identifiers. ([senzing.zendesk.com][1])
- Base your external contract on:

  - **Stable record IDs** and/or
  - **Your own stable entity IDs** with mapping, history, and events.

- Senzing intentionally gives you only `AFFECTED_ENTITIES` + `GetEntity` and expects you to maintain your own view.
- For robust split/merge detection:

  - Track `RecordAssignment` and `EntitySummary` in your DB.
  - For each WithInfo event, snapshot pre-state from your DB, fetch post-state with `GetEntity`, diff, and classify using the `nextEntities` logic above.

- For your _public_ API:

  - Strongly consider a **StableEntityId** layer built on top of this, instead of exposing Senzing IDs directly.
  - For old IDs, you can:

    - Redirect to a single survivor when there's exactly one.
    - Return the current set of underlying entities when there are many.

[1]: https://senzing.zendesk.com/hc/en-us/articles/4415858978067-How-does-an-Entity-ID-behave?utm_source=chatgpt.com "How does an Entity ID behave? - Senzing®"
[2]: https://senzing.com/docs/python/3/g2engine/getting/?utm_source=chatgpt.com "G2Engine Getting Entities and Records :: Senzing Documentation"
[3]: https://senzing.zendesk.com/hc/en-us/articles/360010716274--Advanced-Replicating-the-Senzing-results-to-a-Data-Warehouse?utm_source=chatgpt.com "[Advanced] Replicating the Senzing results to a Data Warehouse"
[4]: https://senzing.com/docs/tutorials/advanced_replication/?utm_source=chatgpt.com "Advanced Real-time Replication and Analytics - senzing.com"
[5]: https://senzing.com/how-entity-resolution-works-with-senzing/?utm_source=chatgpt.com "How Senzing Entity Resolution AI Works"
