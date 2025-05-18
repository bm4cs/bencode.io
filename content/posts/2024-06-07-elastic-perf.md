---
layout: post
draft: false
title: "Elasticsearch Performance and Tuning"
slug: "esperf"
date: "2024-06-07 18:46:01"
lastmod: "2024-06-07 18:47:30"
comments: false
categories:
  - elastic
tags:
  - elasticsearch
  - logstash
  - kibana
---

A dedicated performance course run by Matt Gregory from Elastic, an absolute legend with deep Elasticsearch expert.

Contents

- [Cool takeaways](#cool-takeaways)
- [Tuning for Index Speed](#tuning-for-index-speed)
  - [Increase the refresh interval](#increase-the-refresh-interval)
  - [Index architecting](#index-architecting)
  - [Bulk](#bulk)
  - [Hardware settings to improve performance](#hardware-settings-to-improve-performance)
    - [Disable swapping](#disable-swapping)
    - [Indexing Buffer size](#indexing-buffer-size)
  - [Best practices and scaling](#best-practices-and-scaling)
    - [Disable replics for initial loads](#disable-replics-for-initial-loads)
    - [Use auto-generated IDs](#use-auto-generated-ids)
    - [Use Cross Cluster Replication](#use-cross-cluster-replication)
  - [Thread Pools](#thread-pools)
  - [Memory Locking](#memory-locking)
  - [Transforms](#transforms)
- [Tuning for search](#tuning-for-search)
  - [API settings and data modelling to improve search performance](#api-settings-and-data-modelling-to-improve-search-performance)
    - [Search as few fields as possible](#search-as-few-fields-as-possible)
    - [One big copy_to field as opposed to individual text multi field](#one-big-copy_to-field-as-opposed-to-individual-text-multi-field)
    - [Consider mapping identifiers as keywords](#consider-mapping-identifiers-as-keywords)
    - [Document modeling](#document-modeling)
    - [Consider mapping numeric fields as keyword](#consider-mapping-numeric-fields-as-keyword)
  - [Hardware settings to improve search](#hardware-settings-to-improve-search)
    - [Warm Up Global Ordinals](#warm-up-global-ordinals)
    - [Warm up filesystem Cache](#warm-up-filesystem-cache)
    - [Use index sorting to speed up search](#use-index-sorting-to-speed-up-search)
  - [Ways to improve searches](#ways-to-improve-searches)
    - [must and should clauses](#must-and-should-clauses)
    - [filter and must not clauses](#filter-and-must-not-clauses)
    - [node query cache](#node-query-cache)
    - [shard request cache](#shard-request-cache)
    - [Aggregation performance](#aggregation-performance)
    - [Search rounded dates](#search-rounded-dates)
    - [Force merge read only indices](#force-merge-read-only-indices)
- [Search profiler and Explain API](#search-profiler-and-explain-api)
  - [Search profiler](#search-profiler)
    - [Search profiler API ID](#search-profiler-api-id)
    - [Query section](#query-section)
    - [Timing breakdown](#timing-breakdown)
    - [Collection section](#collection-section)
    - [Collectors reasons](#collectors-reasons)
    - [Rewrite section](#rewrite-section)
  - [Explain and Tasks API](#explain-and-tasks-api)
    - [Explain API](#explain-api)
    - [Score](#score)
    - [Field length normalization and coordindation](#field-length-normalization-and-coordindation)
    - [Other Query Parameters](#other-query-parameters)
- [API Settings to improve indexing performance](#api-settings-to-improve-indexing-performance)
- [Hardware settings to improve performance](#hardware-settings-to-improve-performance-1)
- [Best Practices and scaling](#best-practices-and-scaling-1)
- [Transforms](#transforms-1)

## Cool takeaways

- Increase the `refresh_interval` from default 1s to something higher, like 10s.
- Index typings should be set to `strict` (default is dynamic)
- The `took` param measures raw cluster operation speed, kibana will also reveal a roundtrip time which includes the HTTP layer.
- Auto generated id's are always faster
- One of Matt's favourite APIs `_cluster/allocation/explain`
- Ensure the heap is beefed up
- a `must` clause is the first line of defence for scoring, `should` is then used as the second pass of scoring
- always format queries as a 'bool'
- Configuration management everywhere (Ansible, etc)
- dedicated monitoring cluster

## Tuning for Index Speed

Cheatsheet:

- No replicas
- 1 shard per node
- No Ingest pipelines
- Load balancers
- SSD, Memory & CPU
- Increase the Heap
- Decrease the refresh interval
- Auto generated IDs

### Increase the refresh interval

By default, Elasticsearch periodically refreshes indices every second (1s), but only on indices that have received one search request or more in the last 30 seconds

If you can afford to increase the amount of time between when a document gets indexed and when it becomes searchable, increasing the index.`refresh_interval` to a larger value, e.g. 30s, might help improve indexing speed

### Index architecting

Turn off dynamic mappings, which will still store the document, but not index new un-mapped fields:

```
PUT new_test
{
  "mappings": {
    "dynamic": "false"
  }
}
```

From a security perspective this is good practice, otherwise ES will arbitrarily start mapping fields dynamically.

You can elect to go further and not even index a document if its mappings don't conform. It will be dropped to a dead letter queue (DLQ)

```
PUT new_test
{
  "mappings": {
    "dynamic": "strict"
  }
}
```

### Bulk

Great for testing.

Here index can be defined an a per operation basis:

```
POST _bulk
{ "index" : { "_index" : "test", "_id" : "1" } }
{ "field1" : "value1" }
{ "delete" : { "_index" : "test", "_id" : "2" } }
{ "create" : { "_index" : "test", "_id" : "3" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "1", "_index" : "test"} }
{ "doc" : {"field2" : "value2"} }
```

- The order of operations is not guaranteed.
- The `create` API will dupe check first.

If all ops apply to the same index, defining the index in the URI of the bulk request is faster:

```
POST test/_bulk
{ "index" : {"_id" : "1" } }
{ "field1" : "value1" }
{ "delete" : {"_id" : "2" } }
{ "create" : {"_id" : "3" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "1"} }
{ "doc" : {"field2" : "value2"} }
```

Auto generated unique ID's are faster to:

```
POST test/_bulk
{ "index" : {}}
{ "field1" : "value1" }
{ "delete" : {"_id" : "2" } }
{ "create" : {"_id" : "3" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "1"} }
{ "doc" : {"field2" : "value2"} }
```

The best way to send data in Bulk operation is with only one type of modifier. For instance only index or only delete. Write a bulk operation with the Index name in the header, auto generated IDs and only indexing documents.

```
POST test/_bulk
{ "index" : {}}
{ "field1" : "value1" }
{ "index" : {}}
{ "field1" : "value2" }
{ "index" : {}}
{ "field1" : "value3" }
{ "index" : {}}
{ "field1" : "value4" }
{ "index" : {}}
{ "field1" : "value5" }
{ "index" : {}}
{ "field1" : "value6" }
```

Cool thing, the bulk results report is just JSON, you can easily throw it into an index and report on it:

```
POST bulk_results/_doc
{
  <bulk response here>
}
```

### Hardware settings to improve performance

#### Disable swapping

Swapping is very bad for performance, for node stability, and should be avoided at all costs

It can cause garbage collections to last for minutes instead of milliseconds and can cause nodes to respond slowly or even to
disconnect from the cluster

You should make sure that the operating system is not swapping out the java process by disabling swapping

Most operating systems try to use as much memory as possible for file system caches and eagerly swap out unused application memory

This can result in parts of the JVM heap or even its executable pages being swapped out to disk

3 way to achieve this:

1. Disable OS swap `sudo swapoff -a`, to make this persistent comment out swap in `/etc/fstab`
2. `mlockall` to try to lock the process address space into RAM, preventing any Elasticsearch memory from being swapped out. Test this `GET _nodes?filter_path==**.mlockall`. Set this in `config/elasticsearch.yml` with `"Bootstrap.memory_lock" : "true"`
3.

Quick paint a picture of health:

```
GET _cluster/health
GET _cluster/allocation/explain
```

#### Indexing Buffer size

If a node is doing only heavy indexing, be sure `indices.memory.index_buffer_size` is large enough to give at most **512MB** indexing buffer per shard doing heavy indexing

Beyond that indexing performance does not typically improve!

The default is `10%` which is often plenty: for example, if you give the JVM 10GB of memory, it will give 1GB to the index buffer, which is enough to host two shards that are heavily indexing

### Best practices and scaling

#### Disable replics for initial loads

If you have a large amount of data that you want to load all at once into Elasticsearch, it may be beneficial to set index.number_of_replicas to
0 in order to speed up indexing

Having no replicas means that losing a single node may incur data loss, so it is important that the data lives elsewhere so that this initial
load can be retried in case of an issue

Once the initial load is finished, you can set `index.number_of_replicas` back to greater than 0

#### Use auto-generated IDs

When indexing a document that has an explicit id, ES needs to check whether a document with the same id already exists within the same shard, which is a costly operation and gets even more costly as the index grows.

By using auto-generated ids, ES can skip this check, which makes indexing faster.

#### Use Cross Cluster Replication

Within a single cluster, indexing and searching can compete for resources.

By setting up two clusters, configuring cross-cluster replication to replicate data from one cluster to the other one, and routing all
searches to the cluster that has the follower indices, search activity will no longer steal resources from indexing on the cluster that hosts the
leader indices

### Thread Pools

Running out of worker/threads:

- Make sure to watch for a TOO_MANY_REQUEST (429) response code, which is the way that lasticsearch tells you that it cannot
  keep up with the current indexing rate
- When it happens, you should pause indexing a bit before trying again, ideally with exponential backof

### Memory Locking

### Transforms

Why use transforms?

- Transforms enable you to convert existing Elasticsearch indices into summarized indices
- You can use transforms to pivot your data into entity-centric indices
- You can find the latest document among all documents that have a certain unique key

## Tuning for search

### API settings and data modelling to improve search performance

#### Search as few fields as possible

The more fields a `query_string` or `multi_match` query targets, the slower it is.

A common technique to improve search speed over multiple fields is to copy their values into a single field at index time, and then use this field at search time.

```
PUT movies
{
  "mappings" : {
    "properties" : {
      "name_and_plot" : {
        "type" : "text"
      },
      "name" : {
        "type" : "text"
        "copy_to" : "name_and_plot"
      },
      "plot" : {
        "type" : "text"
        "copy_to" : "name_and_plot"
      }
    }
  }
}
```

#### One big copy_to field as opposed to individual text multi field

Clever way to cut down on the number of text fields.

#### Consider mapping identifiers as keywords

Elasticsearch optimizes numeric fields, such as `integer` or `long`, for range queries. However, `keyword` fields are better for term and other term-level queries.

Identifiers, such as an ISBN or a product ID, are rarely used in range queries. However, they are often retrieved using term-level queries. Making keyword more appropriate.

#### Document modeling

Documents should be modeled so that search-time operations are as cheap as possible

**Nested** can make queries several times slower

**Parent-Child** relations can make queries hundreds of times slower

If the same questions can be answered without **joins** by denormalizing documents, significant speedups can be expected

#### Consider mapping numeric fields as keyword

You don’t plan to search for the identifier data using range queries

Fast retrieval is important. term query searches on keyword fields are often faster than term searches on numeric fields

If you're unsure which to use, you can use a multi-field to map the data as both a keyword and a numeric data type

### Hardware settings to improve search

#### Warm Up Global Ordinals

[Global ordinals](https://www.elastic.co/guide/en/elasticsearch/reference/current/eager-global-ordinals.html) are a data-structure that is used in order to run terms aggregations on keyword fields

They are loaded lazily in memory because Elasticsearch does not know which fields will be used in terms aggregations and which fields won't.

If possible, identify early what keywords will be part of an aggregation, so elasticsearch does not have to guess.

#### Warm up filesystem Cache

If the machine running Elasticsearch is restarted, the filesystem cache will be empty, so it will take some time before the operating system loads hot regions of the index into memory so that search operations are fast.

You can explicitly tell the operating system which files should be loaded into memory eagerly depending on the file extension using the `index.store.preload` setting

#### Use index sorting to speed up search

By default Lucene does not apply any sort, its a scoring system. The `index.sort.*` settings define which fields should be used to sort the documents inside each segment.

Head ups: Can't be done for nested or parent child documents

```
PUT twitter
{
  "settings" : {
    "index" : {
      "sort.field" : "date",
      "sort.order" : "desc"
    }
  },
  "mappings": {
    "properties": {
      "date" : {
        "type" : "date"
      }
    }
  }
}
```

### Ways to improve searches

Cheatsheet:

- FILTERS!
- Denormalization
- Replicas
- CCR
- Transforms
- Ingest pipelines to fix data or do math

#### must and should clauses

`bool` queries allow for multiple clauses to fine tune your query
`must` clauses will calculate a score for documents that meet the query criteria
`should` clauses will impact the score, but generally do not change the hits

#### filter and must not clauses

#### node query cache

Results in the filter context are cached in the node query cache allows for very fast lookups of commonly-used filters

The cache holds up to 10,000 queries (or up to 10% of the heap) these defaults can be modified with the `indices.queries.cache.size` setting

#### shard request cache

Search results may be cached in the shard request cache only requests with `size=0` are cached, which makes it useful for aggregations

You do not have to do anything else special to use the cache

#### Aggregation performance

Improving aggregation performance often comes down to narrowing the scope of your search

1. Use a query
1. Use a sampler or diversified_sampler agg to filter out a sample of the top hits
1. Use a Kibana filter and runtime field with random values to filter out a random sampling of the hits

#### Search rounded dates

Queries on date fields that use the timepicker option of now are typically not cacheable since the range that is being matched changes all the time.

Switching to a rounded date is often acceptable in terms of user experience, and has the benefit of making better use of the query cache.

In that case we rounded to the minute

- if the current time is 16:31:29, the range query will match everything whose value of the my_date field is between 15:31:00 and 16:31:59
- if several users run a query that contains this range in the same minute, the query cache could help speed things up a bit

The longer the interval that is used for rounding, the more the query cache can help, but be beware that too aggressive rounding might also hurt UX.

#### Force merge read only indices

Indices that are read-only may benefit from being merged down to a single segment.

This is typically the case with time-based indices: only the index for the current time frame is getting new documents while older indices are read-only.

Shards that have been force-merged into a single segment can use simpler and more efficient data structures to perform searches.

## Search profiler and Explain API

### Search profiler

The Profile API gives the user insight into how search requests are executed at a low level so that the user can understand why certain requests are slow, and take steps to improve them.

The Profile API does NOT measure:

- Network latency
- Time spent in the search fetch phase
- Time spent while the request is in a queue
- Time spent merging shard responses on coordinating node

Any `_search` request can be profiled by adding `"profile" : true`

```
GET /my-index-000001/_search
{
  "profile": true,
  "query": {
    "match" : {"message" : "Elasticsearch Training"}
  }
}
```

#### Search profiler API ID

Because a search request may be executed against one or more shards in an index, and a search may cover one or more indices, the top level element in the profile response is an array of shard objects

The ID’s format is `[nodeID][indexName][shardID]`:

```
[2aE02wS1R8q_QFnYu6vDVQ][my-index-000001][0]
```

#### Query section

- `type`: Displays Lucene class name
- `description`: Displays the Lucene explanation
- `time_in_nanos`: field shows that this query took ~1.8ms
- `children`: List any sub-queries that may be present. Because we searched for two values (“Elasticsearch” “Training”) we have two children `TermQueries`

#### Timing breakdown

Timings are listed in wall-clock nanoseconds and are not normalized at all.

- `create_weight`: Lucene generates a Weight object which acts as a temporary context object to hold state
- `build_scorer`: How much time it takes to build a score for the query
- `next_doc`: The time it takes to determine which document is the next match

#### Collection section

Lucene works by defining a `Collector` which is responsible for coordinating the traversal, scoring, and collection of matching documents.

`SimpleTopScoreDocCollector` is the default scoring and sorting collector used by Elasticsearch.

#### Collectors reasons

The reason field attempts to give a plain English description of the class name. Here are a few collector reasons:

- Aggregation - A single aggregation collector is used to collect documents for All aggregations
- Global_Aggregation - A collector that executes an aggregation against the global query scope
- Search_Count - A collector that only counts the number of documents that match the query, but does not fetch the source. This is seen when size: 0 is specified

#### Rewrite section

All queries in Lucene undergo a "rewriting" process

A query (and its sub-queries) may be rewritten one or more times, and the process continues until the query stops changing

This process allows Lucene to perform optimizations, such as removing redundant clause, replacing one query for a more efficient execution path

### Explain and Tasks API

#### Explain API

The explain API computes a score explanation for a query and a specific document

This can give useful feedback whether a document matches or didn’t match a specific query

`GET /<index>/_explain/<id>` or tack `"explain"`: true` into the query DSL.

You might be thinking how does score affect performance. Well calculating score can people a fairly large performance cost for any query.

#### Score

TODO

#### Field length normalization and coordindation

TODO

#### Other Query Parameters

- Query normalization (queryNorm): Query normalization is used so that different queries can be compared
- Index Boost: This is a percentage or absolute number used to boost any field at index time
- Query Boost: This is a percentage or absolute number that can be used to boost any query clause at query time. Concretely `multi_match` and `should` boosting.

## API Settings to improve indexing performance

## Hardware settings to improve performance

## Best Practices and scaling

## Transforms

The ES equivalent of a materialized view in a relational DB.

Cool features:

- Can continuously sync the transform destination index from the source index, or just at the point in time it was run.
- Retension policy will automatically clean up the transform
- Theres a `stats` API for monitoring
- Optimize the frequency
-

Sometimes it's a good idea to keep your eye on long running task like transforms

- `GET _transform/<transform_id>/_stats`
- `GET _transform/_stats`
- `GET _transform/*/_stats`

this feels like the ES equivalent of a materialized view in a relational DB
