---
layout: post
title: "Elasticsearch Basics"
date: "2019-03-25 09:26:01"
comments: false
categories:
- elastic
tags:
- elastic
---

Some Elasticsearch wisdom I gleaned from Jason Wong and Mark Laney from Elastic.

**Contents**

- [Use cases](#use-cases)
- [Log stash vs Beats?](#log-stash-vs-beats)
- [Time Series vs Static Data](#time-series-vs-static-data)
- [Logstash](#logstash)
- [Installation](#installation)
- [Starting and Stopping Elasticsearch](#starting-and-stopping-elasticsearch)
  - [Killing](#killing)
- [Communication](#communication)
  - [Discovery module (networking)](#discovery-module-networking)
  - [Security](#security)
    - [Read-only](#read-only)
    - [Enabling X-Pack (Elasticsearch Security)](#enabling-x-pack-elasticsearch-security)
- [CRUD](#crud)
  - [Ingestion](#ingestion)
  - [Reading](#reading)
- [Search](#search)
  - [Query and Filter Contexts](#query-and-filter-contexts)
- [Mapping](#mapping)
- [Inverted Index](#inverted-index)
- [Multi Fields (keyword fields)](#multi-fields-keyword-fields)
- [Anatomy of an Analyzer](#anatomy-of-an-analyzer)
  - [Custom Analyzer](#custom-analyzer)
- [The reindex API](#the-reindex-api)
- [Node Types](#node-types)
  - [Cluster state](#cluster-state)
- [Shards](#shards)
  - [Anatomy of Search (Shards)](#anatomy-of-search-shards)
- [Troubleshooting](#troubleshooting)
  - [Configuration](#configuration)
  - [Responses](#responses)
  - [Cluster and Shard Health](#cluster-and-shard-health)
  - [Diagnosing Issues](#diagnosing-issues)
- [Improving Search Results](#improving-search-results)
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



# Use cases

* Search
* Logging
* Metrics - unlike logs, are typically not in a text format.
* Business analytics - the aggregation and analysis of patterns (e.g. bucketing aggregations, ML jobs)
* Security analytics - 


# Log stash vs Beats?

* *Beats* are lightweight data shippers, but are not appropriate for ETL type stashing.
* *Logstash* on the other hand, can take handle these concerns. But requires a much heavier runtime (JVM).

An official SIEM solution is currently under development.


# Time Series vs Static Data

Data being tipped into Elasticsearch can very generally be categorised as either static or time series.

* Static - large data sets, that change rarely over its lifetime (e.g. blogs, cataloges, tax returns)
* Time Series - event data, that changes frequently over time (logs, metrics)



# Logstash

* The built-in *help* is actually really useful, `logstash --help`
* Check out cool feature *Elastic Filter* for doing a real-time lookup, to enrich incoming documents with extra data.

Sample logstash pipeline, which streams records from a PostgreSQL DB into an index:

    input {
      jdbc {
        jdbc_connection_string => "jdbc:postgresql://db_server:5432/"
        jdbc_driver_class => "org.postgresql.Driver"
        jdbc_driver_library => "/home/elastic/postgresql-9.1-901-1.jdbc4.jar"
        jdbc_user => "postgres"
        jdbc_password => "password"
        statement => "SELECT * from blogs"
      }
    }
    
    filter {
      mutate {
        remove_field => ["@version", "host", "message", "@timestamp", "id", "tags"]
      }
    }
    
    output {
      stdout { codec => "dots"}
      elasticsearch {
        index => "blogs"
      }
    }

A file system based example. Note the `start_position` setting which will ingest existing data in the monitored files:

    input {
      file {
        path => "/opt/data/elastic_blogs/**/*.log"
        codec => "json"
        sincedb_path => "/dev/null"
        start_position => "beginning"
      }
    }
    
    filter {
      date {
        match => [ "date", "MMMM dd, yyyy" ]
        target => "publish_date"
        remove_field => [ "date" ]
      }
      mutate {
        remove_field => [ "@version", "path", "host", "message", "tags", "@timestamp" ]
      }
    }
    
    output {
      stdout { codec => "dots" }
      elasticsearch {
        hosts => [ "cantina:9200" ]
        index => "blogs"
        user => "elastic"
        password => "password"
      }
    }


To run:

    logstash -f ~/blogs-pipeline.conf --log.level=trace --path.settings /etc/logstash --path.logs=/var/log/logstash

Or if using stdin as an input module, standard shell pipes or redirects:

    logstash -f /opt/data/blogs_csv_pipeline.conf --path.settings /etc/logstash --path.logs=/var/log/logstash < /opt/data/blogs.csv



# Installation

Important directories to be mindful of:

* `ES_PATH_CONF` defines the root where all ES configuration lives. So its easy to setup portal configuration on new docker containers for example.
* `modules` are *plugins* that are core to running ES.
* `plugins` useful extensions for ES. TODO: look into these.


Always put configuration in the persistent config files such as `jvm.options`. While its possible (and convenient) to define these on the command line such as `-Xms512mb`, this is not designed for long term application.

Top configuration tips:

* Always change `path.data` (never use the local OS volume). Multiple paths are supported `path.data: [/home/elastic/data1,/home/elastic/data2]` all paths will be used.
* The `elasticsearch` binary supports a daemon mode with `-d`, and a `-p` for storing the current ES PID in a text file.
* Default configuration path can be tweaked using `ES_CONF_PATH`
* Set the `node.name` explicitly.
* Set the `cluster.name`
* Have explicit port numbers (when multiple nodes are spun up on a single machine port range 9200-9299 are used)


# Starting and Stopping Elasticsearch

## Killing

    kill `cat elastic.pid`

*TODO (BenS): add more details*



# Communication

REST API interaction (port rnage 9200-9299)

Internode communication between nodes within the cluster (port range 9300-9399)


## Discovery module (networking)

The default module is known as the *zen* module. By default it will sniff the network for 

    discovery.zen.ping.unicast.hosts : ["node1:9300", "node2"]

Network settings, there are 3 top level setting namespaces:

* `transport.*` transport protocol
* `http.*` controlling the HTTP/REST protocol
* `network.*` for defining settings across both the above

Sepcial values for network.host:

* `_local_` loopback
* `_site_` bind to the public network routable IP (e.g. 10.1.1.14)
* `_global_` any globally scoped address
* `_network-interface_` (e.g. `_eth0_` for binding to the addressable IP of a network device)



## Security

Essential infrastructure:

* firewall
* reverse proxy
* elastic security


### Read-only

Consider a *read-only* cluster, for splitting out reads from writes. CCR (cross cluster replication) make this super handy pattern to roll out.

For locking down the REST API, the reverse proxy could lock down to only `GET` requests, for certain auth or IP's.

The same goes for Kibana. Providing read-only dashboards and visualisations.


### Enabling X-Pack (Elasticsearch Security)

Mostly easily down via Kibana, under the Management | License Management

For **Elasticsearch** jump into `elasticsearch.yml` and set `xpack.security.enabled: true`. Then generate some credentials for the built-in accounts:

    ./elasticsearch/bin/elasticsearch-setup-passwords interactive


For **Kibana**, so it can communicate with the now secured Elasticsearch cluster, jump into `kibana.yml` and set:
    elasticsearch.username: "kibana"
    elasticsearch.password: "kibanapassword"

If passwords in cleartext are no go, a encrypted keystore is provided:

    bin/kibana-keystore create

Then load it up with key/value pairs:

    


# CRUD

## Ingestion

Given ES is just a distributed document store, works with managing complex document structures. ES must be represented as JSON. Beat and Logstash are aimed at making this a smooth process.


* An *index* can be related to a table in a relational store, and has a schema (a mapping type).
* ES will automatically infer the *mapping type* (schema) for you, the first time you attempt to store a document.
* A *shard* is one piece of an index (by default there are 5).
* By default, documents will automatically be overridden (version # incremented). If you don't wont auto overrides, use the `_create` API. Similarly there is an `_update` API.
* `DELETE`ing a document, space can be reclaimed.
* The `_bulk` API allows many operations to be loaded up together. One-line per operation (based on the JSON oneline standard)



## Reading

* To query something need to know the (1) cluster, (2) index, (3) mapping type and the (4) id of the specific document
* To obtain multiple document, the `_mget` API is provided.
* The `_search` API exposes the ES searching functionality.



# Search

* *Precision* is the ratio of true positives vs the total number returned (true and false positives combined). Its tempting to constrain the net of results to improve precision. This is a tradeoff with recall which will drop.
* *Recall* is the ratio of true positives vs the sum of all documents that should have been returned. By widening the net (by using partial matches).
* Scoring is done by 1950's technique known as TF/IDF. TF (term frequency) the more a term exists the more relevant it is. IDF (inverse document frequency) the more documents that contain the term the less relevant it is.
* [Okapi BM25](https://en.wikipedia.org/wiki/Okapi_BM25) is the 25th iteration of TF/IDF and is the default used by ES
* [Claude Shannon](https://en.wikipedia.org/wiki/Claude_Shannon) in 1925 discovered that information content = log 2 * 1/P, and this has been factored into BM25.



Two methods:

* *Query string* can be encoded in the HTTP URL.
* *Query DSL* a full blown JSON based DSL.
* When querying, only pull back fields that you are interested (or not) in with the `_source` option, for example `"source": [ "excludes": "content" ]`
* To increase precious (and drop recall) include the `operator` option set to `and` (by deafult the `or` operator applies) e.g:

Snippet:

    "query": "ingest nodes",
    "operator": "and"

* `minimum_should_match` instructs that a minimum number of search terms need to match.
* `match_phrase` specifies an exact match e.g. *a new way* must include all terms in the specific sequence.
* If the search was *open data* was searched the `slop` option can relax (or tighten) the search, by specifying hte number of terms that can exist between each search term
* Date math is now supported `"gte": "now-3M"`, or `"now+1d"`
* A *bool* query allows a number a conditions to be articulated using the; *must*, `must_not`, `should` and `filter`. `filter` is similar to the `WHERE` clause in a SQL statement. Its not an optional 


## Query and Filter Contexts

* `should` and `must` influence the score, and operate in the *query context*, and determine the shade of grey a match result it by scoring it. Its is handy to combine them, a `must` with several `should`'s will 
* The `must_not` and `filter` options operate in what is known as the *filter context*, and is black and white, results MUST meet the crtieria. A result can't be more January than another, they are just January.
* When a search with only `should`'s is specified, this will implicitly define a `minimum_should_match` term of 1.
* A `should` could nest a `bool` that in turn contains a `must_not` to down score documents if they contain a certain term.
* 


TODO: Include table on P.164 of Engineer I notes.

TODO: Include *should not* query, and *search tip for phrases*

If a user searches  TODO: continue from Engineer I notes from P.175



# Mapping

Basically a schema, with field level definitions such as data typing.

To view the mapping for an index via the API `GET fooindex/_mapping`

* A data type of text means that is can be ripped apart as tokens.
* The keyword, instructs ES to keyword analyse the field.
* Prior to version 6.0, a concept known as *document types* within the same index were supported. This was a design flaw, and removed. Spliting out into separate indexes is now required. Cross index searching is well supported, so this isn't really a big deal e.g. `GET uni_student,uni_lecturer/_search`
* A nested data type is supported, for supporting parent child hierarchies.
* The `keyword` data type is used for exact value strings, and `text` for full text searchable fields.
* Specialised types like `geo_point` and `geo_shape` are supported.
* The `percolator` type, TODO investigate this.
* Be aware of the automatic inferred mappings that ES does, while convenient, typically makes a number of errors when typing fields.


# Inverted Index

Very similar to the index in the back of a book. Common terms, and where they are located in a convenient lookup structure. Lucene similarly creates this *inverted index* with text fields.

* Text is broken apart (tokenised) into individual terms. These are converted to lower case, and special characters are stripped.
* Interestingly the search query is also tokenised by the analyzer in the same way.
* The inverted index is ordered. For search efficiency, allows algorithms like binary search to be used.
* Elasticsearch default analyzer does not apply stop words by default. This is also handled much better by DM25 now, than traditional TF/IDF.
* *Stemming* words like "node" and "nodes" to return the same match. By default, Elasticsearch does not apply stemming. Some examples, configuring > configur, ingest > ingest, pipeline > pipelin


# Multi Fields (keyword fields)

* `text` fields are broken down into pieces, and are not appropriate for doing literal text comparisons. For example "I like Elasticsearch!" will strip the special characters, casing and the sequence of terms.


    "comment": {
      "type": "text",
      "fields": {
        "keyword": {
          "type": "keyword",
          "ignore_above": 256
        }
      }
    },

The above requires two inverted indexes. One for the text (tokens) and the keyword (the literal itself).

In the above comment example, when doing a match filter for example you can explicitly use the `keyword` field by searching only `comment.keyword`.





# Anatomy of an Analyzer

Made up from:

* Character filters, allow junk in the document field to be ignored. Imagine a document field that contains HTML markup, lots of tags and angel brackets, that add no value in a search.
* Tokenizer, for splitting up terms into pieces
* Token filters

Some built-in analyzers include: 

* Standard, no character filters, standard tokenizer, lowercases all terms, and optionally removes stop words.
* Simple, breaks text into terms whenever a non-alpha character is found
* 

The `_analyze` API is handy for testing how different analyzers behave.

    GET _analyze
    {
      "analyzer": "simple",
      "text": "How to configure ingest nodes?"
    }

Check out the [docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis.html) for more.


The stop analyzer:

    GET _analyze
    {
      "analyzer": "stop",
      "text": "Introducing beta releases: Elasticsearch and Kibana Docker images!"
    }


The keyword analyzer:

    GET _analyze
    {
      "analyzer": "keyword",
      "text": "Introducing beta releases: Elasticsearch and Kibana Docker images!"
    }

The english analyzer, includes stemming and lowercasing.

    GET _analyze
    {
      "analyzer": "english",
      "text": "Introducing beta releases: Elasticsearch and Kibana Docker images!"
    }







## Custom Analyzer

Can be created on the index:

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

And to test it out:

    GET analysis_test/_analyze
    {
      "analyzer": "my_analyzer",
      "text": "C++ can help it and your IT systems."
    }



Some reasons for doing this:

* You want to tokenize a comma delimitered field within the document.
* Language specific analyzer (e.g. spanish, english).
* Stop words, terms that are just noise and add little value in search.
* Stemming (with the snowball filter) to boil down words to their roots.
* Token filters are applied in the sequence they are defined.
* Mapping terms of interest into a common representation, such as C++, c++, CPP should all map to cpp.


TODO: For fun, try to create a custom filter for handling Aussie names (baz to barry)



Standard tokenizers:

* whitespace does not lowercase terms and does not remove punctuation
* 


Token filters are applied with the `filter` keyword. There are [dozens](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-tokenfilters.html) of built-in filters.

* Snowball filter for applying stemming back words to their root ([Snowball](http://snowball.tartarus.org/texts/introduction.html) is an agnostic stemming definition language)
* Lowercase
* Stop words, in addition to the [standard stopwords](https://github.com/apache/lucene-solr/tree/master/lucene/analysis/common/src/resources/org/apache/lucene/analysis/snowball)  provided by the underlying Lucene engine.
* Mapping filter e.g. *X-Pack* to *XPack*
* ASCII Folding is used for stripping and normalising special ASCII characters, and open/closing tags in XML representations
* Shingle filter
* Many more




# The reindex API

The `_reindex` API clones one index to another index.

A handy pattern is to reindex an index into a temporary staging index. Test apply custom analyzers or mappings etc. If successful, reindex the staging index back to the live index.

Beware for large indexes, as this can take a significant amount of time. TODO checkout scrolling and some internals around this.





# Node Types

A node can take on several roles:

* Master (low CPU, low RAM, low I/O), the leader of the cluster, manages the creation/deletion of indices, adding/deleting nodes, adding/deleting shards. By default all nodes are `node.master` enabled and are eligible for master. The number of votes needed to win an election is defined by `discovery.zen.minimum_master_nodes`. It should be set to *N / 2 + 1* where N is the number of master eligible nodes. Very important to configure to avoid split brain (possible multiple and inconistent master nodes). Recommendation is to have 3 master eligible nodes, with `minimum_master_nodes` set to 2.
* Data nodes (high CPU, high RAM, high I/O)
* Ingest (high CPU, medium RAM, low I/O), for providing simple ingest pipelines targetting at administrators (not comfortable with scripting or programming)
* Coordinating (high CPU, high RAM, low I/O), like a dating service, responsible for connecting nodes and roles. A smart load balancer.
* Machine Learning

Role assignment is managed in `elasticsearch.yml`:

* `node.master` to true (by default)
* `node.data` to true (by default)
* `node.ingest` to true (by default)


## Cluster state

Various cluster state includes, indices, mappings, settings, shard allocation.

    GET _cluster/state

Interesting state to be aware of:

* Routing table
* Node currently elected the master


The minimum number of nodes in an ES cluster must be 3, to avoid split brain master nodes.




# Shards

Every document is stored in a single (Lucene) shard.

There are two types:

* Primary, the original shards of an index. They are number using a zero based index, i.e. first shard is shard 0.
* Replica, a clone of the primary. The default setting is 1 replica per primary shard. Replicas, like primaries, can be used for querying.


How to see shard allocations? By checking out the routing table from the cluster state.

    PUT fooindex
    {
      "settings": {
        "number_of_shards": 3,
        "number_of_replicas": 2
      }
    }


Shard tips:

* The number of primary shards can't be changed.
* The number of replicas however, can be changed.
* More replicas increases read throughput.
* Useful for managing bursts of resources (e.g. ebay during the xmas period), the number of data nodes and replicas can be increased dynamically on the existing cluster.
* The hashing algorithm called [murmur3](https://en.wikipedia.org/wiki/MurmurHash) modulo the total number of shards, is used to determine the shard number to assign to a specific document.
* Updates and deletes are actually difficult to manage in this distributed system, and are essentially treated as immutatble entites.
* An index operation must occur on the primary shard, prior to being done on any replicas.



## Anatomy of Search (Shards)

* Each shard is required to run the query locally.
* Each shard returns its best results, to the coordinating node, which is responsible for globally merging the results.
* The TF/IDF algorithm, the term frequency make sense even when calculated locally to the shard.
* With the default, fetch-then-query behaviour, IDF (document frequency) can be skewed when its calculated locally on the shard. IDF would be very expensive to calculate globally across the cluster. Interestly in practice, this is rarely an issue, especially when you have a large dataset that is evenly distributed across shards, as an even sampling exists.
* A global IDF can be computed if desired, by setting the `search_type` to `dfs_query_then_fetch`, and useful for testing on small datasets, `GET blogs/_search?search_type=dfs_query_then_fetch`


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




# Troubleshooting


## Configuration

Settings to various artifacts are applied at various levels:

* Index level, `PUT fooindex/_settings { "index.block.writes": true }`
* Node level, the `elasticsearch.yml`
* Cluster level, `PUT _cluster/settings { "persistent": { "discovery.zen.minimum_master_nodes": 2 } }`. Note the `persistent` setting, this will be written to the filesystem somewhere. Similarly a `transient` property is supported.


Precedence of settings:

1. Transient settings
2. Persistent settings
3. CLI arguments
4. Config files



## Responses

Given the REST API is based on HTTP, two things:

* The HTTP response code.
  * Can't connect, investigate network and path.
  * Connect just closed. Retry if possible (i.e. wont result in data duplication). This is one benefit of always indexing with explicit id's.
  * 4xx, busted request.
  * 429, Elasticsearch is too busy, retry later. Client should have backoff policies, such as a linear or exponential backoffs.
  * 5xx, look into ES logs.
* JSON body, always includes some basic shard metadata.

    "_shards": {
"total": 2,
"successful": 2,
"failed": 0
},

Breaking this down:

* Total has many shard copies.
* Successful the count of shard copies that were updated.
* Failed, a count, which will also come with a descriptive `faliures` structure with informative reason information.


Search responses:

* Skipped, ES 6.X onwards has an cheeky optimisation that applies when over 128 shards exists. A pre-optimisation that avoid hassling shards, if it knows there is just no point (i.e. documents that relate to the requested operation will just not exist in those shards).




## Cluster and Shard Health


Shard health:

* *Red*, at least one primary shard is not allocated in the cluster
* *Yellow*, all primaries are allocated but at least one replica is not
* *Green*, all shards are allocated

Index health, will always report on the worrst shard in that index.


Cluster health, will report the worst index in that cluster.



Shard lifecycle:

* `UNASSIGNED`, when shards haven't yet been allocated to nodes yet
* `INITIALIZING`, when shards are being provisioned and accounted for
* `STARTED`, shard is allocated and ready to store data
* `RELOCATING`, when a shard is in the process of being shuffled to another node


Shard promotion, can occur in the instance of a node failure, where a replica will evolve into a primary.

Details shard and index specific details can be obtained, using the `_cluster` API:

    GET _cluster/allocation/explain
{
  "index": "test1",
  "shard": 3,
  "primary": true
}



Shard status with `GET _cat/shards/test0?v`:


index shard prirep state      docs store ip         node
test0 3     p      STARTED       0  261b 172.18.0.2 node1
test0 4     p      STARTED       0  261b 172.18.0.4 node3
test0 2     p      UNASSIGNED                       
test0 1     p      STARTED       0  261b 172.18.0.4 node3
test0 0     p      STARTED       0  261b 172.18.0.2 node1




## Diagnosing Issues

Traffic light indicator via `GET _cluster/health`. Alternative you can block until a desired yellow or green status has been arrived to `GET _cluster/health?wait_for_status=yellow`.


TODO






# Improving Search Results

## Multi-field Search

A convenient shorthand for searching across many fields:

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


## Boosting

You can put more weight when particular fields, using the caret `^` symbol. Here the title is being boosted:


  "query": {
    "multi_match": {
      "query": "shay banon",
      "fields": [
        "title^2",
        "content",
        "author"
      ],
      "type": "best_fields"

To boost it even further `title^3` and so on. Boosting can also be applied to the `bool` clause. Boosting can be used to penalise a result e.g. `title^0.5`

TODO: P.358 `match_phrase`




## Fuzziness


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

Hot tip: use a `fuzziness` setting of `auto`, to dynamically adjust when it should be applied. Consider for example applying a fuzziness of 2 to a 2 character search term such as *hi*. This would hit any 4 character terms across the whole index. Pointless.



## Exact Terms

* Explicitly use the keyword field on a field, for example `category.keyword`.
* Exact keyword matches should often be applied in the filter context.




## Sorting

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


## Paging

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




## Highlighting

Enables a search term result to be wrapped in a tag for later rendering in a UI. By default will wrap in the `<em>`.




# Aggregations

Basically a `GROUP BY` clause.

Types of aggregations:

* Bucket, uses a field within the document type to aggregate on. For example, people by gender. Buckets can be nested. People by country, by gender for example. Buckets can also be sorted by its `_key` (the value of the in context bucketing term).
* Metrics, the usual aggregation suspects, `count`, `max`, `min`, `cardinality`, etc.
* Term, what the biggest contributor (e.g. by country) of a specific search term. Term aggregation are not precise due to a distributed computing problem, where aggregates are calculated per shard by each data node, which is then in turn tallied up by the coordinating node. To avoid this, you can ask that more aggregation results be returned to the coordinator, to avoid inaccurate tallying, by specifying a `"shard_size": 500`


Tricks:

* Set a `"size": 0` to completely strip everything, but the aggregate result itself.
* Queries and aggregations can be coupled together.
* The `cardinality` aggregation reports on just the distinct values. Has a default value of 3000.







# Best Practices

## Index Aliases

Think symbolic linking for indices. Avoid coupling clients to underlying index. For example, the frontend index alias might be called *blogs* and the underlying index *blogs_v1*.

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



## Index Templates

Blueprints for indices when their name matches a pattern. For controlling things like:

* Shard configuration
* Replica configuration

Multiple templates can be applied to an index, depending on the name matching rules that are evaluated. An `order` value in the template helps to battle.



## Scroll Search

Allows you take a snapshot of results (they result will not be impacted as new document get added/deleted from the index). Can have a maximum of 1000 results.


## Cluster Backup

Based on the *Snapshot and Restore API*. A number of repository destinations are supported, including cloud blobs, a network file system, a URL.

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

* Backups that are sent to the repository are incremental. Deleting.
* Handy for doing Elasticsearch upgrades. You can have a parallel cluster running the latest version, restore the backup to it.


General tips and tricks:

* Copy as curl from Kibana.
* Kibana can format JSON is pretty print (for humans) or single line format for use with the bulk API, with ctrl+i.
* Curator is an Elastic product like `cron`?
* Sorting by `_doc` is the fastest possible way to order results (because its the same order within the physical shard).

