---
layout: post
draft: true
title: "Elasticsearch Gems"
slug: "esgems"
date: "2025-03-05 15:46:56+1100"
lastmod: "2025-03-05 15:46:56+1100"
comments: false
categories:
  - elasticsearch
---

Elasticsearch is now a vast platform. Yes it fronts Lucene, but it has evolved it from purely a search engine into several other domains including being able to do high performance aggregations on top of the columnar subsystem, graphs, analomy detection, etc.

I am amazed at some of the fascinating little edge cases you can solve with core Elasticsearch and have years of war stories developing solutions with it. This is collection of some of the _off the beaten track_ tips and tricks I've picked up over the years.

- [Tip 1: Know your customer (precision vs recall)](#tip-1-know-your-customer-precision-vs-recall)
- [Tip 2: Mapping parameters](#tip-2-mapping-parameters)
- [Tip 3: Token filters](#tip-3-token-filters)
- [Tip 4: Query time analyzers](#tip-4-query-time-analyzers)
- [Tip 5: Ingest time normalizers vs analyzers](#tip-5-ingest-time-normalizers-vs-analyzers)
- [Tip 6: cat like its 1999](#tip-6-cat-like-its-1999)
- [Tip 7: Materialised views aka enrichments](#tip-7-materialised-views-aka-enrichments)
- [Tip 8: I can do joins, enter ESQL](#tip-8-i-can-do-joins-enter-esql)
- [Tip 9: Ingest pipelines](#tip-9-ingest-pipelines)
- [Tip Z: Painless](#tip-z-painless)
  - [Ingest time painless](#ingest-time-painless)
  - [Query time painless](#query-time-painless)

## Tip 1: Know your customer (precision vs recall)

Out of the box, Elasticsearch has thousands of options to process, analyze and query documents. Its overwhelming. I've found its critical to come up with a plan of what direction you want to take it. Are you dealing with multi-lingual text? Is your customer in compliance or legal where a missing search hit could have dire consequences?

**Recall** is about ensuring all relevant documents are retrieved. High recall is crucial in legal or compliance scenarios where missing relevant information can have significant consequences.

**Precision** is about ensuring the retrieved documents are highly relevant to the query. High precision is important in consumer (esp zoomer facing) applications to avoid user frustration.

## Tip 2: Mapping parameters

## Tip 3: Token filters

## Tip 4: Query time analyzers

A phrase query can be configured to use a different analyzer setup, than standard token based queries.

Test them with `_analyze`. Test a specific fields configured analyzer setup with `_analyze`

Measure the token space impacts e.g. of ngram or ASCIIfold for example. More tokens = more space.

## Tip 5: Ingest time normalizers vs analyzers

## Tip 6: cat like its 1999

Shards, disk capacity.

## Tip 7: Materialised views aka enrichments

## Tip 8: I can do joins, enter ESQL

Normalised data is the bane of opinionated denormalised "big data" platforms like Elasticsearch. It is discouraged for example to have separate `person` and `address` indices. Instead glob them all together.

## Tip 9: Ingest pipelines

```json
{
  "description": "Ingest pipeline created by text structure finder",
  "processors": [
    {
      "csv": {
        "field": "message",
        "target_fields": [
          "Restaurant",
          "Reviewer",
          "Review",
          "Rating",
          "Metadata",
          "Time",
          "Pictures",
          "7514"
        ],
        "ignore_missing": false
      }
    },
    {
      "convert": {
        "field": "7514",
        "type": "long",
        "ignore_missing": true
      }
    },
    {
      "convert": {
        "field": "Pictures",
        "type": "long",
        "ignore_missing": true
      }
    },
    {
      "convert": {
        "field": "Rating",
        "type": "long",
        "ignore_missing": true
      }
    },
    {
      "remove": {
        "field": "message"
      }
    }
  ]
}
```

## Tip Z: Painless

A full blown JVM based language. Yes it can be frustrating, but it can unlock super powers.

### Ingest time painless

```
TODO
```

### Query time painless

```
TODO
```

WTF?! I found this playing in the elastic lab environment:

```json
{
  "foo": {
    "aliases": {},
    "mappings": {
      "dynamic": "true",
      "dynamic_templates": [
        {
          "all_text_fields": {
            "match_mapping_type": "string",
            "mapping": {
              "analyzer": "iq_text_base",
              "fields": {
                "delimiter": {
                  "analyzer": "iq_text_delimiter",
                  "type": "text",
                  "index_options": "freqs"
                },
                "joined": {
                  "search_analyzer": "q_text_bigram",
                  "analyzer": "i_text_bigram",
                  "type": "text",
                  "index_options": "freqs"
                },
                "prefix": {
                  "search_analyzer": "q_prefix",
                  "analyzer": "i_prefix",
                  "type": "text",
                  "index_options": "docs"
                },
                "enum": {
                  "ignore_above": 2048,
                  "type": "keyword"
                },
                "stem": {
                  "analyzer": "iq_text_stem",
                  "type": "text"
                }
              }
            }
          }
        }
      ]
    },
    "settings": {
      "index": {
        "routing": {
          "allocation": {
            "include": {
              "_tier_preference": "data_content"
            }
          }
        },
        "number_of_shards": "2",
        "auto_expand_replicas": "0-3",
        "provided_name": "foo",
        "creation_date": "1741166122102",
        "analysis": {
          "filter": {
            "front_ngram": {
              "type": "edge_ngram",
              "min_gram": "1",
              "max_gram": "12"
            },
            "bigram_joiner": {
              "max_shingle_size": "2",
              "token_separator": "",
              "output_unigrams": "false",
              "type": "shingle"
            },
            "bigram_max_size": {
              "type": "length",
              "max": "16",
              "min": "0"
            },
            "en-stem-filter": {
              "name": "light_english",
              "type": "stemmer",
              "language": "light_english"
            },
            "bigram_joiner_unigrams": {
              "max_shingle_size": "2",
              "token_separator": "",
              "output_unigrams": "true",
              "type": "shingle"
            },
            "delimiter": {
              "split_on_numerics": "true",
              "generate_word_parts": "true",
              "preserve_original": "false",
              "catenate_words": "true",
              "generate_number_parts": "true",
              "catenate_all": "true",
              "split_on_case_change": "true",
              "type": "word_delimiter_graph",
              "catenate_numbers": "true",
              "stem_english_possessive": "true"
            },
            "en-stop-words-filter": {
              "type": "stop",
              "stopwords": "_english_"
            }
          },
          "analyzer": {
            "i_prefix": {
              "filter": [
                "cjk_width",
                "lowercase",
                "asciifolding",
                "front_ngram"
              ],
              "type": "custom",
              "tokenizer": "standard"
            },
            "iq_text_delimiter": {
              "filter": [
                "delimiter",
                "cjk_width",
                "lowercase",
                "asciifolding",
                "en-stop-words-filter",
                "en-stem-filter"
              ],
              "type": "custom",
              "tokenizer": "whitespace"
            },
            "q_prefix": {
              "filter": ["cjk_width", "lowercase", "asciifolding"],
              "type": "custom",
              "tokenizer": "standard"
            },
            "iq_text_base": {
              "filter": [
                "cjk_width",
                "lowercase",
                "asciifolding",
                "en-stop-words-filter"
              ],
              "type": "custom",
              "tokenizer": "standard"
            },
            "iq_text_stem": {
              "filter": [
                "cjk_width",
                "lowercase",
                "asciifolding",
                "en-stop-words-filter",
                "en-stem-filter"
              ],
              "type": "custom",
              "tokenizer": "standard"
            },
            "i_text_bigram": {
              "filter": [
                "cjk_width",
                "lowercase",
                "asciifolding",
                "en-stem-filter",
                "bigram_joiner",
                "bigram_max_size"
              ],
              "type": "custom",
              "tokenizer": "standard"
            },
            "q_text_bigram": {
              "filter": [
                "cjk_width",
                "lowercase",
                "asciifolding",
                "en-stem-filter",
                "bigram_joiner_unigrams",
                "bigram_max_size"
              ],
              "type": "custom",
              "tokenizer": "standard"
            }
          }
        },
        "number_of_replicas": "1",
        "uuid": "mtH5O5h6RR2eZEGnB9ODMg",
        "version": {
          "created": "8521000"
        }
      }
    }
  }
}
```
