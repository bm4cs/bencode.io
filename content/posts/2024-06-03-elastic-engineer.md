---
layout: post
draft: false
title: "Elasticsearch Engineer 8.1"
slug: "eseng8"
date: "2024-06-02 18:46:01"
lastmod: "2024-06-03 10:15:30"
comments: false
categories:
  - elastic
tags:
  - elasticsearch
  - logstash
  - kibana
---

Revised 2024 edition based on Elasticsearch 8.1.

Recently the opportunity to attend the latest revision of the 4-day Elasticsearch engineer course, which I did in-person about 5 years ago in Sydney. Elasticsearch has often been an integral part of the data solutions I've been involved with and I'm quite fond of it. This time round the course only runs in a virtual class room format (using strigo.io) with our awesome trainers Krishna Shah and Kiju Kim.

**Contents**

- [Cool things I took away](#cool-things-i-took-away)
- [Getting started](#getting-started)
  - [Types of nodes](#types-of-nodes)
  - [Time Series vs Static Data](#time-series-vs-static-data)
  - [Installation](#installation)
  - [Starting and Stopping Elasticsearch](#starting-and-stopping-elasticsearch)
  - [Network communication](#network-communication)
    - [Discovery module (networking)](#discovery-module-networking)
  - [Network security](#network-security)
  - [Read-only cluster](#read-only-cluster)
  - [Data-in (writing)](#data-in-writing)
  - [Querying (reading)](#querying-reading)
    - [Fundamental search theory](#fundamental-search-theory)
    - [SQL](#sql)
- [Data Modelling](#data-modelling)
  - [Mappings](#mappings)
    - [Mapping parameters](#mapping-parameters)
    - [Dynamic templates](#dynamic-templates)
  - [Inverted Index](#inverted-index)
  - [Multi Fields (keyword fields)](#multi-fields-keyword-fields)
  - [Text Analyzers](#text-analyzers)
    - [Custom Analyzers and Token Filters](#custom-analyzers-and-token-filters)
    - [Java stable plugin API](#java-stable-plugin-api)
  - [Dynamic templates](#dynamic-templates-1)
- [You know, for search](#you-know-for-search)
  - [Query DSL](#query-dsl)
    - [match](#match)
    - [minimum_should_match](#minimum_should_match)
    - [match_phrase](#match_phrase)
    - [sort, from and size](#sort-from-and-size)
    - [fields](#fields)
    - [Trimming the fat on \_source](#trimming-the-fat-on-_source)
    - [range and date math](#range-and-date-math)
    - [multi_match](#multi_match)
    - [Compound queries with bool](#compound-queries-with-bool)
  - [Query and Filter Contexts](#query-and-filter-contexts)
  - [Search templates](#search-templates)
  - [Async search](#async-search)
- [Data Processing](#data-processing)
  - [Changing Data](#changing-data)
    - [Processors](#processors)
    - [Ingest pipelines](#ingest-pipelines)
    - [reindex API](#reindex-api)
    - [Update by Query API](#update-by-query-api)
    - [Delete by Query API](#delete-by-query-api)
  - [Enriching Data](#enriching-data)
    - [Denormalizing your data with enrichments](#denormalizing-your-data-with-enrichments)
  - [Scripting](#scripting)
    - [Painless](#painless)
    - [Runtime fields](#runtime-fields)
    - [Changing mappings at query time](#changing-mappings-at-query-time)
- [Aggregations](#aggregations)
  - [metric](#metric)
    - [cardinality](#cardinality)
    - [min](#min)
    - [stats](#stats)
    - [percentile_ranks](#percentile_ranks)
    - [top_hits](#top_hits)
  - [term (bucket)](#term-bucket)
  - [significant_terms and significant_text](#significant_terms-and-significant_text)
  - [Pipeline aggregations](#pipeline-aggregations)
    - [moving_aggs](#moving_aggs)
  - [Scripted (painless) aggregations](#scripted-painless-aggregations)
  - [Aggregation essentials](#aggregation-essentials)
    - [Reducing aggregation by combining with query](#reducing-aggregation-by-combining-with-query)
    - [Multiple aggregation in a single request](#multiple-aggregation-in-a-single-request)
    - [Sub buckets](#sub-buckets)
    - [Sub aggregations](#sub-aggregations)
    - [Sorting by a metric](#sorting-by-a-metric)
  - [Transforms](#transforms)
- [The one about shards](#the-one-about-shards)
  - [Primary and replica shards](#primary-and-replica-shards)
  - [Shard tips](#shard-tips)
    - [Scaling for reads](#scaling-for-reads)
    - [Scaling for writes](#scaling-for-writes)
  - [The lifecycle of a document index request](#the-lifecycle-of-a-document-index-request)
    - [Cluster and Shard Health](#cluster-and-shard-health)
- [Data management](#data-management)
  - [Index aliases](#index-aliases)
  - [Index Templates](#index-templates)
    - [Resolving template match conflicts](#resolving-template-match-conflicts)
  - [Index rollover](#index-rollover)
  - [Data streams](#data-streams)
    - [Data stream naming conventions](#data-stream-naming-conventions)
    - [Creating a data stream](#creating-a-data-stream)
    - [Changing a data stream](#changing-a-data-stream)
    - [Reindex a data stream](#reindex-a-data-stream)
  - [Data tiers](#data-tiers)
    - [Configuring an index to prefer a data tier](#configuring-an-index-to-prefer-a-data-tier)
  - [Index Lifecycle Management (ILM)](#index-lifecycle-management-ilm)
    - [Creating an ILM policy](#creating-an-ilm-policy)
    - [Applying an ILM policy to an index](#applying-an-ilm-policy-to-an-index)
    - [Monitor indices ILM lifecycle](#monitor-indices-ilm-lifecycle)
  - [Snapshots](#snapshots)
    - [Automating snapshots](#automating-snapshots)
    - [Restoring snapshots](#restoring-snapshots)
    - [Monitoring running snapshots:](#monitoring-running-snapshots)
    - [Searchable snapshots](#searchable-snapshots)
    - [Snapshot Lifecycle Management (SLM) policies](#snapshot-lifecycle-management-slm-policies)
  - [Multi-field Search](#multi-field-search)
  - [Boosting](#boosting)
  - [Fuzziness](#fuzziness)
  - [Exact Terms](#exact-terms)
  - [Sorting](#sorting)
  - [Paging](#paging)
  - [Highlighting](#highlighting)
- [Best Practices](#best-practices)
  - [Index Aliases](#index-aliases-1)
  - [Scroll Search](#scroll-search)
- [Cluster management](#cluster-management)
  - [Cross cluster replication](#cross-cluster-replication)
    - [Auto following](#auto-following)
  - [Cross cluster searching](#cross-cluster-searching)
  - [Configuration](#configuration)
  - [Troubleshooting](#troubleshooting)
    - [Cluster health](#cluster-health)
    - [CAT APIs](#cat-apis)
    - [Thread Pool Queues](#thread-pool-queues)
    - [Hot threads and tasks](#hot-threads-and-tasks)
    - [The Profile API](#the-profile-api)
  - [Monitoring](#monitoring)
  - [Optimizing search performance](#optimizing-search-performance)
    - [Unnecessary Scripting](#unnecessary-scripting)
    - [Search Slow Log](#search-slow-log)
    - [Indexing Slow Log](#indexing-slow-log)
    - [Always Filter](#always-filter)
    - [Aggregating Too Many Docs](#aggregating-too-many-docs)
    - [Denormalise First](#denormalise-first)
    - [Too many shards](#too-many-shards)
    - [Search profiler](#search-profiler)
    - [Relevance tuning](#relevance-tuning)
    - [Ways to improve searches](#ways-to-improve-searches)
- [Working examples](#working-examples)
  - [Index with custom analyzer, metadata and mappings](#index-with-custom-analyzer-metadata-and-mappings)

## Cool things I took away

- Benchmarking the `took` value in queries is a great way to baseline performance
- Kibana has a CSV or TSV or JSON uploader
- When querying, only pull back fields that you are interested (or not) in with the `_source` option, for example `"source": [ "excludes": "content" ]`
- To increase precision (and drop recall) include the `operator` option set to `and` (by deafult the `or` operator applies) e.g:
- When running aggregates `size` should be set to 0, if you don't need actual docs
- Language specific analyzers
- Phone number analyzer
- For fun, try to create a custom filter for handling Aussie names (baz to barry)
- Apply the ASCII folding and html_strip character filters to fields that can contain HTML content
- We shoudl define index templates, so custom analyzers can be shared
- OMG mapping parameters such as `doc_values`, `enabled`, etc are a must
- Lean into filter clauses more heavilty than must - better precision
- Always set size 0 for aggregation
- Search templates are great for reusable query definitions - thinking use cases of multiple divergent external consumers coming in at the data
- Transforms are a powerful way to pre-compute expensive aggregations
- Some sort of web socket based push notification when new data streams into the system
- Aim for shard sizes 20-40GB monitor and control this regularly
- Index `refresh_intervals` are a powerful way to batch up replica syncing work that needs to be done
- Checkout the tasks API for monitoring large ingestion jobs `POST _reindex?wait_for_completion=false`
- Check that field boosts are translating to a `multi_match`

## Getting started

### Types of nodes

An instance of Elasticsearch.

- Master: control plan nodes
- Ingest: dedicated for ingestion workloads
- Data: these can be tuned for host and warm nodes

- Master (low CPU, low RAM, low I/O), the control plane, manages the creation/deletion of indices, adding/deleting nodes, adding/deleting shards. By default all nodes are `node.master` enabled and are eligible for master. The number of votes needed to win an election is defined by `discovery.zen.minimum_master_nodes`. It should be set to `(N/2) + 1` where `N` is the number of master eligible nodes. Very important to configure to avoid split brain (possible multiple and inconistent master nodes). Recommendation is to have 3 master eligible nodes, with `minimum_master_nodes` set to 2.
- Data nodes (high CPU, high RAM, high I/O)
- Ingest (high CPU, medium RAM, low I/O), for providing simple ingest pipelines targetting at administrators (not comfortable with scripting or programming)
- Coordinating (high CPU, high RAM, low I/O), like a dating service, responsible for connecting nodes and roles. A smart load balancer.

Role assignment is managed in `elasticsearch.yml`:

- `node.master` to true (by default)
- `node.data` to true (by default)
- `node.ingest` to true (by default)

### Time Series vs Static Data

Data being tipped into Elasticsearch can usually be categorised as either static or time series.

- Static: large data sets, that change rarely over its lifetime (e.g. blogs, cataloges, tax returns)
- Time Series: event based data, that changes frequently over time (logs, metrics)

### Installation

Important directories to be mindful of:

- `ES_PATH_CONF` defines the root where all ES configuration lives. So its easy to setup portal configuration on new docker containers for example
- `modules` are _plugins_ that are core to running ES
- `plugins` useful extensions for ES

Always put configuration in the persistent config files such as `jvm.options`. While its possible (and convenient) to define these on the command line such as `-Xms512mb`, this is not designed for long term application.

Top configuration tips:

- Always change `path.data` (never use the local OS volume). Multiple paths are supported `path.data: [/home/elastic/data1,/home/elastic/data2]` all paths will be used.
- The `elasticsearch` binary supports a daemon mode with `-d`, and a `-p` for storing the current ES PID in a text file.
- Default configuration path can be tweaked using `ES_CONF_PATH`
- Set the `node.name` explicitly.
- Set the `cluster.name`
- Have explicit port numbers (when multiple nodes are spun up on a single machine port range 9200-9299 are used)

### Starting and Stopping Elasticsearch

```sh
kill `cat elastic.pid`
```

### Network communication

REST API interaction (port rnage 9200-9299)

Internode communication between nodes within the cluster (port range 9300-9399)

#### Discovery module (networking)

The default module is known as the _zen_ module. By default it will sniff the network for

    discovery.zen.ping.unicast.hosts : ["node1:9300", "node2"]

Network settings, there are 3 top level setting namespaces:

- `transport.*` transport protocol
- `http.*` controlling the HTTP/REST protocol
- `network.*` for defining settings across both the above

Sepcial values for network.host:

- `_local_` loopback
- `_site_` bind to the public network routable IP (e.g. 10.1.1.14)
- `_global_` any globally scoped address
- `_network-interface_` (e.g. `_eth0_` for binding to the addressable IP of a network device)

### Network security

Essential infrastructure:

- firewall
- reverse proxy
- elastic security

### Read-only cluster

Consider a _read-only_ cluster, for splitting out reads from writes. CCR (cross cluster replication) make this super handy pattern to roll out.

For locking down the REST API, the reverse proxy could lock down to only `GET` requests, for certain auth or IP's.

The same goes for Kibana. Providing read-only dashboards and visualisations.

### Data-in (writing)

Given ES is just a distributed document store, works with managing complex document structures. ES must be represented as JSON. Beat and Logstash are aimed at making this a smooth process.

- An _index_ can be related to a table in a relational store, and has a schema (a mapping type).
- ES will automatically infer the _mapping type_ (schema) for you, the first time you attempt to store a document.
- A _shard_ is one piece of an index (by default there are 5).
- By default, documents will automatically be overridden (version # incremented). If you don't wont auto overrides, use the `_create` API. Similarly there is an `_update` API.
- `DELETE`ing a document, space can be reclaimed.
- The `_bulk` API allows many operations to be loaded up together. One-line per operation (based on the JSON oneline standard), supported operations include create, index, update, and delete

The `POST` API will auto generate unique ID's:

```
POST hackers/_doc
{
    "name": "John Carmack",
    "city": "Texus"
}
```

The `PUT` API allows you to BYO an ID:

```
PUT hackers/_doc/1
{
    "name": "Dennis Ritchie",
    "city": "Virginia"
}
```

Bulk API allows multiple operations the be batched together:

```
POST comments/_bulk
{"index" : {}}
{"title": "Tuning Go Apps with Metricbeat", "category": "Engineering"}
{"index" : {"_id":"unique_doc_id"}}
{"title": "Searching for a needle", "category": "User Stories"}
{"create" : {"_id":"unique_doc_id"}}
{"title": "Searching for a needle in a haystack"}
{"update" : {"_id":"unique_doc_id"}}
{"doc": {"title": "Searching for a needle in a haystack"}}
{"delete": {"_id":"unique_doc_id"}}
```

### Querying (reading)

- To query something need to know the (1) cluster, (2) index, (3) mapping type and the (4) id of the specific document
- For simplistic queries KQL or Lucene queries allow you to articulate simple `field: value` filters
- To obtain multiple documents, the `_mget` API is provided.
- The query DSL is the most powerful and flexible option. The `_search` API exposes the ES searching functionality.
- Elasticsearch returns 10 hits by default
- A SQL parser is now provided!
- By default, the `match` query uses "or" logic if multiple terms appear in the search query

#### Fundamental search theory

- _Precision_ is the ratio of true positives vs the total number returned (true and false positives combined). Its tempting to constrain the net of results to improve precision. This is a tradeoff with recall which will drop.
- _Recall_ is the ratio of true positives vs the sum of all documents that should have been returned. By widening the net (by using partial matches).
- Scoring is done by 1950's technique known as TF/IDF.
  - TF (term frequency) the more a term exists the more relevant it is.
  - IDF (inverse document frequency) the more documents that contain the term the less relevant it is.
- [Okapi BM25](https://en.wikipedia.org/wiki/Okapi_BM25) is the 25th iteration of TF/IDF and is the default used by ES
- [Claude Shannon](https://en.wikipedia.org/wiki/Claude_Shannon) in 1925 discovered that information content = `log 2 * 1/P`, and this has been factored into BM25.

Two methods:

- _Query string_ can be encoded in the HTTP URL.
- _Query DSL_ a full blown JSON based DSL.
- When querying, only pull back fields that you are interested (or not) in with the `_source` option, for example `"source": [ "excludes": "content" ]`
- To increase precision (and drop recall) include the `operator` option set to `and` (by deafult the `or` operator applies) e.g:

Snippet:

    "query": "ingest nodes",
    "operator": "and"

- `minimum_should_match` instructs that a minimum number of search terms need to match.
- `match_phrase` specifies an exact match e.g. _a new way_ must include all terms in the specific sequence.
- If the search was _open data_ was searched the `slop` option can relax (or tighten) the search, by specifying hte number of terms that can exist between each search term

#### SQL

Example use of the SQL API:

```
POST /_sql?format=txt
{
  "query": "SELECT * FROM my_index"
}
```

## Data Modelling

### Mappings

Basically a per-index schema, with field level definitions such as data typing.

To view the mapping for an index via the API `GET fooindex/_mapping`.

Interesting traits of mappings:

- By default Elasticsearch will attempt to dynamic map document, but in practice this is rarely optimal e.g. will default integers to the `long` type
- Mappings cannot be changed after documents have been ingested on them, instead a new index and mapping should be defined and the documents reindexed into them

Some common [field data types](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html):

- `text`: Full text analyzed
- `keyword`: Raw text values (unaltered) useful for strings and aggregations
- `nested`: Useful parent child hierarchies
- `geo_point` and `geo_shape`: for geometric types
- `object`
- `percolator`: type, TODO investigate this.
- Be aware of the automatic inferred mappings that ES does, while convenient, typically makes a number of errors when typing fields.

To define mappings at index creation time:

```
PUT my_index
{
  "mappings": {
    define mappings here
  }
}
```

To add additional mappings:

```
PUT my_index/_mapping
{
  additional mappings here
}
```

An example `object` mapping (`properties` is one of the `object` types [supported properties](https://www.elastic.co/guide/en/elasticsearch/reference/current/object.html)):

```
PUT my-index-000001
{
  "mappings": {
    "properties": {
      "region": {
        "type": "keyword"
      },
      "manager": {
        "properties": {
          "age":  { "type": "integer" },
          "name": {
            "properties": {
              "first": { "type": "text" },
              "last":  { "type": "text" }
            }
          }
        }
      }
    }
  }
}
```

#### Mapping parameters

In addition to the type, fields in a mapping can be configured with additional parameters for example to set the analyzer for a text field:

An extensive list of [mapping parameters](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-params.html) are supported.

- `format`: hints the date formats to parse `"format" : "dd/MM/yyyy||epoch_millis"`
- `coerce`: by default type coersion is enabled (e.g. storing a `float` 4.5 into a `integer` field will cast to integer 4), this can be disabled with this property, documents will be rejected if their data doesn't fit
- `doc_values`: doc values are a data structure created implicitly during index time, they make aggregation and sorting possible
- `enabled`: for a fields stored in the `_source` document but not currently used at all
- `index`: by default a data structure that enables fast queries is built (inverted index for text and keyword) and BKD tree (geo and numeric), however this is not always useful and can be disabled, allowing for slower queries on it still
- `copy_to`: handy for combining multiple fields into a single field

Disabling doc values:

```
"url" : {
    "type": "keyword",
    "doc_values": false
}
```

To expose the `_source` document and a specific set of indexed fields:

```
GET ratings/_search
{
    "fields": [
        "rating"
    ]
}
```

`copy_to` in action:

```
"properties": {
    "region_name": {
        "type": "keyword",
        "index": "false",
        "copy_to": "locations_combined"
    },
    "country_name": {
        "type": "keyword",
        "index": "false",
        "copy_to": "locations_combined"
    },
    "city_name": {
        "type": "keyword",
        "index": "false",
        "copy_to": "locations_combined"
    },
    "locations_combined": {
        "type": "text"
    }
```

#### Dynamic templates

Manually defining a mapping can be tedious when you:

- have documents with a large number of fields
- or don't know the fields ahead of time
- or want to change the default mapping for certain field types

Use dynamic templates to define a field mappings based on one of the following:

- the field’s data type
- the name of the field
- the path to the field

### Inverted Index

Very similar to the index in the back of a book. Common terms, and where they are located in a convenient lookup structure. Lucene similarly creates this _inverted index_ with text fields.

- Text is broken apart (tokenised) into individual terms. These are converted to lower case, and special characters are stripped.
- Interestingly the search query is also tokenised by the analyzer in the same way.
- The inverted index is ordered. For search efficiency, allows algorithms like binary search to be used.
- Elasticsearch default analyzer does not apply stop words by default. This is also handled much better by BM25 now, than traditional TF/IDF.
- _Stemming_ words like "node" and "nodes" to return the same match. By default, Elasticsearch does not apply stemming. Some examples, configuring > configur, ingest > ingest, pipeline > pipelin

### Multi Fields (keyword fields)

- `text` fields are broken down into pieces, and are not appropriate for doing literal text comparisons. For example "I like Elasticsearch!" will strip the special characters, casing and the sequence of terms.
- Term aggregations on country

```
"comment": {
    "type": "text",
        "fields": {
            "keyword": {
                "type": "keyword",
                "ignore_above": 256
        }
    }
},
```

The above requires two inverted indexes. One for the text (tokens) and the keyword (the literal itself).

In the above comment example, when doing a match filter for example you can explicitly use the `keyword` field by searching only `comment.keyword`.

### Text Analyzers

An [analyzer](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-analyzers.html) is made up from these parts:

1. _Tokenizer_: Splits up terms into pieces, only one per analyzer is supported
2. _Character filters_: These allow junk in the document field to be ignored. Imagine a document field that contains HTML markup, lots of tags and angle brackets, that add no value in a search
3. _Token filters_: Process a stream of tokens from a tokenizer and can mutate (e.g. lowercase), delete (e.g. remove stop words) or add additional tokens (e.g. synonyms) along the way

[8 built-in analyzers](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-analyzers.html) are provided:

- Standard: No character filters, standard tokenizer, lowercases and optionally removes stop words
- Simple: Breaks terms whenever a non-alpha character is found, lowercases
- Whitespace: Breaks terms for any whitespace, does not lowercase
- Stop: Same as _Simple_, but supports stop word removal
- Keyword: A noop analyzer, it output the exacts same text its recieves
- Pattern: Breaks terms based on a regular expression, supports lowercasing and stop words
- Language: Language specific like `german` or `french`
- Fingerprint: Specialist analyzer that focuses on creating a uniqueness fingerprint useful for duplicate detection

Token filters are applied with the `filter` keyword. There are [dozens](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-tokenfilters.html) of built-in token filters.

- Snowball filter for applying stemming back words to their root forms, making text analysis and search more effective by treating different forms of the same word as a single term - [Snowball](http://snowball.tartarus.org/texts/introduction.html) is named after the Snowball project, which aims to produce highly configurable stemming algorithms for various languages. It is known for its flexibility and support for multiple languages.
- Lowercase
- Stop words, in addition to the standard stopwords, provided by the underlying Lucene engine.
- Mapping filter e.g. _X-Pack_ to _XPack_
- ASCII Folding is used for stripping and normalising special ASCII characters, and open/closing tags in XML representations
- Shingle filter
- Many more

The `_analyze` API is handy for testing how different analyzers behave.

```
GET _analyze
{
    "analyzer": "english",
    "text": "Tuning Go Apps in a Beat"
}

---

{
  "tokens" : [
    {
      "token" : "tune",
      "start_offset" : 0,
      "end_offset" : 6,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "go",
      "start_offset" : 7,
      "end_offset" : 9,
      "type" : "<ALPHANUM>",
      "position" : 1
    },
    {
      "token" : "app",
      "start_offset" : 10,
      "end_offset" : 14,
      "type" : "<ALPHANUM>",
      "position" : 2
    },
    {
      "token" : "beat",
      "start_offset" : 20,
      "end_offset" : 24,
      "type" : "<ALPHANUM>",
      "position" : 5
    }
  ]
}
```

Here's another:

```
GET _analyze
{
  "text": "United Kingdom",
  "analyzer": "standard"
}

---

{
  "tokens" : [
    {
      "token" : "united",
      "start_offset" : 0,
      "end_offset" : 6,
      "type" : "<ALPHANUM>",
      "position" : 0
    },
    {
      "token" : "kingdom",
      "start_offset" : 7,
      "end_offset" : 14,
      "type" : "<ALPHANUM>",
      "position" : 1
    }
  ]
}
```

Check out the [docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html) for more.

The stop analyzer:

```
GET _analyze
{
    "analyzer": "stop",
    "text": "Introducing beta releases: Elasticsearch and Kibana Docker images!"
}
```

The keyword analyzer:

```
GET _analyze
{
    "analyzer": "keyword",
    "text": "Introducing beta releases: Elasticsearch and Kibana Docker images!"
}
```

The english analyzer, includes stemming and lowercasing.

```
GET _analyze
{
    "analyzer": "english",
    "text": "Introducing beta releases: Elasticsearch and Kibana Docker images!"
}
```

#### Custom Analyzers and Token Filters

Many use-cases for [custom analyzers](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-custom-analyzer.html) such as:

- You want to tokenize a comma delimitered field within the document.
- Language specific analyzer (e.g. spanish, english).
- Stop words, terms that are just noise and add little value in search.
- Stemming (with the snowball filter) to boil down words to their roots.
- Token filters are applied in the sequence they are defined.
- Mapping terms of interest into a common representation, such as C++, c++, CPP should all map to cpp.

Can be created on the index:

```
PUT analysis_test
{
    "settings": {
        "analysis": {
            "char_filter": {
                "cpp_it": {
                    "type": "mapping",
                    "mappings": ["c++ => cpp", "C++ => cpp", "IT => _IT_"]
                }
            },
            "filter": {
                "my_stop": {
                    "type": "stop",
                    "stopwords": ["can", "we", "our", "you", "your", "all"]
                }
            },
            "analyzer": {
                "my_analyzer": {
                    "tokenizer": "standard",
                    "char_filter": ["cpp_it"],
                    "filter": ["lowercase", "stop", "my_stop"]
                }
            }
        }
    }
}
```

And to test it out:

```
GET analysis_test/_analyze
{
    "analyzer": "my_analyzer",
    "text": "C++ can help it and your IT systems."
}
```

Apply the analyzer to specific fields using a mapping:

```
"mappings": {
    "properties": {
    ...
        "content": {
            "type": "text",
            " analyzer": "my_content_analyzer"
        },
```

Another working example, that cleans up an HTML field:

```
PUT blogs_test
{
  "settings": {
    "analysis": {
      "analyzer": {
        "content_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "char_filter": [
            "html_strip"
          ],
          "filter": [
            "lowercase"
          ]
        }
      }
    }
  }
}
```

Testing it:

```
GET blogs_test/_analyze
{
  "text": "<b>Is</b> this <a href='/blogs'>clean</a> text?",
  "analyzer": "content_analyzer"
}
```

#### Java stable plugin API

[Elasticsearch plugins](https://www.elastic.co/guide/en/elasticsearch/plugins/8.13/plugin-authors.html) are modular bits of code that add functionality to Elasticsearch. Plugins are written in Java and implement Java interfaces that are defined in the source code. Plugins are composed of JAR files and metadata files, compressed in a single zip file.

Text analysis plugins can be developed against the [stable plugin API](https://www.elastic.co/guide/en/elasticsearch/plugins/8.13/creating-stable-plugins.html) to provide Elasticsearch with custom Lucene analyzers, token filters, character filters, and tokenizers.

A working Lucene character filter example is [provided](https://www.elastic.co/guide/en/elasticsearch/plugins/8.13/example-text-analysis-plugin.html).

### Dynamic templates

TODO

## You know, for search

### Query DSL

The Query DSL offers many types of queries.

- Full text queries: match, match_phrase, multi_match, query_string
- Term level queries: term, range, exists, fuzzy, regexp, wildcard
- Many more: script, percolate, span*, geo*, nested

#### match

By default, the match query uses "or" logic if multiple terms appear in the search query

```
GET blogs/_search
{
    "query": {
        "match": {
            "title": "community team"
        }
    }
}
```

Change to "and" logic:

```
GET blogs/_search
{
    "query": {
        "match": {
            "title": {
                "query": "community team",
                "operator": "and"
            }
        }
}
```

#### minimum_should_match

The or or and options might be too wide or too strict use the minimum_should_match parameter to trim the long tail of less relevant results

Here, two of the search terms must occur in the title of a document for it to be a match:

```
GET blogs/_search
{
    "query": {
        "match": {
            "title": {
                "query": "elastic community team",
                "minimum_should_match": 2
            }
        }
    }
}
```

#### match_phrase

`match` does not care about the order of terms. The `match_phrase` query is for searching text when you want to find terms that are near each other

```
GET blogs/_search
{
    "query": {
        "match_phrase": {
            "title": "community team"
        }
    }
}
```

#### sort, from and size

By default the query response will return:

1. top 10 documents that match the query and
2. sorted by `_score` in descending order

Basically defaults to this:

```
GET blogs/_search
{
    "from": 0,
    "size": 10,
    "sort": {
        "_score": {
            "order": "desc"
        }
    },
    "query": {
    ...
    }
}
```

Sort and pagination of course can be controlled:

```
GET blogs/_search
{
    "from": 100,
    "size": 50,
    "sort": [
        {
            "publish_date": {
                "order": "asc"
            }
        },
        "_score"
    ],
    "query": {
        ...
    }
}
```

#### fields

By default, each hit in the response includes the document’s `_source` the original document that was indexed. Use `fields` to only retrieve specific fields:

```
GET blogs/_search
{
    "_source": false,
    "fields": [
        "publish_date",
        "title"
    ]
    ...
}
```

#### Trimming the fat on \_source

Just return the `title` field off the source document:

```
GET blogs_fixed2/_search
{
  "size": 50,
  "_source": "title",
  "query": {
    "match_all": {}
  }
}

```

If you just want specific fields from hits, the `fields` parameter is more efficient than using `_source`. Modify your match_all query so that the fields parameter is title and set \_source to false (so that \_source does not get returned).

#### range and date math

```
GET blogs/_search
{
    "query": {
        "range": {
            "publish_date": {
                "gte": "2020-01-01",
                "lte": "2021-12-31"
            }
        }
    }
}
```

Date math is now supported `"gte": "now-3M"`, or `"now+1d"`:

```
GET blogs/_search
{
    "query": {
        "range": {
            "publish_date": {
                "gte": "now-1y"
            }
        }
    }
}
```

#### multi_match

How would you query multiple fields at once? For example: find blogs that mention "Agent" in the title or content fields.

`multi_match` has a `type` parameter, here multiple field hits will result in higher scoring:

```
GET blogs/_search
{
    "query": {
        "multi_match": {
            "type": "most_fields",
            "query": "agent",
            "fields": [
                "title",
                "content"
            ]
        }
    }
}
```

Phrase mode is another:

```
GET blogs/_search
{
    "query": {
        "multi_match": {
            "type": "phrase",
            "query": "elastic agent",
            "fields": [
                "title",
                "content"
            ]
        }
    }
}
```

#### Compound queries with bool

A _bool_ query allows a number a conditions to be articulated using the; `must`, `must_not`, `should` and `filter`. `filter` is similar to the `WHERE` clause in a SQL statement. Its not an optional.

```
GET blogs/_search
{
    "query": {
        "bool": {
            "must": [ ... ],
            "filter": [ ... ],
            "must_not": [ ... ],
            "should": [ ... ]
        }
    }
}
```

Clause types:

- `must`: Any query in a must clause must match for a document to be a hit, every query contributes to the score
- `filter`: Filters are like must clauses: any query in a filter clause has to match for a document to be a hit, queries in a filter clause do not contribute to the score
- `must_not`: Use `must_not` to exclude documents that match a query, queries in a `must_not` clause do not contribute to the score
- `should`: Use should to boost documents that match a query, contributes to the score, but, documents that do not match the queries in a should clause are returned as hits too

```
GET blogs_fixed2/_search
{
  "_source": [
    "title",
    "publish_date"
  ],
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "content": "ingestion"
          }
        }
      ],
      "must_not": [
        {
          "match": {
            "content": "logstash"
          }
        }
      ],
      "filter": [
        {
          "match": {
            "locale": "fr-fr"
          }
        }
      ]
    }
  }
}
```

### Query and Filter Contexts

Use filters as much as possible.

This prevents costly score calculations (is faster) and frequently used filters can be cached by the optimizer.

```
GET blogs/_search
{
    "query": {
        "bool": {
            "must": [
                {
                    "match": {
                        "content": "agent"
                    }
                }
            ],
            "filter": [
                {
                    "range": {
                        "publish_date": {
                            "gt": "2020"
                        }
                    }
                }
            ]
        }
    }
}
```

- `should` and `must` influence the score, and operate in the _query context_, and determine the shade of grey a match result it by scoring it. Its is handy to combine them, a `must` with several `should`'s will
- The `must_not` and `filter` options operate in what is known as the _filter context_, and is black and white, results MUST meet the crtieria. A result can't be more January than another, they are just January.
- When a search with only `should`'s is specified, this will implicitly define a `minimum_should_match` term of 1.
- A `should` could nest a `bool` that in turn contains a `must_not` to down score documents if they contain a certain term.
-

### Search templates

You have several applications sending the same complex search request.

Use search templates to pre-render search requests to store a search template, use the `_scripts` endpoint.

```
PUT _scripts/my_search_template
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
```

Then execute the stored search:

```
GET blogs/_search/template
{
    "id": "my_search_template",
    "params": {
        "my_field": "title",
        "my_value": "shay banon"
    }
}
```

Default parameters can be handy. Here the last one week of blogs will be returned, if the `end_date` param is not provided:

```
PUT _scripts/top_blogs
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "bool": {
          "filter": [
            {
              "range": {
                "publish_date": {
                  "gte": "{{start_date}}",
                  "lt": "{{end_date}}{{^end_date}}{{start_date}}||+1w{{/end_date}}"
                }
              }
            }
          ]
        }
      }
    }
  }
}
```

Conditionals in mustache is also supported, everything in between `{{#search_date}}` and `{{/search_date}}` in this snippet:

```
PUT _scripts/my_search_template
{
    "script": {
        "lang": "mustache",
        "source":
        """
        { "query": { "bool": {
            "must": [ {
                "match": { "content": "{{
                search_term}}" } } ]
                {{#search_date}}
                ,
            "filter": [ {
                "range": {
                    "@timestamp": {
                        "gte": "{{start}}",
                        "lt": "{{end}}" } } }]
                {{/search_date}}
            } } }
            """
        } }
```

### Async search

Useful for slow queries and aggregations, here you can ship the query off and monitor the progress, retreiving partial results as they become available.

```
POST blogs_fixed2/_async_search?wait_for_completion_timeout=0s
{
  "query": {
    "function_score": {
      "query": {
        "match": {
          "content": "to the blog and your query: you are both enjoying being on Elasticsearch "
        }
      },
      "script_score": {
        "script": """
        int m = 30;
        double u = 1.0;
        for (int x = 0; x < m; ++x)
          for (int y = 0; y < 10000; ++y)
            u=Math.log(y);
        return u
        """
      }
    }
  }
}
```

By default the:

- `wait_for_completion_timeout` is 1s
- `expiration_time_in_millis` is 5d

For long running queries, you'll get a token that you can use to check up on:

```
GET _async_search/FlBfdWczbWdyU1MyUWZKd0EzcHZUb2ceSHJGWkpBVFdRZ0dpUlhOOVhvaXJlUToyNTgyMTMz
```

## Data Processing

### Changing Data

#### Processors

[Processors](https://www.elastic.co/guide/en/elasticsearch/reference/current/processors.html) can be used to transform documents before being indexed into Elasticsearch

There are different ways to deploy processors: Beats, Logstash or Ingest node pipelines

Processors:

- `set`, just setting a string literal to a field
- `split`, for splitting a string into an array
- `script` for running a painless script
- `pipeline`
- `remove`
- `dot_expander`
- `join`
- `dissect`
- `gsub`
- `csv`
- `json`
- `geoip`
- `user_agent`

There are [tons more](https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest-processors.html).

Pro tip: master nodes are by default ingest nodes, be careful you don't kill your master nodes, if you start putting heavy load on ingest nodes.

#### Ingest pipelines

Ingest pipelines are the primary instrument for running processors.

Here's a sample of the `drop` processor:

```
PUT _ingest/pipeline/my_pipeline
{
  "processors": [
    {
      "remove": {
        "field": "is_https",
        "ignore_missing": true
      }
    },
    {
      "rename": {
        "field": "request",
        "target_field": "url.original",
        "ignore_missing": true
      }
    },
    {
      "drop": {
        "description": "Drop documents with 'network.name' of 'Guest'",
        "if": "ctx?.network?.name == 'Guest'"
      }
    }
  ]
}
```

Testing ingest pipelines:

```
GET _ingest/pipeline/web_traffic_pipeline/_simulate
{
  "docs": [
    {
      "_source": {
        "@timestamp": "2021-03-21T19:25:05.000-06:00",
        "bytes_sent": 26774,
        "content_type": "text/html; charset=utf-8",
        "geoip_location_lat": 39.1029,
        "geoip_location_lon": -94.5713,
        "is_https": true,
        "request": "/blog/introducing-elastic-endpoint-security",
        "response": 200,
        "runtime_ms": 191,
        "user_Agent": "Mozilla/5.0 (compatible; MJ12bot/v1.4.8; http://mj12bot.com/)",
        "verb": "GET"
      }
    }
  ]
}
```

Apply the pipeline to document in index request:

```
POST my_index/_update_by_query? pipeline=my_pipeline
```

Set the default pipeline on a new index called `web_traffic`:

```
PUT web_traffic
{
  "settings": {
    "default_pipeline": "web_traffic_pipeline",
    "number_of_shards": 10,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "geo": {
        "properties": {
          "location": {
            "type": "geo_point"
          }
        }
      }
    }
  }
}
```

Use `_settings` API for existing indices:

```
PUT my_index/_settings
{
    "default_pipeline": "my_pipeline"
}
```

Re-process documents by running a specific pipeline with update by query or reindex API's:

You can change index settings and modify the `_source` using `_reindex` `_update_by_query` API's.

#### reindex API

The `_reindex` API clones one index to another index.

A handy pattern is to reindex an index into a temporary staging index. Test apply custom analyzers or mappings etc. If successful, reindex the staging index back to the live index.

Beware for large indexes, as this can take a significant amount of time. TODO checkout scrolling and some internals around this.

```
POST _reindex
{
    "source": {
        "index": "blogs"
    },
    "dest": {
        "index": " blogs_v2"
    }
}
```

To reindex only a subset of the source index use `max_docs` and/or add a `query`:

```
POST _reindex
{
    "max_docs": 100,
    "source": {
        "index": " blogs",
        "query": {
            "match": {
                "category": "Engineering"
            }
        }
    },
    "dest": {
        "index": " blogs_fixed"
    }
}
```

Reindex from a remote cluster. Remote hosts have to be explicitly allowed in `elasticsearch.yml` using the `reindex.remote.whitelist` property:

Here's an `elasticsearch.yml` snippet:

```
reindex.remote.whitelist: node5:9204
reindex.ssl.certificate_authorities: /usr/share/elasticsearch/config/certificates/ca/ca.crt
reindex.ssl.verification_mode: none
```

```
POST _reindex
{
    "source": {
        "remote": {
            "host": "http://otherhost:9200",
            "username": "user",
            "password": "pass"
        },
        "index": "remote_index",
    },
    "dest": {
        "index": "local_index"
    }
}
```

#### Update by Query API

To change all the documents in an existing index use the Update by Query API:

- reindexes every document into the same index
- _update by query_ has many of the same features as _reindex_

```
POST blogs/ _update_by_query
{
    "query": {
        "match": { "category" : "Engineering" }
    }
}
```

Documents that don't match the query are left unchanged.

Here is a piece of painless script that increments the `count` field on documents:

```
POST my-index/_update_by_query
{
    "script": {
        "source": "ctx._source.count++",
        "lang": "painless"
    },
    "query": {
        "term": {
            "user.id": "kimchy"
        }
    }
}
```

#### Delete by Query API

Use the _Delete by Query API_ to delete documents that match a specified query deletes every document in the index that is a hit for the query.

```
POST blogs_fixed/_delete_by_query
{
    "query": {
        "match": {
            "author.full_name.keyword": "Clinton Gormley"
        }
    }
}
```

### Enriching Data

Common enrichment use-cases:

- Add zip codes based on geo location
- Enrichment based on IP range
- Currency conversion
- Denormalizing data
- Threat Intel Enrichment

#### Denormalizing your data with enrichments

Denormalizing your data refers to "flattening" your data storing redundant copies of data in each document instead of using some type of relationship.

Use the enrich processor to add data from your existing indices to incoming documents during ingest

There are several steps to enriching your data:

1. Set up an enrich policy
1. Create an enrich index for the policy
1. Create an ingest pipeline with an enrich processor
1. Set up your index to use the pipeline

First setup an enrich policy (note it cant be modified once created):

```
PUT _enrich/policy/categories_policy
{
  "match": {
    "indices": "categories",
    "match_field": "uid",
    "enrich_fields": ["title"]
  }
}
```

Second, execute the enrich policy to create the enrich index for your policy:

```
POST _enrich/policy/categories_policy/_execute
```

An enrich policy uses enrich data from the policy’s source indices to create a streamlined system index called the enrich index the processor uses this index to match and enrich incoming documents.

Third, create ingest pipeline with enrich processor:

```
PUT _ingest/pipeline/categories_pipeline
{
  "processors": [
    {
      "enrich": {
        "field": "category",
        "policy_name": "categories_policy",
        "target_field": "category_title",
        "ignore_missing": true
      }
    },
    {
      "remove": {
        "field": "category",
        "ignore_missing": true
      }
    }
  ]
}
```

- the field in the input document that matches the policy’s `match_field`
- set `max_matches` >1 if the field in the input document is an array

Now is a good time to setup mappings for the newly enriched data:

```
PUT blogs_fixed2/_mapping
{
  "properties": {
    "category_title": {
      "properties": {
        "title": {
          "type": "keyword"
        },
        "uid": {
          "type": "keyword"
        }
      }
    }
  }
}
```

Finally, you can leverage the pipeline:

```
POST blogs_fixed2/_update_by_query?pipeline=categories_pipeline&wait_for_completion=false
```

Set the pipeline as a `default_pipeline` if you want to enrich incoming documents.

### Scripting

Elasticsearch compiles new scripts and stores the compiled version in a cache.

Use `source` for inline script or `id` for stored script.

```
"script": {
    "lang": "...",
    "source" "...",
    "params": { ... }
}
```

#### Painless

Painless has a Java-like syntax (and can contain actual Java code) and fields of a document can be accessed using a Map named doc.

```
GET blogs/_search
{
    "script_fields": {
        "second_part_of_url": {
            "script": {
                "source": "doc['url'].value.splitOnToken('/')[2]"
            }
        }
    }
}
```

Use Painless to:

- create Kibana scripted fields
- process reindexed data
- create runtime fields which are evaluated at query time

[painless script](https://www.youtube.com/watch?v=3FLEJJ8PsM40)

One way you can use Painless is in a script query:

```
GET blogs_fixed2/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "script": {
            "script": """
              return doc['url'].value.length() >= 100;
            """
          }
        }
      ]
    }
  }
}
```

Painless is a mini language, here we iterate over an array field:

```
GET blogs_fixed2/_search
{
  "query": {
    "bool": {
      "filter": [
        {
          "script": {
            "script": """
              def authors = doc['authors.last_name'];
              for (int i=0; i<authors.size(); i++) {
                if (authors.get(i).startsWith("K")) {
                  return true;
                }
              }
              return false;
            """
          }
        }
      ]
    }
  }
}
```

#### Runtime fields

Runtime fields allow for creating arbitrary non-indexed data fields and are evaluated at query time.

Ideally, your schema is defined at index time ("schema on write"). However, there are situations, where you may want to define a schema on read.

Testing runtime fields in Kibana is convenient and can be done on a data view with "add field".

Common to run into `[script] Too many dynamic script compilations within`, thresholds for which can be controlled with `script.context.field.max_compilations_rate`.

A runtime field can be bolted in as part of the query definition:

```
GET blogs_fixed2/_search
{
  "runtime_mappings": {
    "day_of_week": {
      "type": "keyword",
      "script": {
        "source": "emit(doc['publish_date'].value.dayOfWeekEnum.getDisplayName(TextStyle.FULL, Locale.ROOT))"
      }
    }
  },
  "aggs": {
    "by_day": {
      "terms": {
        "field": "day_of_week"
      }
    }
  },
  "size": 0
}

```

Alternatively, you can bolt the field in as a mapping, by defining the `runtime` section defines the field in the mapping:

```
PUT blogs/_mapping
{
    "runtime": {
        "day_of_week": {
            "type": "keyword",
            "script": {
                "source": "emit(doc['publish_date'].value.dayOfWeekEnum.getDisplayName(TextStyle.FULL, Locale.ROOT))"
            }
        }
    }
}
```

To remove a runtime field:

```
PUT blogs/_mapping
{
    "runtime": {
        "day_of_week": null
    }
}
```

#### Changing mappings at query time

With runtime fields its possible to change the mapping of a field just only for a specific search request:

```
GET blogs_fixed2/_search
{
  "runtime_mappings": {
    "authors.full_name": {
      "type": "keyword"
    }
  },
  "query": {
    "match": {
      "authors.full_name": "Jongmin Kim"
    }
  }
}
```

Similarly this technique can be used to query disabled fields.

## Aggregations

Equivalent of a `GROUP BY` clause.

Types of aggregations:

- Bucket: Uses a field within the document type to aggregate on. For example, people by gender. Buckets can be nested. People by country, by gender for example. Buckets can also be sorted by its `_key` (the value of the in context bucketing term).
- Metrics: The usual aggregation suspects, `count`, `max`, `min`, `cardinality`, etc statistically summarize documents
- Term: What the biggest contributor (e.g. by country) of a specific search term. Term aggregation are not precise due to a distributed computing problem, where aggregates are calculated per shard by each data node, which is then in turn tallied up by the coordinating node. To avoid this, you can ask that more aggregation results be returned to the coordinator, to avoid inaccurate tallying, by specifying a `"shard_size": 500`

### metric

Compute values extracted from the documents.

Business quetsions:

- What is the number of bytes served from all blogs?
- What is the average of bytes served from Android devices?
- What is the average response time?
- What is the median response time?
- What is the 95 percentile?

Elasticsearch provides the following:

- `min/max/sum/avg`:
- `weighted_avg`:
- `stats`:
- `percentiles`:
- `percentile_ranks`: measures the percentage
- `geo_centroid`:
- `top_hits`:

Be aware some of these return a single value, some return many.

#### cardinality

```
GET blogs/_search
{
    "size": 0,
    "aggregations": {
        "my_cardinality_agg": {
            "cardinality": {
                "field": "authors.full_name.keyword"
            }
        }
    }
}
```

#### min

`min` example showing the fastest web request:

```
get web_traffic/_search?size=0
{
  "aggs": {
    "fastest_request": {
      "min": {
        "field": "runtime_ms"
      }
    }
  }
}
```

#### stats

`stats` will crunch all the key metrics in one go:

```
get web_traffic/_search?size=0
{
  "aggs": {
    "fastest_request": {
      "stats": {
        "field": "runtime_ms"
      }
    }
  }
}

---

"aggregations" : {
  "fastest_request" : {
    "count" : 1462658,
    "min" : 73.0,
    "max" : 1.449890781E9,
    "avg" : 494715.2839590663,
    "sum" : 7.23599267805E11
  }
}
```

`percentile` (my favourite) will

```
get web_traffic/_search?size=0
{
  "aggs": {
    "runtime_median_and_90": {
      "percentiles": {
        "field": "runtime_ms",
        "percents": [
          50,
          90
        ]
      }
    }
  }
}

---

"aggregations" : {
  "runtime_median_and_90" : {
    "values" : {
      "50.0" : 394555.0707763148,
      "90.0" : 955544.3463730324
    }
  }
}
```

#### percentile_ranks

`percentile_ranks` given a concrete value will return the percentile it represents. Approximately 64.6% of the requests take 500 milliseconds or less.

```
get web_traffic/_search?size=0
{
  "aggs": {
    "runtime_sla": {
      "percentile_ranks": {
        "field": "runtime_ms",
        "values": [500000]
      }
    }
  }
}
```

#### top_hits

Allows you to surface documents that are part of the aggregation.

For example, the following searches for "elasticsearch siem" in the `content` field. Using this scope of documents then gets the top 3 blogs of each one of the top 5 categories:

```
GET blogs_fixed2/_search
{
  "size": 0,
  "query": {
    "match": {
      "content": "elasticsearch siem"
    }
  },
  "aggs": {
    "top5_categories": {
      "terms": {
        "field": "category_title.title",
        "size": 5
      },
      "aggs": {
        "top3_blogs": {
          "top_hits": {
            "size": 3,
            "_source": ["title"]
          }
        }
      }
    }
  }
}
```

### term (bucket)

Group documents according to certain criteria. Business questions:

- How many requests reach our system every day?
- How many requests took between 0-200, 200-500, 500+ ms?
- What are the most viewed blogs on our website?
- Which are the 5 most popular blog categories?

ES provides the following:

- `date_histogram`:
- `terms`
- `filter`
- `range`: custom numeric ranges

Sample terms aggregation:

```
GET blogs/_search
{
    "size": 0,
    "aggregations": {
        "my_terms_agg": {
            "terms": {
                "field": "authors.full_name.keyword"
            }
        }
    }
}
```

Date histogram buckets:

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "runtime_histogram": {
      "histogram": {
        "field": "bytes_sent",
        "interval": 10000,
        "min_doc_count": 1000
      }
    }
  }
}
```

### significant_terms and significant_text

[Significant Terms Aggregation](https://www.elastic.co/blog/significant-terms-aggregation)

Samples a subset of the dataset, known as the foreground group where there is a population density pattern in the data, for example how many people in the general public know about google, vs how many people in the general public know about lucene, vs how many developers in the Elastic training know about lucene. The Elastic developers group has an unusual density of familiarity with lucene, than the general public.

To use simply change `terms` in an aggregation to `significant_terms`. Example, shows a blog author that has unique significant terms, specific to their writing (no common terms like the, and, or).

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "top_OS": {
      "terms": {
        "field": "user_agent.os.name.keyword",
        "size": 5
      },
      "aggs": {
        "top_urls": {
          "significant_terms": {
            "field": "url.original",
            "size": 3
          }
        }
      }
    }
  }
}
```

Constrasting this with a vanilla `terms` agg, the URLs returned by a `significant_terms` are less generic and more specifics.

With `terms` the top result for `Windows` samples these URLs:

```
            "buckets" : [
              {
                "key" : "/blog/welcome-insight-io-to-the-elastic-team",
                "doc_count" : 38455
              },
              {
                "key" : "/blog/introducing-elastic-endpoint-security",
                "doc_count" : 10596
              },
              {
                "key" : "/blog/how-many-shards-should-i-have-in-my-elasticsearch-cluster",
                "doc_count" : 9044
              }
            ]
```

However with `significant_terms`:

```
            "buckets" : [
              {
                "key" : "/blog/welcome-insight-io-to-the-elastic-team",
                "doc_count" : 38455,
                "score" : 0.058338717766485755,
                "bg_count" : 60841
              },
              {
                "key" : "/blog/configuring-ssl-tls-and-https-to-secure-elasticsearch-kibana-beats-and-logstash",
                "doc_count" : 7369,
                "score" : 0.00916213949964911,
                "bg_count" : 12664
              },
              {
                "key" : "/blog/whats-new-elastic-7-12-0-schema-on-read-frozen-tier-autoscaling",
                "doc_count" : 7736,
                "score" : 0.007438080722458519,
                "bg_count" : 14590
              }
            ]
```

### Pipeline aggregations

Works on output produced from other aggregations.

- bucket `min/max/sum/avg`
- `cumulative_sum`
- `moving_aggs`
- `bucket_sort`

#### moving_aggs

Compute the moving average of the hourly sum with a window of 5 hours:

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "logs_by_week": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "hour"
      },
      "aggs": {
        "sum_bytes": {
          "sum": {
            "field": "bytes_sent"
          }
        },
        "the_movfn": {
          "moving_fn": {
            "buckets_path": "sum_bytes",
            "window": 5,
            "script": "MovingFunctions.unweightedAvg(values)"
          }
        }
      }
    }
  }
}
```

### Scripted (painless) aggregations

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

### Aggregation essentials

- Set a `"size": 0` to completely strip document results, but keep the aggregation result itself.
- Queries and aggregations can be coupled together.
- Aggregations only work with keywords.

#### Reducing aggregation by combining with query

By default, aggregations are performed on all documents in the index. Combine with a query to reduce the scope.

```
GET web_traffic/_search
{
  "size": 0,
  "query": {
    "term": {
      "http.response.status_code": {
        "value": "404"
      }
    }
  },
  "aggs": {
    "logs_by_week": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "week"
      }
    }
  }
}
```

#### Multiple aggregation in a single request

You can specify multiple aggregations in the same request.

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "medium": {
      "percentiles": {
        "field": "runtime_ms",
        "percents": [50]
      }
    },
    "average": {
      "avg": {
        "field": "runtime_ms"
      }
    }
  }
}
```

#### Sub buckets

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "response_code_types": {
      "terms": {
        "field": "http.response.status_code"
      },
      "aggs": {
        "medium": {
          "percentiles": {
            "field": "runtime_ms",
            "percents": [
              50
            ]
          }
        }
      }
    }
  }
}
```

#### Sub aggregations

Bucket aggregations support bucket or metric sub-aggregations. Super handy for answering things such as:

- What is the sum of bytes per day?
- What is the number of bytes served daily and median bytes size?
- What is the number of bytes served monthly per OS?

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "logs_by_week": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "week"
      },
      "aggs": {
        "user_agent_os": {
          "terms": {
            "field": "user_agent.os.name.keyword"
          }
        }
      }
    }
  }
}
```

Another example, most popular operating system, top 3 URL's they accessed:

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "user_agent_os": {
      "terms": {
        "field": "user_agent.os.name.keyword"
      },
      "aggs": {
        "top_urls": {
          "terms": {
            "field": "url.original",
            "size": 3
          }
        }
      }
    }
  }
}
```

#### Sorting by a metric

You can sort buckets by a metric value in a sub-aggregation:

```
GET web_traffic/_search
{
  "size": 0,
  "aggs": {
    "response_code_types": {
      "terms": {
        "field": "http.response.status_code",
        "order": {
          "runtime_ms_medium.50": "asc"
        }
      },
      "aggs": {
        "runtime_ms_medium": {
          "percentiles": {
            "field": "runtime_ms",
            "percents": [
              50
            ]
          }
        }
      }
    }
  }
}
```

### Transforms

[Transforms](https://www.elastic.co/guide/en/elasticsearch/reference/current/transform-overview.html) enable you to convert existing raw indices into summarized output indices using aggregations. Tranforms can operate in one of two supported modes:

- pivot: to collect results of complex bucket and metrics aggs (essentially providing a high performance cache of complex queries)
- latest: to collect most recent documents of bucket aggs

Some key configurable traits of a transform:

- Continuous mode: the syncronisation strategy and frequency, allowing control over the staleness of data. You can measure the performance and find a sweet spot with the [transform statistics API](https://www.elastic.co/guide/en/elasticsearch/reference/current/get-transform-stats.html)
- Retention policy: the garbage collection criteria as being out of date in the destination index

The [transform API](https://www.elastic.co/guide/en/elasticsearch/reference/current/transform-api-quickref.html) is the way to go, but as always can use Kibana under Stack Management > Transforms.

```
PUT _transform/traffic_stats
{
  "source": {
    "index": [
      "web_traffic"
    ]
  },
  "pivot": {
    "group_by": {
      "url.original": {
        "terms": {
          "field": "url.original"
        }
      }
    },
    "aggregations": {
      "@timestamp.value_count": {
        "value_count": {
          "field": "@timestamp"
        }
      },
      "runtime_ms.avg": {
        "avg": {
          "field": "runtime_ms"
        }
      }
    }
  },
  "frequency": "1m",
  "dest": {
    "index": "traffic_stats"
  },
  "settings": {
    "max_page_search_size": 500
  }
}
```

Then start the transform:

```
POST _transform/traffic_stats/_start
```

## The one about shards

[How many shards should I have in my Elasticsearch cluster?](https://www.elastic.co/blog/how-many-shards-should-i-have-in-my-elasticsearch-cluster)

A cluster is made of 1 or more nodes, and nodes communicate with each other and exchange information.

An index is a collection of documents that are related to each other the documents stored in Elasticsearch are distributed across nodes.

An index distributes documents over one or more shards. Each shard:

- is an instance of Lucene
- contains all the data of any one document

Every document is stored in a single (Lucene) shard.

### Primary and replica shards

There are two types:

Primary, the original shards of an index. They are number using a zero based index, i.e. first shard is shard 0. You can not increase the number of primary shards after an index is created

Replica, a clone of the primary. The default setting is 1 replica per primary shard. Replicas, like primaries, can be used for querying. The number of replicas (unlike primaries) can be adjusted for existing indices.

How to see shard allocations? By checking out the routing table from the cluster state.

```
PUT fooindex
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 2
  }
}
```

To adjust the replicas on an existing index:

```
PUT fooindex/_settings
{
  "number_of_replicas": 2
}
```

List shard allocation, sorted by shard:

```
GET _cat/shards/fooindex?v&h=index,shard,prirep,state,node&s=index,shard,prirep
```

### Shard tips

- The number of primary shards can't be changed
- The number of replicas however, can be changed
- More replicas increases read throughput
- Useful for managing bursts of resources (e.g. ebay during the xmas period), the number of data nodes and replicas can be increased dynamically on the existing cluster.
- The hashing algorithm called [murmur3](https://en.wikipedia.org/wiki/MurmurHash) modulo the total number of shards, is used to determine the shard number to assign to a specific document.
- Updates and deletes are actually difficult to manage in this distributed system, and are essentially treated as immutatble entites.
- An index operation must occur on the primary shard, prior to being done on any replicas.
- The TF/IDF algorithm, the term frequency make sense even when calculated locally to the shard.
- With the default, fetch-then-query behaviour, IDF (document frequency) can be skewed when its calculated locally on the shard. IDF would be very expensive to calculate globally across the cluster. Interestingly in practice, this is rarely an issue, especially when you have a large dataset that is evenly distributed across shards, as an even sampling exists.
- A global IDF can be computed if desired, by setting the `search_type` to `dfs_query_then_fetch`, and useful for testing on small datasets, `GET blogs/_search?search_type=dfs_query_then_fetch`

As shards are distributed across nodes, first paint a picture of available nodes:

```
GET _cat/nodes?v
```

Indices live in shards, this assignment and their physical footprint (total across replicas and just primary in KB) can be measured with:

```
GET _cat/indices?v
```

To evaluate shard to document distribution, use the `_cat` API:

    GET _cat/shards?v

Or a specific cluster name can be specified with:

    GET _cat/shards/logs_server2?v

Or even better sorted by shard and primary/replica type:

    GET _cat/shards/test1?v&s=shard,prirep

Results:

    index shard prirep state   docs store ip         node
    blogs 0     p      STARTED  321 1.2mb 172.18.0.4 node3
    blogs 0     r      STARTED  321 1.2mb 172.18.0.3 node2
    blogs 1     p      STARTED  316 1.1mb 172.18.0.4 node3
    blogs 1     r      STARTED  316 1.1mb 172.18.0.2 node1
    blogs 2     p      STARTED  356 1.4mb 172.18.0.4 node3
    blogs 2     r      STARTED  356 1.4mb 172.18.0.2 node1
    blogs 3     p      STARTED  304 1.1mb 172.18.0.2 node1
    blogs 3     r      STARTED  304 1.1mb 172.18.0.3 node2
    blogs 4     p      STARTED  297   1mb 172.18.0.2 node1
    blogs 4     r      STARTED  297   1mb 172.18.0.3 node2

For testing you can stop and start nodes to observe the spread of replicas across nodes.

Also can change the replia setting live for an index:

    PUT test1/_settings
    {
      "settings": {
        "number_of_replicas": 0
      }
    }

#### Scaling for reads

Queries and aggregations scale with replicas. For example, have one primary and as many replicas as you have additional nodes.

Use auto_expand_replicas setting to change the number of replicas automatically as you add/remove nodes.

```
PUT fooindex/_settings
{
  "index.auto_expand_replicas": "0-all"
}
```

Read optimisation tips:

- Create flat, denormalized documents
- Query the smallest number of fields, consider `copy_to` over `multi_match`
- Map identifiers as keyword instead of as a number, term queries on keyword fields are very fast
- Force merge read-only indices
- Limit the scope of aggregations
- Use filters, as they are cacheable

See [Tuning for search speed](https://www.elastic.co/guide/en/elasticsearch/reference/current/tune-for-search-speed.html) for more.

When searching you can explicitly request a shard to service the request, using the [preference](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-preference) parameter:

```
GET blogs_tmp/_search?preference=_shards:0
{
  "size": 3,
  "_source": ["title"],
  "query": {
    "match": {
      "content": "Agent"
    }
  }
}
```

#### Scaling for writes

Write throughput scales by increasing number of primaries:

- having many primary shards allows Elasticsearch to "fan out" the writes, so each shard does less work.
- maximize throughput by using disks on all machines

When an index is done with writes, you can shrink it.

Write optimization tips:

- Use `_bulk` API to minimize the overhead of HTTP requests
- Parallelize your write requests
- Disable refreshing every second:
  - set `index.refresh_interval` to `-1` for very large writes (then back to default when finished indexing)
  - set `index.refresh_interval` to `30s` to increase indexing speed but affect search as little as possible
- Disable replicas, then re-enable after very large writes, every document also needs to be written to every replica
- Use auto-generated IDs, Elasticsearch won't check whether a doc ID already exists

If you disable the refresh interval, you can manually trigger a refresh with:

```
POST fooindex/_refresh
```

Now the data ingestion is complete, spread it across the cluster as replicas with:

```
PUT fooindex/_settings
{
  "index.auto_expand_replicas": "0-all"
}
```

Then validate shard assignment to replias:

```
GET _cat/shards/fooindex?v&h=index,shard,prirep,state,node&s=index,shard,prirep
```

### The lifecycle of a document index request

1. When a document is indexed in a cluster `PUT blogs/_doc/551 { ... }`, the index request is routing to a coordinating node
1. The index request is sent to a chosen coordinating node (e.g. `node3`)
1. This node will determine on which shard the document will be indexed
1. When you index, delete, or update a document, the primary shard has to perform the operation first (e.g. `node3` forwards to `node1`, which houses the desigated primary shard deemed for the document)
1. `node1` indexes the document, then scatters out replica sync requests

"its depends" e.g. the level of staleness tolerable by business, replicas sync rates, refresh_intervals,

Given the REST API is based on HTTP, two things:

- The HTTP response code.
  - Can't connect, investigate network and path.
  - Connect just closed. Retry if possible (i.e. wont result in data duplication). This is one benefit of always indexing with explicit id's.
  - 4xx, busted request.
  - 429, Elasticsearch is too busy, retry later. Client should have backoff policies, such as a linear or exponential backoffs.
  - 5xx, look into ES logs.
- JSON body, always includes some basic shard metadata.

      "_shards": {

  "total": 2,
  "successful": 2,
  "failed": 0
  },

Breaking this down:

- Total has many shard copies.
- Successful the count of shard copies that were updated.
- Failed, a count, which will also come with a descriptive `faliures` structure with informative reason information.

Search responses:

- Skipped, ES 6.X onwards has an cheeky optimisation that applies when over 128 shards exists. A pre-optimisation that avoid hassling shards, if it knows there is just no point (i.e. documents that relate to the requested operation will just not exist in those shards).

#### Cluster and Shard Health

Shard health:

- _Red_, at least one primary shard is not allocated in the cluster
- _Yellow_, all primaries are allocated but at least one replica is not
- _Green_, all shards are allocated

Index health, will always report on the worrst shard in that index.

Cluster health, will report the worst index in that cluster.

Shard lifecycle:

- `UNASSIGNED`, when shards haven't yet been allocated to nodes yet
- `INITIALIZING`, when shards are being provisioned and accounted for
- `STARTED`, shard is allocated and ready to store data
- `RELOCATING`, when a shard is in the process of being shuffled to another node

Shard promotion, can occur in the instance of a node failure, where a replica will evolve into a primary.

Details shard and index specific details can be obtained, using the `_cluster` API:

    GET _cluster/allocation/explain

{
"index": "test1",
"shard": 3,
"primary": true
}

Shard status with `GET _cat/shards/test0?v`:

index shard prirep state docs store ip node
test0 3 p STARTED 0 261b 172.18.0.2 node1
test0 4 p STARTED 0 261b 172.18.0.4 node3
test0 2 p UNASSIGNED  
test0 1 p STARTED 0 261b 172.18.0.4 node3
test0 0 p STARTED 0 261b 172.18.0.2 node1

## Data management

### Index aliases

Indices scale by adding more shards, but increasing the number of shards of an index is expensive.

index aliases to simplify your access to the growing number of indices.

Use the `_aliases` endpoint to create an alias specify the write index using `is_write_index`

```
TODO example here
```

Configure a new index to be the write index for an alias:

```
PUT my-metrics-000001
{
  "aliases": {
    "my-metrics": {
      "is_write_index": true
    }
  }
}

GET my-metrics-000001
```

### Index Templates

Blueprints for indices when their name matches a pattern. For controlling things like:

- Shard configuration
- Replica configuration

An index template can contain the following sections:

- component templates
- settings
- mappings
- aliases

Component templates are reusable building blocks that can contain:

- settings, mappings or aliases
- components are reusable pieces that can be tapped into multiple templates

In Kibana this is available under Stack Management > Index Management > Component Templates.

The `_component_template` API is best:

```
PUT _component_template/time-series-mappings
{
  "template": {
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "status": {
          "type": "keyword"
        },
        "message": {
          "type": "text"
        }
      }
    }
  }
}
```

Component templates can define settings too:

```
PUT _component_template/time-series-settings
{
  "template": {
    "settings": {
      "index": {
        "number_of_replicas": "2"
      }
    }
  }
}
```

Working example, the `logs-template` overrides the default setting of 1 replica and applies to any new indices with a name that begins with logs:

```
PUT _index_template/logs-template
{
  "index_patterns": [ "logs*" ],
  "template": {
    "settings": {
      "number_of_replicas": 0
    }
  }
}
```

Here's a index template that uses multiple component templates:

```
PUT _index_template/my-metrics-template
{
  "priority": 500,
  "index_patterns": [
    "my-metrics-*"
  ],
  "composed_of": [
    "time-series-mappings",
    "time-series-settings"
  ]
}
```

#### Resolving template match conflicts

Multiple templates can be applied to an index, depending on the name matching rules that are evaluated. An `order` value in the template helps for the precedence of templates to battle it out.

One and only one template will be applied to a newly created index. If more than one template defines a matching index pattern, the
priority setting is used to determine which template applies:

1. the highest priority is applied, others are not used
2. set a priority over 200 to override auto-created index templates
3. use `_simulate` to test how an index would match

```
POST /_index_template/_simulate_index/my_index-test
```

### Index rollover

Rollovers can be used with aliases and templates to create new indices when an older one becomes full (e.g. approaches 30GB for example).

```
POST my-metrics/_rollover
{
  "conditions": {
    "max_age": "2s"
  }
}
```

If the alias houses a single write index `my-metrics-000001`, the above rollover with auto create a new index `my-metrics-000002` and mark it as the new write index.

### Data streams

A data stream is a collection of backing indices behind an alias and are ideal for time series data that grows quickly and doesn't change.

Time series data typically grows quickly and is almost never updated.

A data stream lets you store time-series data across multiple indices while giving you a single named resource for requests:

- indexing and search requests are sent to the data stream
- the stream routes the request to the appropriate backing index

Every data stream is made up of hidden backing indices with a single write index.

A rollover creates a new backing index based on age or size which becomes the stream’s new write index.

`TODO: diagram`

#### Data stream naming conventions

Data streams are named by:

- type, to describe the generic data type
- dataset, to describe the specific subset of data
- namespace, for user-specific details

For example `metrics-system.cpu-production`

Each data stream should include constant_keyword fields for:

- data_stream.type
- data_stream.dataset
- data_stream.namespace

constant_keyword has the same value for all documents

#### Creating a data stream

First create component template:

```
PUT _component_template/time-series-mappings
{
  "template": {
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "message": {
          "type": "text"
        },
        "status": {
          "type": "keyword"
        },
        "data_stream.type": {
          "type": "constant_keyword"
        }
      }
    }
  }
}
```

Next, define an index template ensuring its marked as a `data_stream`:

```
PUT _index_template/my-metrics-ds-template
{
  "priority": 500,
  "index_patterns": [
    "my-metrics-*-*"
  ],
  "data_stream": {},
  "composed_of": [
    "time-series-mappings",
    "time-series-settings"
  ]
}
```

Finally create the data stream:

```
POST my_metrics-service.status-dev/_doc
{
  "@timestamp": "2021-07-04",
  "status": "UP",
  "message": "Service is running."
}
```

#### Changing a data stream

Changes should be made to the index template associated with the stream. New backing indices will get the changes when they are
created. Older backing indices can have limited changes applied.

For example, you may change a component template part of a broader index template:

```
PUT _component_template/time-series-mappings
{
  "template": {
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "message": {
          "type": "text"
        },
        "status": {
          "type": "keyword"
        },
        "data_stream.type": {
          "type": "constant_keyword"
        }
      }
    }
  }
}
```

After updating, you should observe that the data stream has not taken on the new mappings:

```
GET my_metrics-service.status-dev/_mapping
```

Next you can manually rollover the data:

```
POST my_metrics-service.status-dev/_rollover
```

Index a new data stream event:

```
POST my_metrics-service.status-dev/_doc
{
  "@timestamp": "2021-07-05",
  "status": "UP",
  "message": "Service is running.",
  "data_stream.type": "my_metrics"
}
```

Confirm the updated mappings on the data stream have been absorbed:

```
GET my_metrics-service.status-dev/_mapping
```

Before reindexing, use the resolve API to check for conflicting names:

```
GET /_resolve/index/new-data-stream*
```

#### Reindex a data stream

Set up a new data stream template with the data stream API, creating an empty data stream.

```
PUT /_data_stream/new-data-stream
```

Reindex with `op_type` of create. Can also use single backing indices to preserve order

```
POST /_reindex
{
  "source": {
    "index": " my-data-stream"
  },
  "dest": {
    "index": " new-data-stream",
    "op_type": "create"
  }
}
```

### Data tiers

A data tier is a collection of nodes with the same data role that typically share the same hardware profile.

There are five types of data tiers, a hot → warm → cold → frozen architecture:

- hot tier: have the fastest storage for writing data and for frequent searching
- warm tier: for read-only data that is searched less often
- cold tier: for data that is searched sparingly
- frozen tier: for data that is accessed rarely and never updated

Every node is tagged `all` data tiers by default change using the `node.roles` parameter.

Data stream indices are created in the hot tier by default.

Move indices to colder tiers as the data gets older define an index lifecycle management policy to manage this.

#### Configuring an index to prefer a data tier

Set the data tier preference of an index using the `routing.allocation.include._tier_preference` property:

- data_content is the default for all indices
- you can update the property at any time
- ILM can manage this setting for you

```
PUT logs-2024-06
{
  "settings": {
    "index.routing.allocation.include._tier_preference" : "data_hot"
  }
}
```

### Index Lifecycle Management (ILM)

ILM consists of policies that trigger actions, such as:

- `rollover` create a new index based on age, size, or doc count
- `shrink` reduce the number of primary shards
- `force` merge optimize storage space
- `searchable snapshot` saves memory on rarely used indices
- `delete` permanently remove an index

#### Creating an ILM policy

Can be defined in Kibana or using the ILM API:

```
PUT _ilm/policy/my-metrics-policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age": "2m"
          },
          "set_priority": {
            "priority": 100
          }
        },
        "min_age": "0ms"
      },
      "warm": {
        "min_age": "0d",
        "actions": {
          "set_priority": {
            "priority": 50
          },
          "allocate": {
            "number_of_replicas": 1
          }
        }
      },
      "cold": {
        "min_age": "2m",
        "actions": {
          "set_priority": {
            "priority": 0
          },
          "allocate": {
            "number_of_replicas": 0
          }
        }
      },
      "delete": {
        "min_age": "5m",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

ILM workload is run by the scheduler on an interval. This is a cluster wide configuration:

```
PUT _cluster/settings
{
  "persistent": {
    "indices.lifecycle.poll_interval": "30s"
  }
}
```

#### Applying an ILM policy to an index

A policy is bound to a index with the `index.lifecycle.name` setting.

Using index (or component) templates is a great way to manage this:

```
PUT _index_template/my-metrics-ds-template
{
  "priority": 500,
  "template": {
    "settings": {
      "index.lifecycle.name": "my-metrics-policy"
    }
  },
  "data_stream": {},
  "index_patterns": [
    "my_metrics-*-*"
  ],
  "composed_of": [
    "time-series-mappings",
    "time-series-settings"
  ]
}
```

Create a new index:

```
POST my_metrics-service.status-dev/_doc
{
  "@timestamp": "2021-07-04",
  "status": "UP",
  "message": "Service is running."
}
```

Validate that the index is governed by ILM:

```
GET my_metrics-service.status-dev/_settings
```

#### Monitor indices ILM lifecycle

```
GET my_metrics-service.status-dev/_ilm/explain
```

### Snapshots

While replicas do provide redundant copies, they do not protect you against catastrophic failure you will need to keep a complete backup of your data.

Snapshot and restore allows you to create and manage backups taken from a running Elasticsearch cluster takes the current state and data in your cluster and saves it to a repository.

Supported repositories:

- Shared file system: define path.repo in every node
- Read-only URL: used when multiple clusters share a repository
- repository-s3: pluginfor AWS S3 repositories
- repository-azure: pluginfor Microsoft Azure storage
- repository-gcs: pluginfor Google Cloud Storage
- repository-hdfs: pluginstore snapshots in Hadoop

A number of repository destinations are supported, including cloud blobs, a network file system, a URL.

Defining a backup repository:

```
PUT _snapshot/my_repo
{
  "type": "fs",
  "settings": {
    "location": "/mnt/my_repo_folder"
  }
}
```

Backup tips:

- Backups that are sent to the repository are incremental. Deleting.
- Handy for doing Elasticsearch upgrades. You can have a parallel cluster running the latest version, restore the backup to it.

```
PUT _snapshot/ my_repo/my_logs_snapshot_1
{
  "indices": "logs-*",
  "ignore_unavailable": true,
  "include_global_state": true
}
```

#### Automating snapshots

The \_snapshot endpoint can be called manually:

- every time you want to take a snapshot
- at regular intervals using an external tool

Snapshot lifecycle management (SLM) policies are a first class option:

- policies can be created in Kibana
- or using the `_slm` AP

#### Restoring snapshots

```
POST _snapshot/my_repo/my_snapshot_2/ _restore
```

#### Monitoring running snapshots:

```
GET _snapshot/my_repository/_current
```

#### Searchable snapshots

Searching a searchable snapshot index is the same as searching any other index

- when a snapshot of an index is searched, the index must get mounted locally in a temporary index
- the shards of the index are allocated to data nodes in the cluster

In the cold or frozen phase, you configure a searchable snapshot by selecting a registered repository.

Edit your ILM policy to add a searchable snapshot to your `cold` or `frozen` phase.

- ILM will automatically handle the index mounting
- the cold phase uses fully mounted indices
- the frozen phase uses partially mounted indices

If the delete phase is active, it will delete the searchable snapshot by default. Disable this with `delete_searchable_snapshot: false`

If your policy applies to a data stream, the searchable snapshot will be included in searches by default

In the following ILM policy note the use of `searchable_snapshot` in the `cold` phase:

```
PUT _ilm/policy/my-metrics-policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age": "2m"
          },
          "set_priority": {
            "priority": 100
          }
        },
        "min_age": "0ms"
      },
      "warm": {
        "min_age": "0d",
        "actions": {
          "set_priority": {
            "priority": 50
          },
          "allocate": {
            "number_of_replicas": 1
          }
        }
      },
      "cold": {
        "min_age": "2m",
        "actions": {
          "set_priority": {
            "priority": 0
          },
          "allocate": {
            "number_of_replicas": 0
          },
          "searchable_snapshot": {
            "snapshot_repository": "snap-repo"
          }
        }
      },
      "delete": {
        "min_age": "5m",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

#### Snapshot Lifecycle Management (SLM) policies

An SLM policy automatically takes snapshots on a preset schedule. The policy can also delete snapshots based on retention rules you define.

```
PUT _slm/policy/my-daily-snaps
{
  "schedule": "0 30 1 * * ?",
  "name": "<my-daily-{now/d}>",
  "repository": "snap-repo",
  "config": {},
  "retention": {
    "max_count": 3
  }
}
```

Instead of waiting for the scheduler, can run the SLM policy on-demand:

```
POST _slm/policy/nightly-snapshots/_execute
```

SLM policies can be monitored:

```
GET _slm/stats
GET _slm/policy/my-daily-snaps
```

### Multi-field Search

A convenient shorthand for searching across many fields:

```
GET blogs/_search
{
    "query": {
        "multi_match": {
            "query": "shay banon",
            "fields": [
                "title",
                "content",
                "author"
            ],
            "type": "best_fields"
        }
    }
}
```

### Boosting

You can put more weight when particular fields, using the caret `^` symbol. Here the title is being boosted:

```
"query": {
"multi_match": {
"query": "shay banon",
"fields": [
"title^2",
"content",
"author"
],
"type": "best_fields"
```

To boost it even further `title^3` and so on. Boosting can also be applied to the `bool` clause. Boosting can be used to penalise a result e.g. `title^0.5`

TODO: P.358 `match_phrase`

### Fuzziness

Levestein distinst. Refers to the number of single character edits required to get a match. Because this is such an expensive opereation, Elasticsaerch caps the fuzziness at 2.

    GET blogs/_search
    {
      "query": {
        "match": {
          "content": {
            "query": "shark",
            "fuzziness": 1
          }
        }
      }
    }

Hot tip: use a `fuzziness` setting of `auto`, to dynamically adjust when it should be applied. Consider for example applying a fuzziness of 2 to a 2 character search term such as _hi_. This would hit any 4 character terms across the whole index. Pointless.

### Exact Terms

- Explicitly use the keyword field on a field, for example `category.keyword`.
- Exact keyword matches should often be applied in the filter context.

### Sorting

Simple sorting, removes the need to score results, which ES will jump at as its a huge optimisation:

    GET blogs/_search
    {
      "query": {
        "match": {
          "content": "security"
        }
      },
      "sort": [
        {
          "publish_date": {
            "order": "desc"
          }
        }
      ]
    }

If you want the score, specify `_score` as a term first, then additiaonal search terms after it.

### Paging

Built-in support for paginating results:

    GET blogs/_search
    {
      "from": 10,
      "size": 10,
      "query": {
        "match": {
          "content": "elasticsearch"
        }
      }
    }

Caution, this is very ineffcient if doing deep pagination. In this case, you should leverage the `search_after` option:

    GET blogs/_search
    {
      "size": 10,
      "query": {
        "match": {
          "content": "elasticsearch"
        }
      },
      "sort": [
        {
          "_score": {
            "order": "desc"
          }
        },
        {
          "_id": {
            "order": "asc"
          }
        }
      ],
      "search_after": [
        0.55449957,
        "1346"
      ]
    }

### Highlighting

Enables a search term result to be wrapped in a tag for later rendering in a UI. By default will wrap in the `<em>`.

```
GET blogs/_search
{
    "query": {
        "match_phrase": {
            "title": "kibana"
        }
    },
    "highlight": {
        "fields": {
            "title": {}
        },
        "pre_tags": ["<es-hit>"],
        "post_tags": ["</es-hit>"]
    }
}
```

## Best Practices

### Index Aliases

Think symbolic linking for indices. Avoid coupling clients to underlying index. For example, the frontend index alias might be called _blogs_ and the underlying index _blogs_v1_.

Aliases can also have filters built-in to them, for example only documents that relate to the engineering department.

The indices that make up an aliases:

    POST _aliases
    {
      "actions": [
        {
          "add": {
            "index": "logs-2018-07-05",
            "alias": "logs-write"
          }
        },
        {
          "remove": {
            "index": "logs-2018-07-04",
            "alias" : "logs-write"
          }
        }
      ]
    }

### Scroll Search

Allows you take a snapshot of results (they result will not be impacted as new document get added/deleted from the index). Can have a maximum of 1000 results.

General tips and tricks:

- Copy as curl from Kibana.
- Kibana can format JSON is pretty print (for humans) or single line format for use with the bulk API, with ctrl+i.
- Curator is an Elastic product like `cron`?
- Sorting by `_doc` is the fastest possible way to order results (because its the same order within the physical shard).

## Cluster management

Various cluster state includes, indices, mappings, settings, shard allocation.

```
GET _cluster/state
```

### Cross cluster replication

Cross-cluster replication (CCR) enables replication of indices across clusters and active-passive model:

- you index to a leader index,
- the data is replicated to one or more read-only follower indices

You need a user that has the appropriate roles, and configure the appropriate TLS/SSL certificates.

```
PUT copy_of_the_leader_index/_ccr/follow
{
  "remote_cluster" : "cluster2",
  "leader_index" : "index_to_be_replicated"
}
```

#### Auto following

Useful when your leader indices automatically rollover to new indices you follow a pattern (instead of a static index name)

```
PUT _ccr/auto_follow/logs
{
  "remote_cluster" : "cluster2",
  "leader_index_patterns" : [ "logs*" ],
  "follow_index_pattern" : "{{leader_index}}-copy"
}
```

### Cross cluster searching

Enables the execution of a query across multiple clusters.

To perform a search across multiple clusters, list the cluster names and indices you can use wildcards for the names of the remote clusters:

```
GET blogs,EMEA_DE_cluster:blogs,APAC_*:blogs/_search
{
  ...
}
```

Run a query across a remote cluster and the local cluster:

```
GET cluster2:blogs,blogs/_search
{
  "query": {
    "match_phrase": {
      "content": "kibana query language"
    }
  }
}

```

### Configuration

Settings to various artifacts are applied at various levels:

- Index level, `PUT fooindex/_settings { "index.block.writes": true }`
- Node level, the `elasticsearch.yml`
- Cluster level, `PUT _cluster/settings { "persistent": { "discovery.zen.minimum_master_nodes": 2 } }`. Note the `persistent` setting, this will be written to the filesystem somewhere. Similarly a `transient` property is supported.

Precedence of settings:

1. Transient settings
2. Persistent settings
3. CLI arguments
4. Config files

Interesting state to be aware of:

- Routing table
- Node currently elected the master

The minimum number of nodes in an ES cluster must be 3, to avoid split brain master nodes.

### Troubleshooting

#### Cluster health

A high level traffic light indicator via `GET _cluster/health`, which indicates the health of shard layout.

Hot tip: You can block until a desired yellow or green status has been arrived to `GET _cluster/health?wait_for_status=yellow`.

Either green, yellow, or red and exists at three levels: shard, index, and cluster

- green: all shards are allocated
- yellow: all primaries are allocated, but at least one replica is not
- red: at least one primary shard is not allocated in the cluster

#### CAT APIs

The compact and aligned text (CAT) API can help:

- `_cat/thread_pool`
- `_cat/shards`
- `_cat/health`

CAT APIs are only for human consumption, use the JSON API for programmatic access.

#### Thread Pool Queues

Thread pools are used to handle cluster tasks (bulk, index, get, search).

Thread pools are fronted by queues, when full, a HTTP 429 is returned.

```
GET _cat/thread_pool
GET _nodes/stats/thread_pool
```

Example:

```
"write": {
  "threads": 8,
  "queue": 0,
  "active": 0,
  "rejected": 0,
  "largest": 8,
  "completed": 177
}
```

The `cat` API can be used to keep an eye on thread pools `GET _cat/thread_pool?v`:

    node_name name                active queue rejected
    node5     analyze                  0     0        0
    node5     ccr                      0     0        0
    node5     fetch_shard_started      0     0        0
    node5     fetch_shard_store        0     0        0
    node5     flush                    0     0        0
    ...

A full queue may be good or bad (“It depends!”)

- OK if bulk indexing is faster than ES can handle
- bad if search queue is full

#### Hot threads and tasks

If you do have thread pools that seem too busy, try looking at the running tasks and hot threads.

- `GET _tasks`: the running tasks on the cluster
- `GET _cluster/pending_tasks`: any cluster-level changes that have not yet executed
- `GET _nodes/hot_threads`: threads using high CPU volume and executing for a long time

What are the nodes busiest doing:

```
GET _nodes/hot_threads
```

Or a specific node:

```
GET _nodes/node123/hot_threads
```

#### The Profile API

Awesome feature! Just pass a `"profile": true` along with your search request.

Make sure to use the Kibana _Search Profiler_ functionality (which sits next to the _Dev Console_).

You can dump the profiler results, and simply plug it into the _Search Profiler_. These are JSON, so can be easily stored, and analysed offline at a later stage, or even offsite.

### Monitoring

To monitor the Elasticsearch you can use...the Elastic Stack.

- Metricbeat to collect metrics
- Filebeat to collect logs

We recommend using a dedicated cluster for monitoring:

- to reduce the load and storage on the monitored clusters
- to keep access to Monitoring even for unhealthy clusters
- to support segregation of duties (separate security policies)

### Optimizing search performance

#### Unnecessary Scripting

Avoid running calculations at query time, and instead stored the calculation at index time perhaps using an ingest pipeline.

Make search faster by transforming data during ingest instead slower index speeds, but faster query speeds.

#### Search Slow Log

Very similar, index specifc setting using `index.search.slowlog`, threadholds of millis would make more sense here.

```
PUT my_index/_settings
{
  "index.search.slowlog": {
    "threshold": {
      "query": {
        "info": "5s"
      },
      "fetch": {
        "info": "800ms"
      }
    }
  }
}
```

#### Indexing Slow Log

Can log information about long running index operations. Various log4j thresholds can be mapped to index timings on the index specific `_settings`. Log file on disk is configured in the `log4j2.properties`.

#### Always Filter

Benefits from:

- Not scoring
- The _filter cache_ (bit sets).

#### Aggregating Too Many Docs

Always consider pairing an aggregation with a query to trim the result set the aggregation is applied to.

Use a filter bucket! Allows a filter to be bolted into an aggregate. This could be in turned paired with an outer query.

A _Sampler Aggregation_ can be used to cut off the noisy tail (think bell curve tail) of a large data set.

#### Denormalise First

#### Too many shards

#### Search profiler

Visualization of search performance of queries and aggregations per shard.

Set `profile` to `true` to profile your search, you can copy-and-paste the response into Search Profiler.

```
GET web_traffic/_search
{
  "size": 0,
  "profile": true,
  "aggs": {
    "top_os": {
      "terms": {
        "field": "user_agent.os.full.keyword",
        "size": 20
      }
  ...
```

Another example:

```
GET blogs_fixed2/_search
{
  "profile": true,
  "_source": [""],
  "query": {
    "function_score": {
      "query": {
        "match_all": {}
      },
      "script_score": {
        "script": """
          void slow() {
            for (int x = 0; x < 10000; ++x)
              Math.log(x);
          }

          for (int x = 0; x < 3; ++x)
            slow();
        """
      }
    }
  }
}
```

#### Relevance tuning

Get the “best” results at the top of your hit list no need to come back for the second or third page of hits.

It's all about manipulating the `_score`

Per field boosting:

```
GET blogs_fixed2/_search
{
  "_source": [
    "title"
  ],
  "query": {
    "multi_match": {
      "query": "boosting",
      "fields": [
        "content",
        "title^1.4"
      ]
    }
  }
}
```

By default, the maximum score from the two field to compute the final score. Update the previous query to use the sum of the field scores instead of using the default `best_fields`, by changing the type of the `multi_match` to `most_fields`.

Index boosting:

```
GET blogs*/_search
{
  "indices_boost": [
    { "blogs-2022": 2.0 },
    { "blogs-2021": 1.5 }
  ]
}
```

Constant scoring assigns a constant value to the `_score`. Here all blogs by “monica” will have a \_score of 1.5:

```
GET blogs/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "term": { "authors.first_name": "monica" }
      },
      "boost": 1.5
} } }
```

Scripted scoring uses painless to calculate teh score:

```
GET my_web_logs/_search
{
"query": {
"script_score": {
"query": {
"match": { "message": "elasticsearch" }
},
"script": {
"source": "_score / doc['resp_ms'].value"
}
} } }
```

#### Ways to improve searches

The _node query cache_ are where results of filter contexts are cached. Its a big benefit of using filters.

- By default stores 10,000 queries (or up to 10% of heap)
- Can be modified with the `indices.queries.cache.size` setting

The _shard request cache_ caches complete search results. Only applies to queries with a `size=0` (i.e. aggregations).

Query performance generally involves locating expensive queries and remediating:

- `fuzzy`, `regex`, `wildcard` should run on fields of type `wildcard`
- Move from query to ingest time

Aggregation performance involves narrowing the breadth of search:

- Apply in addition to a `query` if possible
- Use a `sampler` or `diversified_sampler` aggregation to sub-sample top hits
- Use a Kibana filter and runtime field with random values to filter out a random sampling of the hits

## Working examples

### Index with custom analyzer, metadata and mappings

```
PUT blogs_fixed2
{
  "settings": {
    "analysis": {
      "analyzer": {
        "content_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "char_filter": [
            "html_strip"
          ],
          "filter": [
            "lowercase"
          ]
        }
      }
    }
  },
  "mappings": {
    "_meta": {
      "created_by": "Benjamin S"
    },
    "properties": {
      "authors": {
        "properties": {
          "company": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "first_name": {
            "type": "keyword"
          },
          "full_name": {
            "type": "text"
          },
          "job_title": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          },
          "last_name": {
            "type": "keyword"
          },
          "uid": {
            "enabled": false
          }
        }
      },
      "category": {
        "type": "keyword"
      },
      "content": {
        "type": "text",
        "analyzer": "content_analyzer"
      },
      "locale": {
        "type": "keyword"
      },
      "publish_date": {
        "type": "date",
        "format": "iso8601"
      },
      "tags": {
        "properties": {
          "elastic_stack": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          },
          "industry": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          },
          "level": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          },
          "product": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          },
          "tags": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          },
          "topic": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          },
          "use_case": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          },
          "use_cases": {
            "type": "keyword",
            "doc_values": false,
            "copy_to": "search_tags"
          }
        }
      },
      "title": {
        "type": "text"
      },
      "url": {
        "type": "keyword"
      },
      "search_tags": {
        "type": "keyword"
      }
    }
  }
}

---

POST _reindex
{
  "source": {
    "index": "blogs"
  },
  "dest": {
    "index": "blogs_fixed2"
  }
}
```
