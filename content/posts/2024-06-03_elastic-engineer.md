---
layout: post
draft: true
title: "Elasticsearch Engineer 8.1"
slug: "elasticsearch"
date: "2024-06-02 18:46:01"
lastmod: "2024-05-18 14:39:30"
comments: false
categories:
  - elastic
tags:
  - elasticsearch
  - logstash
  - kibana
---

Revised 2024 edition based on Elasticsearch 8.1.

Recently the opportunity to attend this 4-day training on the core Elasticsearch engine has come my way, which I did in-person about 5 years ago in Sydney. Elasticsearch has always been an integral part of the data solutions I've been involved with and I'm quite fond of it. This time round the course now only runs in a virtual class room format (using strigo.io), our trainers in this instance are Krishna Shah and Kiju Kim.

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
    - [Search API](#search-api)
    - [Query and Filter Contexts](#query-and-filter-contexts)
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
  - [The reindex API](#the-reindex-api)
- [You know, for search](#you-know-for-search)
- [Cluster state](#cluster-state)
- [Shards](#shards)
- [Anatomy of Search (Shards)](#anatomy-of-search-shards)
  - [Troubleshooting](#troubleshooting)
    - [Configuration](#configuration)
- [Responses](#responses)
    - [Cluster and Shard Health](#cluster-and-shard-health)
- [Diagnosing Issues](#diagnosing-issues)
- [Optimising search performance](#optimising-search-performance)
  - [Multi-field Search](#multi-field-search)
  - [Boosting](#boosting)
  - [Fuzziness](#fuzziness)
  - [Exact Terms](#exact-terms)
  - [Sorting](#sorting)
  - [Paging](#paging)
  - [Highlighting](#highlighting)
- [Aggregations](#aggregations)
- [Best Practices](#best-practices)
  - [Index Aliases](#index-aliases)
  - [Index Templates](#index-templates)
  - [Scroll Search](#scroll-search)
  - [Cluster Backup](#cluster-backup)
- [Questions](#questions)
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

#### Search API

- _Precision_ is the ratio of true positives vs the total number returned (true and false positives combined). Its tempting to constrain the net of results to improve precision. This is a tradeoff with recall which will drop.
- _Recall_ is the ratio of true positives vs the sum of all documents that should have been returned. By widening the net (by using partial matches).
- Scoring is done by 1950's technique known as TF/IDF. TF (term frequency) the more a term exists the more relevant it is. IDF (inverse document frequency) the more documents that contain the term the less relevant it is.
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
- Date math is now supported `"gte": "now-3M"`, or `"now+1d"`
- A _bool_ query allows a number a conditions to be articulated using the; _must_, `must_not`, `should` and `filter`. `filter` is similar to the `WHERE` clause in a SQL statement. Its not an optional

#### Query and Filter Contexts

- `should` and `must` influence the score, and operate in the _query context_, and determine the shade of grey a match result it by scoring it. Its is handy to combine them, a `must` with several `should`'s will
- The `must_not` and `filter` options operate in what is known as the _filter context_, and is black and white, results MUST meet the crtieria. A result can't be more January than another, they are just January.
- When a search with only `should`'s is specified, this will implicitly define a `minimum_should_match` term of 1.
- A `should` could nest a `bool` that in turn contains a `must_not` to down score documents if they contain a certain term.
-

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
○ have documents with a large number of fields
○ or don't know the fields ahead of time
○ or want to change the default mapping for certain field types
Use dynamic templates to define a field’s mapping based on one of
the following:
○ the field’s data type
○ the name of the field
○ the path to the field

### Inverted Index

Very similar to the index in the back of a book. Common terms, and where they are located in a convenient lookup structure. Lucene similarly creates this _inverted index_ with text fields.

- Text is broken apart (tokenised) into individual terms. These are converted to lower case, and special characters are stripped.
- Interestingly the search query is also tokenised by the analyzer in the same way.
- The inverted index is ordered. For search efficiency, allows algorithms like binary search to be used.
- Elasticsearch default analyzer does not apply stop words by default. This is also handled much better by DM25 now, than traditional TF/IDF.
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

### The reindex API

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


## You know, for search

TODO


## Cluster state

Various cluster state includes, indices, mappings, settings, shard allocation.

    GET _cluster/state

Interesting state to be aware of:

- Routing table
- Node currently elected the master

The minimum number of nodes in an ES cluster must be 3, to avoid split brain master nodes.

## Shards

Every document is stored in a single (Lucene) shard.

There are two types:

- Primary, the original shards of an index. They are number using a zero based index, i.e. first shard is shard 0.
- Replica, a clone of the primary. The default setting is 1 replica per primary shard. Replicas, like primaries, can be used for querying.

How to see shard allocations? By checking out the routing table from the cluster state.

    PUT fooindex
    {
      "settings": {
        "number_of_shards": 3,
        "number_of_replicas": 2
      }
    }

Shard tips:

- The number of primary shards can't be changed.
- The number of replicas however, can be changed.
- More replicas increases read throughput.
- Useful for managing bursts of resources (e.g. ebay during the xmas period), the number of data nodes and replicas can be increased dynamically on the existing cluster.
- The hashing algorithm called [murmur3](https://en.wikipedia.org/wiki/MurmurHash) modulo the total number of shards, is used to determine the shard number to assign to a specific document.
- Updates and deletes are actually difficult to manage in this distributed system, and are essentially treated as immutatble entites.
- An index operation must occur on the primary shard, prior to being done on any replicas.

## Anatomy of Search (Shards)

- Each shard is required to run the query locally.
- Each shard returns its best results, to the coordinating node, which is responsible for globally merging the results.
- The TF/IDF algorithm, the term frequency make sense even when calculated locally to the shard.
- With the default, fetch-then-query behaviour, IDF (document frequency) can be skewed when its calculated locally on the shard. IDF would be very expensive to calculate globally across the cluster. Interestly in practice, this is rarely an issue, especially when you have a large dataset that is evenly distributed across shards, as an even sampling exists.
- A global IDF can be computed if desired, by setting the `search_type` to `dfs_query_then_fetch`, and useful for testing on small datasets, `GET blogs/_search?search_type=dfs_query_then_fetch`

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

### Troubleshooting

#### Configuration

Settings to various artifacts are applied at various levels:

- Index level, `PUT fooindex/_settings { "index.block.writes": true }`
- Node level, the `elasticsearch.yml`
- Cluster level, `PUT _cluster/settings { "persistent": { "discovery.zen.minimum_master_nodes": 2 } }`. Note the `persistent` setting, this will be written to the filesystem somewhere. Similarly a `transient` property is supported.

Precedence of settings:

1. Transient settings
2. Persistent settings
3. CLI arguments
4. Config files

## Responses

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

## Diagnosing Issues

Traffic light indicator via `GET _cluster/health`. Alternative you can block until a desired yellow or green status has been arrived to `GET _cluster/health?wait_for_status=yellow`.

TODO

## Optimising search performance

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

## Aggregations

Basically a `GROUP BY` clause.

Types of aggregations:

- Bucket, uses a field within the document type to aggregate on. For example, people by gender. Buckets can be nested. People by country, by gender for example. Buckets can also be sorted by its `_key` (the value of the in context bucketing term).
- Metrics, the usual aggregation suspects, `count`, `max`, `min`, `cardinality`, etc statistically summarize documents
- Term, what the biggest contributor (e.g. by country) of a specific search term. Term aggregation are not precise due to a distributed computing problem, where aggregates are calculated per shard by each data node, which is then in turn tallied up by the coordinating node. To avoid this, you can ask that more aggregation results be returned to the coordinator, to avoid inaccurate tallying, by specifying a `"shard_size": 500`

Example term (bucket) aggregation:

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

Example metric aggregation:

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

Tricks:

- Set a `"size": 0` to completely strip everything, but the aggregate result itself.
- Queries and aggregations can be coupled together.

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

### Index Templates

Blueprints for indices when their name matches a pattern. For controlling things like:

- Shard configuration
- Replica configuration

Multiple templates can be applied to an index, depending on the name matching rules that are evaluated. An `order` value in the template helps to battle.

### Scroll Search

Allows you take a snapshot of results (they result will not be impacted as new document get added/deleted from the index). Can have a maximum of 1000 results.

### Cluster Backup

Based on the _Snapshot and Restore API_. A number of repository destinations are supported, including cloud blobs, a network file system, a URL.

Defining a backup repository:

    PUT _snapshot/my_repo
    {
      "type": "fs",
      "settings": {
        "location": "/mnt/my_repo_folder"
      }
    }

Different providers are provided as Elasticsearch plug-ins:

Backup tips:

- Backups that are sent to the repository are incremental. Deleting.
- Handy for doing Elasticsearch upgrades. You can have a parallel cluster running the latest version, restore the backup to it.

General tips and tricks:

- Copy as curl from Kibana.
- Kibana can format JSON is pretty print (for humans) or single line format for use with the bulk API, with ctrl+i.
- Curator is an Elastic product like `cron`?
- Sorting by `_doc` is the fastest possible way to order results (because its the same order within the physical shard).

## Questions

- Elastic agent vs beats
- logstash
- ingest pipelines
- recommendations for disk speed and network speed between nodes
- running on kubernetes

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
