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
  - [TL;DR](#tldr)
- [FrankenRes](#frankenres)
  - [Internals](#internals)
  - [API surface](#api-surface)

## The Problem

The classic entity resolution gotcha: the thing that looks like a primary key (e.g. Senzing’s entity ID) is actually a volatile cluster ID that can legitimately change as the engine learns. Senzing explicitly says their resolved entity ID is **not** a globally unique persistent identifier and that it’s just an identifier for a grouping that may be transient. ([senzing.zendesk.com][1])

So the key is: don’t allow that volatility to leak into your external contract.

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

- Consumers can’t store a single durable “entity ID” and reuse it forever; they must always go via record IDs (or search by attributes).
- If they want a list of all records in the same entity, they still need your service (not just a key).

This approach works really well if integrating systems mostly care about **“what’s the current 360° view for this record?”** and don’t need a long‑lived, globally referenced entity key.

## Solution 2: Introduce your own _stable_ external Entity ID and map it to Senzing

If consumers really _must_ have something like `CustomerId` that they can embed in their own systems, the common pattern is:

> **Create your own public entity identifier and treat Senzing’s entity ID as an internal implementation detail.**

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

  - Listening to Senzing’s change stream.
  - Maintaining merge/split history.
  - Handling edge cases in mapping.

- You need a bit more schema: tables for `PublicEntity`, `EntityAlias`, `EntityHistory`, etc.

This is basically how many MDM/CRM/“customer 360” platforms are layered on top of an ER engine.

## Solution 3: Provide an entity change feed (events) for downstream sync

Regardless of whether you expose your own `PublicEntityId` or stick to record‑centric access, **an event stream is incredibly useful**.

### 3.1. Why?

Because Senzing can re‑decide past assertions as new data arrives. It’s built to do that; the docs explicitly talk about revisiting earlier entity decisions as part of real‑time learning. ([Senzing Entity Resolution AI][5])

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

If you **don’t** need a long‑term, shareable ID – maybe clients just want to:

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

If you’re in a world of audits, “why did we make that decision in 2023?”, or regulated domains, you can go further and **version the entity view**.

Pattern:

- Each change (merge, split, membership change, attribute change) becomes an event in your store.
- `PublicEntityId` + `version` identifies a specific historical state.
- API examples:

  - `GET /entities/{id}` → latest.
  - `GET /entities/{id}/versions/{version}` → historical snapshot.
  - `GET /entities/{id}/history` → list of changes (including merges/splits).

You can build those events off Senzing’s change notifications / replication tables. ([Senzing Entity Resolution AI][4])

This is more effort, but it neatly separates:

- “What did we think at the time?” (immutable history)
- “What do we think now?” (current resolution).

### TL;DR

- **Never** expose Senzing’s raw entity IDs as “the” ID – they’re defined by Senzing itself as transient cluster identifiers. ([senzing.zendesk.com][1])
- Base your external contract on:

  - **Stable record IDs** and/or
  - **Your own stable entity IDs** with mapping, history, and events.

- Decide how much sophistication you need:

  - Only current state → record‑centric or simple public IDs.
  - Cross‑system joins → stable public IDs + merge/split mapping.
  - Compliance/audit → add versioning / event sourcing.

## FrankenRes

As I'm designing an entity management system around Senzing, I’m planning to combine the desirable traits of a few of the solutions together.

### Internals

- **Value objects**

  - `RecordId` = `(sourceSystem, sourceRecordId)`
  - `PublicEntityId` = GUID/string.
  - `SenzingEntityId` = long (internal only).

- **Tables**

  - `Records` – your metadata + Senzing’s internal record IDs.
  - `PublicEntities` – `PublicEntityId`, status, `CurrentSenzingEntityId`, etc.
  - `EntityLinks` – links for merges/splits (old → new).
  - `EntityMembership` – which records belong to which `PublicEntityId`.

- **Integration with Senzing**

  - On record add/update/remove:

    - Call Senzing add/update/delete.
    - Use `getEntityByRecordID` or similar to get the current entity state. ([Senzing Entity Resolution AI][2])

  - Run a small component that consumes Senzing’s “affected entity” / replication stream to detect merges/splits and update mappings. ([Senzing Entity Resolution AI][4])

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
- `PublicEntityId` is stable, but its **meaning** (which records/attributes it aggregates) can change, and when it does you’ll emit events and expose history.

[1]: https://senzing.zendesk.com/hc/en-us/articles/4415858978067-How-does-an-Entity-ID-behave?utm_source=chatgpt.com "How does an Entity ID behave? - Senzing®"
[2]: https://senzing.com/docs/python/3/g2engine/getting/?utm_source=chatgpt.com "G2Engine Getting Entities and Records :: Senzing Documentation"
[3]: https://senzing.zendesk.com/hc/en-us/articles/360010716274--Advanced-Replicating-the-Senzing-results-to-a-Data-Warehouse?utm_source=chatgpt.com "[Advanced] Replicating the Senzing results to a Data Warehouse"
[4]: https://senzing.com/docs/tutorials/advanced_replication/?utm_source=chatgpt.com "Advanced Real-time Replication and Analytics - senzing.com"
[5]: https://senzing.com/how-entity-resolution-works-with-senzing/?utm_source=chatgpt.com "How Senzing Entity Resolution AI Works"
