---
layout: post
title: "Black belt Elasticsearch"
date: "2019-03-27 08:44:10"
comments: false
categories:
- elastic
tags:
- elasticsearch
- elk
- logstash
---

Some more advanced Elasticsearch wisdom I gleaned from Jason Wong and Mark Laney from Elastic.


**Contents**

- [Environment with Config](#environment-with-config)
  - [X-Pack Security (the 1337 way)](#x-pack-security-the-1337-way)
    - [Roles](#roles)
    - [Built-in Query Web UI (batteries included)](#built-in-query-web-ui-batteries-included)
- [Internals](#internals)
  - [Lucene](#lucene)
  - [Segments](#segments)
  - [Elasticsearch Indexing](#elasticsearch-indexing)
    - [Transaction Log and Flushing](#transaction-log-and-flushing)
    - [Doc Values](#doc-values)
  - [Caching](#caching)
- [Field Modelling](#field-modelling)
  - [Typing](#typing)
  - [Denormalising](#denormalising)
  - [Range Types](#range-types)
  - [Mapping Parameters](#mapping-parameters)
- [Fixing Data](#fixing-data)
  - [Painless](#painless)
  - [Reindexing API's](#reindexing-apis)
  - [Picking up Mapping Changes](#picking-up-mapping-changes)
    - [Multi-fields](#multi-fields)
    - [Custom Marker (flag) Field](#custom-marker-flag-field)
  - [Fixing Fields](#fixing-fields)
- [Advanced Search and Aggregations](#advanced-search-and-aggregations)
  - [Patterns](#patterns)
    - [Wildcard Query](#wildcard-query)
    - [Regexp Qury](#regexp-qury)
    - [Null](#null)
    - [Script (painless) Query](#script-painless-query)
    - [Script Field](#script-field)
    - [Performance Considerations](#performance-considerations)
  - [Search Templates](#search-templates)
  - [Aggregations](#aggregations)
    - [Percentile](#percentile)
    - [Top Hits](#top-hits)
    - [Scripted (painless) Aggregations](#scripted-painless-aggregations)
    - [Significant Terms Aggregation](#significant-terms-aggregation)
    - [Pipeline Aggregations](#pipeline-aggregations)
- [Cluster Management](#cluster-management)
  - [Dedicated Nodes](#dedicated-nodes)
  - [Hot Warm Architecture](#hot-warm-architecture)
    - [Tags](#tags)
    - [Verify Shard Allocation](#verify-shard-allocation)
    - [Forced Awareness](#forced-awareness)
- [Capacity Planning](#capacity-planning)
  - [Shard Allocation](#shard-allocation)
    - [Litmus Test](#litmus-test)
    - [Primary Shards](#primary-shards)
    - [Scaling with Indices](#scaling-with-indices)
    - [Scaling with Replicas](#scaling-with-replicas)
    - [Resources](#resources)
  - [Time Based Data](#time-based-data)
    - [API's for Managing Indices](#apis-for-managing-indices)
- [Document Modelling](#document-modelling)
  - [Nested Objects](#nested-objects)
  - [Nested Aggregations](#nested-aggregations)
  - [Parent Child Relationships](#parent-child-relationships)
  - [Argh Which Technique is Best?](#argh-which-technique-is-best)
  - [Kibana Considerations](#kibana-considerations)
- [Monitoring](#monitoring)
  - [Task Management API](#task-management-api)
  - [The cat API](#the-cat-api)
  - [Performance Issues](#performance-issues)
    - [Thread Pool Queues](#thread-pool-queues)
    - [hot_threads API](#hotthreads-api)
    - [Indexing Slow Log](#indexing-slow-log)
    - [Search Slow Log](#search-slow-log)
    - [The Profile API](#the-profile-api)
  - [X-Pack Monitoring](#x-pack-monitoring)
    - [Alerting](#alerting)
- [From Dev to Production](#from-dev-to-production)
  - [Disabling Dynamic Indices](#disabling-dynamic-indices)
  - [Production Mode](#production-mode)
  - [Best Practices](#best-practices)
    - [Network Best Practices](#network-best-practices)
    - [Storage Best Practices](#storage-best-practices)
    - [Hardware Selection](#hardware-selection)
    - [Throttles](#throttles)
    - [JVM](#jvm)
  - [Poor Query Performance](#poor-query-performance)
    - [Always Filter](#always-filter)
    - [Aggregating Too Many Docs](#aggregating-too-many-docs)
    - [Denormalise First](#denormalise-first)
    - [Too many shards](#too-many-shards)
    - [Unnecessary Scripting](#unnecessary-scripting)
  - [Cross Cluster Replication](#cross-cluster-replication)
  - [Upgrades](#upgrades)
    - [Rolling Upgrade](#rolling-upgrade)




# Environment with Config

Can use environment variables within `elasticsearch.yml`:

    cluster.name: my_cluster
    node.name: ${NODENAME}
    network.host: _site_
    discovery.zen.ping.unicast.hosts: [ "server1", "server2", "server3" ]
    discovery.zen.minimum_master_nodes: 2
    xpack.security.enabled: true

This is particularly useful for running within Docker containers.


## X-Pack Security (the 1337 way)

Create user on CLI:

    /home/elastic/elasticsearch/bin/elasticsearch-users useradd training -p my_password -r superuser


Enable the X-Pack:

    curl -i -XPOST "http://${HOSTNAME}:9200/_xpack/license/start_trial?acknowledge=true"


### Roles

Using the `_xpack/security/role` API:

    POST _xpack/security/role/blogs_readonly
    {
      "indices": [
        {
          "names": ["blogs*"],
          "privileges": ["read", "read_cross_cluster", "view_index_metadata", "monitor"]
        }
      ]
    }


### Built-in Query Web UI (batteries included)

Cool tip, if you just hit the TLS port (443), Elasticsearch will provide a neat little web UI.




# Internals


## Lucene

Lucene is the underpinning engine, Elasticsearch sits on.

* Shard hashing is in essence `hash('511') % 5` (specifically using the *murmur3* algorithm).
* A shard is actually a complete Lucene instance, therefore a complete search engine. Elasticsearch abstracts Lucence indexes behind the index concept.
* 10% of the JVM heap is allocated for buffering data between the client and shards.
* When a buffer is full, they are flushed into a *segment* within the *shard*. Because of this, Elasticsearch is a near real-time, not actual real-time. By default the `refresh_interval` is 1 second, which is the buffer/flush cycle.
* Buffer size can be changed with the `indices.memory.index_buffer_size: 5%` setting.
* For heavy data loads, index performance can be improved by reducing the `refresh_interval`. This will drop number of writes (I/O) that will occur on the backing segment, for a specific index.
* A `refresh` query string param can be provided to the REST API, to force a segemnt refresh (`true`), or turned into a synchronous call (`wait_for`).

Updating the refresh interval:

    PUT fooindex/_settings
    {
      "refresh_interval": "30s"
    }



## Segments

* A *shard* is a Lucene index, which is a big bag of segments.
* They are immutable.
* Contain many data structures relating to the inverted index. Containing the term, its frequency and the document ID's it occurs in. A list of fields in the index. A term proximity table, which defines where in the field a term occurs (each term is represented by an index), this is very useful for *phrase* matching. Stored field values. [BKD](https://en.wikipedia.org/wiki/K-D-B-tree) (k-dimensional b-tree) used for numerics. Normalization factors for managing things like boosting. *doc_values* for representing keywords.
* The number of segments can impact I/O performance.
* Segment merging is the act of compacting and defraging segemnts within a shard. This can be forced with the `_forcemerge` API, such as `POST fooindex/_forcemerge`. Segment compaction can in turn be forced `POST fooindex/_forcemerge?max_num_segments=1`.


Shards live under the data path, for example `/home/elastic/elasticsearch/data/nodes/0/indices/1CcmiyKvTYK0FMjZk80QKg/1/index`.


    GET _cat/indices/my_refresh_test?v
    health status index           uuid                   pri rep docs.count docs.deleted store.size pri.store.size
    green  open   my_refresh_test 9EpRLCP3QHGnjHbFST2lcg   3   0          0            0       690b           690b

That means that the 9EpRLCP3QHGnjHbFST2lcg folder contains the data from my_refresh_data that is allocated to node1. This same folder exists in the other nodes of your cluster.

`cd` into this dirctory, e.g. `cd /home/elastic/elasticsearch/data/nodes/0/indices/9EpRLCP3QHGnjHbFST2lcg`, and list it:

    $ ls -l                                                            
    total 8                                                                                                    
    drwxrwxr-x 5 elastic elastic 4096 Mar 27 00:13 2                                                           
    drwxrwxr-x 2 elastic elastic 4096 Mar 27 00:13 _state


You will see a folder for each shard that is allocated to this node. For example, the following output shows that shard 0 is on node1 (because there is a folder named 0):

This can be verified by checking shard allocation using the *cat* API like this `GET _cat/shards/my_refresh_test?s=node`

    $ cd 2                                                             
    [elastic@server1 2]$ ls                                                                                    
    index  _state  translog 

Hot tip: Document 1 is returned. By default, the GET API is realtime, and is not affected by the refresh rate of the index (when data will become visible for search).

    $ ls                                                                                
    _0.fdt  _0.fdx  segments_3  write.lock








## Elasticsearch Indexing

### Transaction Log and Flushing

Elasticsearch provides a transaction log, on top of the Lucene segment. It lives between the buffer and the segment.

* Is flushed to disk after each write request.

A flush can be forced:

    POST fooindex/_flush

A synched flush, a normal flush plus a unique checkpoint marker that is replicated across all shards.

    POST fooindex/_flush/synced



### Doc Values

It makes no sense to sort a text field. For example:

* i like es => i, like, es
* I LIKES ES => i, like, es

After analysis and tokenizing, and put on the inverted index, the original values (casing, stemming, etc) are lost (losy).

This is solved by using `fielddata`.

A *doc value* on the other hand are an on-disk columnar based representation. They are FAST, because only the specific fields (columns, unlke a complete tuple in a relational system) are loaded into memory (like a hash) for lookup.


## Caching

* One *node level cache* per node is provided. 10% of the JVM heap is allocated, and a LRU eviction policy is used by default.
* Size can be changed `indices.queries.cache.size: "5%"`
* Segement level cache uses bit sets, which can significantly optimise *filter context* clauses (which are either true or false).
* In addition to the *node level cache*, a *shard request cache* is provided. This is basically like caching the responses on a web server.








# Field Modelling

## Typing

Automatic inference


## Denormalising

Granular field modelling (aka denormalising). For example, don't just store a version number, but perhaps its semver components too:

    PUT blogs
    {
      "mappings": {
        "_doc": {
          "properties": {
            "version": {
              "properties": {
                "display_name": {
                  "type": "keyword"
                },
                    "major": {
                  "type": "byte"
                },
                "minor": {
                  "type": "byte"
                },
                "bugfix": {
                  "type": "byte"
                }
              }
            }
          }



## Range Types

This is cool, you could represent a period (time span) of time, using the `gte` and `lte` type syntax.

Types of range queries:

* if rangees touch (relation: intersects)
* if it contains
* if its within



## Mapping Parameters

Can specify that fields are not searchable `"index": false`

Or not searchable or aggregated, by `"enabled": false`

Disabled *doc values*, `"doc_values": false` (needed for sorting and aggregation).

Disabling an object cascades down it all child ojbects, that may be nested.

Disabling `_all`, is a special (meta) concatenation of all the fields as *one gorilla string*.

The `copy_to` allows for multiple fields to be tipped into a single convenience field, such as `locations_combined`.

`null` values and handled suprisingly in aggregations. An average will completely exclude document, where their field of concern is set to `null`. A `null_value` setting in the mapping is available to set a default value if `null`.

Coercing (casting) data. The default mappings will type based on its best guess (e.g. long, text, date). If a type `"coerce": false"

The `__meta` field are super handy key/value bag for storing information about the index.

Dynamic templates, is a hook on a field mapping that allow you to evaluate a type and convert it into another type (e.g. long => text, keyword => text, date => text). You can also apply types based on the field name e.g. field that start with f:

    f*

The strictness of the dynamic template can be relaxed.








# Fixing Data

Elastic provides a custom scripting lang called *painless*. Is a small, fast subset of the Java API.


## Painless

Painless use-cases:

* Field level manipulation. Like updating/deleting a field. Field level computation.
* Running an ETL script on an ingest node.
* With the reindex API, for mold data as part of a reindex.


Two ways to run a painless script:

* Inline, e.g. via the update API `POST fooindex/_doc/1/_update { "script": { ...`
* Stored, done via the `_scripts` API, and referencing it downstream API's like `_update`.


Accessing data:

* Ingest node `ctx.field_name`
* Updates `ctx._source.fieldname`
* Search and aggregations, `doc['fieldname'].value`. Doc fields are very effcient to access (due to in memory hash columnar format in which it is stored within the heap).


General painless tips:

* They are compiled on the fly, and can be expensive. Capped at 75 compilations per 5 minute window. Tweakable by `script.max_compilations_rate`
* Support a bind variable type concept, to avoid recompilation due to parameter differences in scripts.
* In painless, the `ctx.index` (meta field) can be set to distribute the document across shards, in a more controlled manner.
* Triple quotes in JSON, allow you to have multiline painless script.
* If you want to return all the original document fields, include a `"_source": []` setting in the query, along with the `script_fields`


## Reindexing API's

When reindex be careful about setting level configuration (such as shards) and mappings. These are immutable and can't be changed.

Types:

* `_reindex` is for reindexing on index to another.
* `_update_by_query` is for reindexing into the same index. Cool!
* `_delete_by_index` will garbage collect documents that match a search criteria.


Reindexing tips:

* Source to destination versioning. By default `version_type` is `internal`, which will overrides documents in the destination. 
* A `version_type` of `external`, later versions in the source will override older versions in the destination. External mode will actual fail (exception) the reindex if an older version in the source is detected. To have it continue, the `"conflicts": "proceed"` setting should be set.
* This is a parameter that can be specified in the destination chunk of the `_reindex` request.
* To only have new creation flow through through set the `"op_type": "create"`





## Picking up Mapping Changes

### Multi-fields

Elastic knows that the fields are related, and will maintain multi-fields when the `_update_by_query` is used.

TODO: snippet P157



### Custom Marker (flag) Field

TODO: P.160



## Fixing Fields

If you had a value `"locales": "de-de,fr-fr"` that you want to split apart into an array.

An ingest pipeline, is like a logstash ETL pipeline. They are defined using the `_ingest` API.

TODO: P168 snippet

Tip the `on_failure` handler in a pipeline, you can push documents that fail to like dead letter type index, for later analysis.

Testing pipelines, the `_ingest` API provides a `_simulate` operation, where you can throw an inline document set in the request for testing.


The Bulk API, supports a `pipeline` parameter, so that you can wash your documents through these ingest pipelines.

A default pipline can be defined on the index `settings`, to avoid specifying it.



Processors:

* `set`, just setting a string literal to a field
* `split`, for splitting a string into an array
* `script` for running a painless script (TODO P.174 snippet)
*

There are [tons more](https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest-processors.html).

Pro tip: master nodes are by default ingest nodes, be careful you don't kill your master nodes, if you start putting heavy load on ingest nodes.




# Advanced Search and Aggregations


## Patterns


### Wildcard Query

Globing patterns.

    GET blogs/_search
    {
      "query": {
        "wildcard": {
          "title.keyword": {
            "value": "* 5.*"
          }
        }
      }
    }


### Regexp Qury

Awesome! Expensive though.

    GET blogs/_search
    {
      "query": {
        "regexp": {
          "title.keyword": """.*5\.[0-2]\.[0-9].*"""
        }
      }
    }


### Null

Can check for the presence of a value (or not in a `must_not`):

    GET blogs/_search
    {
      "query": {
        "exists": {
          "field": "locales"
        }
      }
    }



### Script (painless) Query

Run some painless script in a query:

    GET blogs_fixed/_search
    {
      "query": {
        "bool": {
          "filter": {
            "script": {
              "script": {
                "source": "doc['locales'].size() > 1"
              }
            }
          }
        }
      }
    }


### Script Field

Is a dynamic field defined by a piece of painless. Just like SQL allows you make small calculations on the fly.

    GET blogs_fixed/_search
    {
      "script_fields": {
        "day_of_week": {
          "script": {
            "source": "def d = new Date(doc['publish_date'].value.millis);\nreturn d.toString().substring(0,3);"
          }
        }
      }
    }



### Performance Considerations

Calculating fields at query time is a smell.

Consider:

* Ingest pipelining
* Logstash




## Search Templates

Reusable search templates. Not painless, but mustasche based.

Defined using the `_script` API, like this:

    POST _scripts/my_search_template
    {
      "script": {
        "lang": "mustache",
        "source": {
          "query": {
            "match": {
              "{{my_field}}": "{{my_value}}"
            }
          }
        }
      }
    }


And used like this:

    GET blogs/_search/template
    {
      "id": "my_search_template",
      "params": {
        "my_field": "title",
        "my_value": "shard"
      }
    }

Mustache can do basic flow control, like conditionals.

{% raw %}
    POST _scripts/blogs_with_date_search
    {
      "script": {
        "lang": "mustache",
        "source": """
        {
          "query": {
            "bool": {
              "must": {
                "match": { "content": "{{search_term}}" }
              }
              {{#search_date}}
              ,
              "filter": {
                "range": {
                  "publish_date": { "gte": "{{search_date}}" }
                }
              }
              {{/search_date}}
            }
          }
        }
        """
      }
    }
{% endraw %}


Unit testing search templates:

    GET blogs_fixed/_search/template
    {
      "id": "blogs_with_date_search",
      "params": {
        "search_term": "shay banon"
      }
    }



## Aggregations


Pro tip: set the `"size": 0` to avoid using the doc.

Pro tip 2: aggregations only work with keywords.



### Percentile

Bucketing into deviation.

    GET logs_server*/_search
    {
      "size": 0,
      "aggs": {
        "runtime_percentiles": {
          "percentiles": {
            "field": "runtime_ms"
          }
        }
      }
    }


### Top Hits

Also a sample set size, specified by the `top_hits` setting in an aggregate query.



### Scripted (painless) Aggregations

Allows the bucketing term to be defined as the result of some painless script.

    GET blogs/_search
    {
      "size": 0,
      "aggs": {
        "blogs_by_day_of_week": {
          "terms": {
            "script": {
              "source": "doc['publish_date'].value.dayOfWeek"
            }
          }
        }
      }
    }


### Significant Terms Aggregation

Samples a subset of the dataset, known as the foreground group where there is a population density pattern in the data, for example how many people in the general public know about google, vs how many people in the general public know about lucene, vs how many developers in the Elastic training know about lucene. The Elastic developers group has an unusual density of familiarity with lucene, than the general public.


To use simply change `terms` in an aggregation to `significant_terms`. Example, shows a blog author that has unique significant terms, specific to their writing (no common terms like the, and, or).



### Pipeline Aggregations

Allow you to perform calculations on prior aggregation calculations. The `buckets_path` 






# Cluster Management

## Dedicated Nodes

Roles:

* `node.master` master eligible
* `node.data` data node
* `node.ingest` ingest node

When the above are all set to `false`, it takes on the coordinator (coordinating) only role.




## Hot Warm Architecture

Splitting reads and writes. Very valuable for time based indices.

Data nodes can be setup to use a hot/warm architecture.

* Useful for splitting reads/write, spread indexing work, and querying work
* Hot nodes, for supporting the indices with new documents.
* Warm nodes, for handling read-only data.
* Uses shard filtering to make this happen, by tagging which nodes, and which indicies,  are which.
  * Use the `node.attr` to tag either an an `-E` or elasticsearch.yml`, e.g. `node.attr.my_temp: hot`
  * Use `index.routing.allocation` to assign indexes to nodes.



### Tags

To assign tags to the index:

    PUT logs-2017-03
    {
      "settings": {
        "index.routing.allocation.require.my_temp" : "hot"
      }
    }

When you're ready to move those shards to the cheaper warm hardware:

    PUT logs-2017-02/_settings
    {
      "index.routing.allocation.require.my_temp" : "warm"
    }

To review index level tags `GET logs_server1/_settings`.


These tags are arbitary, you could for example include a sizing tag on the node:

    node.attr.my_server: medium


To list nodes, and the tags on the nodes:

    GET _cat/nodes?v

Results:

    ip         heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
    172.18.0.6           38          98   2    0.34    1.12     0.64 d         -      node5
    172.18.0.3           32          98   2    0.34    1.12     0.64 di        -      node2
    172.18.0.5           44          98   2    0.34    1.12     0.64 di        -      node4
    172.18.0.4           34          98   2    0.34    1.12     0.64 d         -      node3
    172.18.0.2           28          98   2    0.34    1.12     0.64 m         *      node1

And to get the tags on these nodes `GET _cat/nodeattrs?v`:

    node  host       ip         attr              value
    node5 172.18.0.6 172.18.0.6 ml.machine_memory 8369913856
    node5 172.18.0.6 172.18.0.6 ml.max_open_jobs  20
    node5 172.18.0.6 172.18.0.6 xpack.installed   true
    node5 172.18.0.6 172.18.0.6 ml.enabled        true
    node5 172.18.0.6 172.18.0.6 my_rack           rack2
    node5 172.18.0.6 172.18.0.6 my_temp           warm
    node2 172.18.0.3 172.18.0.3 ml.machine_memory 8369913856
    node2 172.18.0.3 172.18.0.3 ml.max_open_jobs  20
    node2 172.18.0.3 172.18.0.3 xpack.installed   true
    node2 172.18.0.3 172.18.0.3 ml.enabled        true
    node2 172.18.0.3 172.18.0.3 my_rack           rack1
    node2 172.18.0.3 172.18.0.3 my_temp           hot
    node4 172.18.0.5 172.18.0.5 ml.machine_memory 8369913856
    node4 172.18.0.5 172.18.0.5 ml.max_open_jobs  20
    node4 172.18.0.5 172.18.0.5 xpack.installed   true
    ...


Configure the indexes to use the hardware you need:

    PUT my_index2
    {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 1,
        "index.routing.allocation.include.my_server" : "medium,small",
        "index.routing.allocation.exclude.my_temp" : "hot"
      }
    }



### Verify Shard Allocation

Assignment to of indices to nodes and shards is verifiable by dumping the `_cat` shards meta:

    GET _cat/shards/logs_server*?v&h=index,shard,prirep,state,node&s=index,shard

Results in:

    index        shard prirep state   node
    logs_server1 0     p      STARTED node3
    logs_server1 0     r      STARTED node5
    logs_server1 1     r      STARTED node3
    logs_server1 1     p      STARTED node5
    logs_server1 2     r      STARTED node3
    logs_server1 2     p      STARTED node5
    logs_server1 3     p      STARTED node3
    logs_server1 3     r      STARTED node5
    logs_server1 4     r      STARTED node3
    logs_server1 4     p      STARTED node5
    logs_server2 0     r      STARTED node3
    logs_server2 0     p      STARTED node5
    logs_server2 1     p      STARTED node3






### Forced Awareness

You can instruct Elasticsearch not to create replica shards within a rack. Which may not make sense depending on the level of underpinning infra that is shared within a rack (e.g. network switches, drives, power).

    PUT _cluster/settings
    {
      "persistent": {
        "cluster": {
          "routing": {
            "allocation.awareness.attributes": "my_rack_id",
            "allocation.awareness.force.my_rack_id.values": "rack1,rack2"
          }
        }
      }
    }


If you configure shard filtering that is not achievable (i.e. missing node tags):

* Existing shards will stay put, and not be shuffled.
* New shards will never have anywhere to go (and result in a cluster red status)






# Capacity Planning

## Shard Allocation

Rules of thumb:

* A little overallocation, but not too much
* Should aim to hold 10-40GiB per shard
* Too many shards is very common across customers, due to the defaults of 5 shards per day, and not enough data in the existing shards.
* Capacity plan, 1GB per day, 6 month retention = 180GB.

Good questions to ask:

* How fast is data ingested
* How fast does querying need to be
* Hot vs warm data, hot shards might be more sutied to be smaller

### Litmus Test

Use a single node with a single shard and no replica, and test and measure.

Things to measure:

* Ingest rates
* Keep an eye out for an HTTP 429, when Elasticsearch is overwhelmed. Logstash and beats have back pressure mechanics to help with this. Alternately consider putting a queue (like rabbitmq or kafka) in front of Elasticsearch.
* Query performance


If you hit around 50GB, that is a sweet spot. You may want a little less depending on specifc use-case, 30GB might be the sweet spot if you are throwing lots of aggregate queries at your index, for example.


### Primary Shards

If your scenario is more ingest focused, more primary shards will help in this space. This is a tradeoff, because it will likely drop the shard sizes down from the target sweet spot.


### Scaling with Indices

This is a great way to influence the shard size.

Aliases make it possible to query across several indices.


### Scaling with Replicas

To boost read performance. The nice thing about replicas is that its a 


### Resources

[How many shards?](https://www.elastic.co/blog/how-many-shards-should-i-have-in-my-elasticsearch-cluster)


## Time Based Data

Only store a certain timeframe of documents into an index.

    PUT tweets-2017-02-05
    {
      "settings": {
        "number_of_shards": 4,
        "number_of_replicas": 1
      }
    }

Date math is supported for use in index names (it must be HTTP encoded):

    GET /<logstash-{now/d}>/_search

Must be represented as:

    GET /%3Clogstash-%7Bnow%2Fd%7D%3E/_search


### API's for Managing Indices

API's:

* `_reindex`
* `_shrink` to reduce the number of shards.
* `_split` to create more shards.
* `_rollover` which can split up an index based on time, number of docs, or even shard size!

Also checkout *frozen* indices, for data that can be archived (but easily restored).





# Document Modelling

Unlike for a relational database, where entities are modelled by normalising them. In Elasticsearch, its all about denormalising. This is good for performance, avoiding things like joins and row level locks.

To deal with joining entities together:

* *Denormalise*. Flatten everything, but leave fields you just don't need out. When denormalising there should always be a single authoritive source of the data. For example, storing the users twitter handle and age against their every tweet, there age will eventually become inaccurate. The individual user should be represented elsewhere (in another index), which could later be replicated out and updated into the tweets index.
* Application based joins, where the combinational logic resides in the consuming application logic.
* Nested objects, help deal with JSON array flatten that Lucene does under the hood. By defining a type of nested (`"type": "nested"`).
* Parent child relationship



## Nested Objects

Internally nested objects are stored as independent documents.

P.340

    PUT photos
    {
      "mappings": {
        "_doc": {
          "properties": {
            "filename": {
              "type": "keyword"
            },
            "tags": {
              "type": "nested",
              "properties": {
                "key": {
                  "type": "keyword"
                },
                "value": {
                  "type": "text"
                }
              }
            }
          }
        }
      }
    }

Use `inner_hits` to reveal which keys generated the hits.


## Nested Aggregations

Allows you to pour nested objects into a bucket.


    GET photos/_search
    {
      "size": 0,
      "aggs": {
        "my_tags": {
          "nested": {
            "path": "tags"
          }
        }
      }
    }

Results:

    "aggregations": {
      "my_tags": {
        "doc_count": 4
      }
    }


## Parent Child Relationships

Can connect related documents together, but they must exist within the same shard, this must be defined as a query string param, `?routing=c1`

This applies for doing parent/child related operations, such as deletes, updates and aggregates. Elasticsearch will simply not return any results if you forget to provide a routing key (as a query string param).


1. Mapping. Add a `_doc` mapping type of `join`, which defines a `relations`, with the parent first, and the child second. Must be a one to many relationship type (many to many not possible). For example, company could be a parent, with employee as the child.
2. Index parent docs
3. Index child docs
4. Query docs


From the parent (such as a company search), you can refer to child level fields by using the `has_child` query type.

This will return the parents (e.g. companies) that match. Make sure to include `"inner_hits": {}` to retreive child related documents (e.g. employees) that caused the parent hits (e.g. companies).

The inverse is provided for querying from the perspective of the child, using the `has_parent` query type, along with `inner_hits`.

Parent/child notes:

* Deleting a child document does not impact the parent (they are their own independent documents)
* They are very slow
* They are scoped to a specific shard.
* Generally to be avoided.



## Argh Which Technique is Best?

TODO: Include image on P.367 (decision graph to select the best techniuqe)

## Kibana Considerations

Kibana has very limited support for both *nested types* and *parent/child relationships*.

Options:

* Get the data out, and data visualisation.
* Vaga, a Kibana plugin. A D3.js plugin.





# Monitoring

Several API are provided:

* Node level, `_nodes/stats`. Nodes roles, tags (attributes), network configuration (transport and host addresses)
* Cluster level, `_cluster/stats`, and for pending tasks `_cluster/pending_tasks`
* Index level, `fooindex/_stats`, number of docs, the physical size of the index across all shards
* Pending tasks API, is valuable, this should generally return on empty task array. If not, can drill into specific tasks using the `_tasks` API. Each task include the UUID of the node, the action (e.g. monitoring), run time in nano's, if it was spawned from a parent task (important if killing).



## Task Management API

Allows to dig into running tasks:

    GET _tasks


## The cat API

Was created to provide a human readable tabular output, which actually is just a wrapper around the core JSON API's.

Some (optional) cat API parameters:

* Including headers, by adding the verbose param `?v` will add column headers to the tabular output.
* Only include particular columns (`SELECT`), the `?h` query string param allow you to filter on what columns you are interested in (like `SELECT` in SQL)
* Sorting `?s=index:desc`
* Filtering the records returned (`WHERE` clause) `?index=logs*`


Kill a task:

    POST _tasks/taskid/_cancel




## Performance Issues

### Thread Pool Queues

Thread pools are used to hadnle cluster tasks (bulk, index, get, search).

Thread pools are fronted by queues, when full, a HTTP 429 is returned.

    GET _nodex/thread_pool


    GET _nodes/stats/thread_pool

Example:

    "write": {
      "threads": 8,
      "queue": 0,
      "active": 0,
      "rejected": 0,
      "largest": 8,
      "completed": 177
    }


The `cat` API can be used to keep an eye on thread pools `GET _cat/thread_pool?v`:

    node_name name                active queue rejected
    node5     analyze                  0     0        0
    node5     ccr                      0     0        0
    node5     fetch_shard_started      0     0        0
    node5     fetch_shard_store        0     0        0
    node5     flush                    0     0        0
    ...


### hot_threads API

What are the nodes busiest doing:

    GET _nodes/hot_threads


Or a specific node:

    GET _nodes/node123/hot_threads



### Indexing Slow Log

Can log information about long running index operations. Various log4j thresholds can be mapped to index timings on the index specific `_settings`. Log file on disk is configured in the `log4j2.properties`.


### Search Slow Log

Very similar, index specifc setting using `index.search.slowlog`, threadholds of millis would make more sense here.


### The Profile API

Awesome feature! Just pass a `"profile": true` along with your search request.

Make sure to use the Kibana *Search Profiler* functionality (which sits next to the *Dev Console*).

You can dump the profiler results, and simply plug it into the *Search Profiler*. These are JSON, so can be easily stored, and analysed offline at a later stage, or even offsite.



## X-Pack Monitoring

Adds awesome functionality, which is surfaced through Kibana, and API's.

Best practices:

* Don't running monitoring on the production cluster. Use a dedicated monitoring cluster.


Basic configuration:

* `xpack.monitoring.collection.indices` defaults to all indices, but you can focus the monitoring to specific indices.
* `xpack.monitoring.collection.interval` how often samples are collected
* `xpack.monitoring.history.duration` how many days the logs will stick around


Cool monitoring tips:

* Keep an eye on segment count (within the shards), which should be fairly stable, if no indexing work is occuring.
* Indexing rate, total rate includes replica activity (if `replicas` is set to 1, then roughly double the primary replica work will occur).
* 


### Alerting

Like a watchdog. Can react to changes or anomalies. Such as:

* Running out of storage
* Malicious network activity
* If a node leaves the cluster

A watch is made up of five pieces:

* Trigger, typically a `schedule`
* Input
* Condition
* Transform
* Actions

They are stored in Elasticsearch you can reach them with a `GET .watches/_doc/log_error_watch` or `GET .watches/_search`.


Secured by two roles:

* `watcher_admin`
* `watcher_user`


Under Kibana, watcher is available under management (this is an X-Pack only feature).




# From Dev to Production

## Disabling Dynamic Indices

OOTB Elasticsearch will just create an index, if a request to index on it comes in. In production, this is probably an error or undesirable, and can be disbled.

TODO: P431


## Production Mode

Production mode, ensure that a minimum baseline of resources is available to ensure it runs well, when it is bootstrapped.

This mode kicks in whenever you change the `transport.bind_host`, transition the node to *production mode*.

Some of the checks:

* JVM checks: heap size, disabled swapping, no using a serial GC collector
* OS specific checks: map count, virtual memory, file description (1024), syscall filter


## Best Practices

### Network Best Practices

* No WAN links between nodes. Aim for zero hops between nodes. Cross Cluster Search (CCS) or Cross Cluster Replication (CCR) are much better options.
* Use long-lived HTTP connections
* Reverse proxy?


### Storage Best Practices

* Prefer SSD's.
* Local disks better than SAN.
* Cut redundant storage (such as RAID), its not necessary. Redundancy is already built-in with the replica concept.
* RAID0 (striping) is good.
* `path.data` allow an index to be distributed your index across multiple SSD's.
* Use `noop` or deadline scheduler in the OS when using SSD `echo noop > /sys/block/{DEVICE}/queue/scheduler`
* If using SATA disks, disable concurrent merges `index.merge.scheduler.max_thread_count: 1`
* Trim you SSD's [TODO link to is-your-elastsearch-trimmed](#)
* Don't be scared to disable swap. If a node does end up needing to use swap (virtual memory) is going to be useless anyway, and delay finding the underlying problem.


### Hardware Selection

Medium boxes over big boxes. P442.


### Throttles

Relocation and Recovery throttles ensure that the recovery and relocation of nodes, is capped at 2 nodes at a time, which is conservative.

    "cluster.routing.allocation.node_concurrent_recoveries": 2

And for relocation:

    "cluster.routing.allocation.cluster_concurrent_rebalance": 2


### JVM

Controlled by `jvm.options` or the `ES_JAVA_OPTS` CLI argument.

    -Xms30g
    -Xmx30g

By default the JVM heap is set to 1GB.

General production rule of thumb is half the system available memory, but never over 30GB. Half the available system memory, as Lucene (the shards) need the remaining resources. Due to a limitation *compressed ordinary object pointers* limit.

TODO: Link blog called a-heap-of-trouble

JDK set to server mode, not client mode.

Configure JVM to disable swapping. P449




## Poor Query Performance


### Always Filter

Benefits from:

* Not scoring
* The *filter cache* (bit sets). 


### Aggregating Too Many Docs

Always consider pairing an aggregation with a query to trim the result set the aggregation is applied to.

Use a filter bucket! Allows a filter to be bolted into an aggregate. This could be in turned paired with an outer query.

A *Sampler Aggregation* can be used to cut off the noisy tail (think bell curve tail) of a large data set.



### Denormalise First




### Too many shards



### Unnecessary Scripting

Avoid running calculations at query time, and instead stored the calculation at index time perhaps using an ingest pipeline.



## Cross Cluster Replication

Powerful cross cluster WAN (low latency) solution, by using the `cluster.remote` setting.

Queries can then have cluster targets included by prefix the index name with the cluster name (e.g. `GET blogs,germany_cluster:blogs/_search`)

Both the cluster name and index name portions can be wildcard'ed.




## Upgrades

### Rolling Upgrade

Where indices are compatible between releases.

Always start with master nodes.

1. stop indexing work
1. disable shard allocation
1. stop and upgrade one node at a time
1. start the node
1. re-enable shard allocation
1. repeat from step 2 for next node


    PUT _cluster/settings
    {
      "transient": {
        "cluster.routing.allocation.enable" : "none"
      }
    }

    POST _flush/synced 


