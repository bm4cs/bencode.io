---
layout: post
draft: false
title: "Reflections on ElasticON Sydney 2025"
slug: "elasticon25"
date: "2025-03-07 7:16:56+1100"
lastmod: "2025-03-08 13:07:12+1100"
comments: false
categories:
  - elasticsearch
---

ElasticON in Sydney this March was a packed day, blending technical deep dives with executive-level discussions. The event featured interviews with partners and customers, but the real highlight was the keynote from Ken Exner and Baha Azarmi. Their presentation was slick, showcasing cutting edge GenAI features across the Elastic stack, including the new `semantic_text` field type, RRF, BBQ, LogsDB mode, and the ability to ETL unstructured data onto ECS using an LLM. The introduction of the ESQL query engine with native joins was another game changer.

The conference made one thing crystal clear, Elastic is all-in on GenAI. Once seen as a platform for simply storing and searching logs and semi-structured data using lexical search (BM25), Elastic is now evolving into something far more ambitious. It’s positioning itself as a key player in the world of semantic search, Retrieval Augmented Generation (RAG) orchestration and Generative AI. This shift signals a broader vision of not just indexing data but transforming it into a knowledge engine.

- [BBQ - Better Binary Quantization](#bbq---better-binary-quantization)
  - [How does it work?](#how-does-it-work)
- [Sparse Vectors and Semantic Search](#sparse-vectors-and-semantic-search)
- [Semantic Text Field Type \& Semantic Query](#semantic-text-field-type--semantic-query)
- [Hybrid Search with Reciprocal Rank Fusion (RRF)](#hybrid-search-with-reciprocal-rank-fusion-rrf)
- [GenAI \& the Free Tier Dilemma](#genai--the-free-tier-dilemma)
- [Developer Quality of Life Improvements](#developer-quality-of-life-improvements)
  - [ES|QL \& Joins](#esql--joins)
  - [start-local](#start-local)
  - [OpenTelemetry (OTel) Adoption](#opentelemetry-otel-adoption)
  - [Platform Consolidation \& Strategic Shift](#platform-consolidation--strategic-shift)
  - [JVM \& Native Code Optimizations](#jvm--native-code-optimizations)
- [Elastic Cloud Serverless](#elastic-cloud-serverless)
- [Final Thoughts](#final-thoughts)

## BBQ - Better Binary Quantization

If dense vectors are the heavy-duty freight trucks of machine learning, carrying vast amounts of high dimensional data, then quantization is the equivalent of repacking that freight into sleek, optimised shipping containers for faster transport.

BBQ (Better Binary Quantization) takes this further, pushing quantization to its limits. It delivers:

- 20-30x acceleration in vector quantization times
- Up to 95x reduction in vector memory footprint
- Faster search performance without significant accuracy loss

### How does it work?

Dense vectors store ML generated embeddings; representing text, images, or other inputs, as floating-point numbers in high dimensional space. The problem? Computing similarity between these vectors is costly.

Quantization helps by compressing these dimensions, converting 32-bit floats into smaller representations like 8-bit or even 4-bit integers. This drastically improves search efficiency at the cost of some accuracy.

BBQ builds on [Optimized Scalar Quantization](https://www.elastic.co/search-labs/blog/optimized-scalar-quantization-elasticsearch), allowing fine-tuned control over speed vs recall quality. It also aligns with the latest research on high-dimensional vector search, including papers like [RaBitQ](https://arxiv.org/abs/2405.12497).

For organisations working with AI driven search, this means faster queries, lower storage costs, and better scalability.

## Sparse Vectors and Semantic Search

Imagine walking into a massive library where books aren’t categorized by title or author but by the deeper meaning of their content. That’s the power of sparse vectors in semantic search.

Unlike dense vectors, which are purely numeric, sparse vectors represent text as a set of weighted key-value pairs, mapping concepts to numerical importance.

For example, if we embed the name "Pablo Picasso" might get something like this:

```json
{
  "picasso": 2.667,
  "pablo": 2.102,
  "artist": 1.023,
  "art": 0.936,
  "painting": 0.921
}
```

At query time, a search for "painting" will naturally surface documents about Picasso, even if the word "painting" doesn’t explicitly appear in the text.

This approach moves beyond keyword based search, allowing for concept based retrieval, where the system understands what users mean rather than just what they type.

## Semantic Text Field Type & Semantic Query

Elasticsearch's new `semantic_text` field type automates semantic search using sparse vectors behind the scenes. If you've ever wished for an easy, plug-and-play way to add AI powered search, this is it.

Generating these sparse vector embeddings is straightforward using Elastic's built-in ML models like ELSER for English. This makes it easier than ever to experiment with hybrid search, blending traditional keyword-based search with AI-driven relevance ranking.

TODO: code snippet

## Hybrid Search with Reciprocal Rank Fusion (RRF)

Hybrid search—combining lexical (BM25) and semantic search, has traditionally required fine-tuning. A naïve approach is to execute both search types separately and merge results using linear combination (AND/OR logic). However, this often leads to ranking inconsistencies.

[RRF](https://www.elastic.co/guide/en/elasticsearch/reference/current/rrf.html) offers a more sophisticated alternative. Instead of normalizing scores, RRF ranks results based on their relative positions across different search methods.

For example, if a document appears:

- 1st in BM25 results
- Last in semantic search results

RRF averages the rank, placing it somewhere in the middle—offering a more balanced ranking that reflects both exact matches and conceptual relevance.

This technique provides a blended search experience without the headache of manual score tuning.

## GenAI & the Free Tier Dilemma

One lingering question from the conference: What’s actually available in the free tier?

Elastic’s feature matrix suggests vectors are included, but when designing complex RAG architectures, for both customers and personal projects, license tier trade-offs matter.

The GenAI space is evolving too rapidly for Elastic (or anyone) to have all the answers. Competitors like OpenSearch AI search are also moving quickly, creating an environment where flexibility is key.

Historically, Elastic thrived on its open-source Lucene foundation, with premium features available via X-Pack. But in this new GenAI world, things feel different. Elastic is now a publicly listed corporation, and its licensing model reflects that shift.

## Developer Quality of Life Improvements

Amid the GenAI hype, Elastic hasn’t forgotten its core developer audience. Some notable improvements:

### ES|QL & Joins

Elasticsearch has long been notorious for not supporting joins, a hard design opinion it is renown for. But now, with the ES|QL query engine, joins are not only possible but scalable.

This is a game-changer, and Elastic plans to migrate its existing query API to ES|QL over time.

### start-local

A much-needed developer QoL feature: [start-local](https://www.elastic.co/guide/en/elasticsearch/reference/current/run-elasticsearch-locally.html) makes spinning up local Elastic instances much easier.

### OpenTelemetry (OTel) Adoption

Elastic is ditching proprietary instrumentation and embracing OpenTelemetry (OTel). In version 9.x, Elasticsearch will absorb OTel signals natively, eliminating the need for separate APM layers. This shift toward open standards is great for interoperability.

### Platform Consolidation & Strategic Shift

Elastic is simplifying its ecosystem, with a clear shift toward consolidation. Expect some products like Enterprise Search, APM, and Logstash to be sunset over time as Elastic doubles down on core capabilities.

### JVM & Native Code Optimizations

Elastic is leveraging JDK 20’s Project Panama to refactor performance-critical Java code. This includes:

- SIMD optimizations
- Fused multiply-add instructions

These low-level optimizations should significantly boost efficiency for high-performance workloads.

## Elastic Cloud Serverless

One of the biggest shifts: Elastic is now offering a fully managed SaaS product.

Historically, Elastic took a "you manage it" stance, but this move signals a willingness to handle live production deployments, a major departure from its roots.

Managing customer data at scale is a high-stakes game, and it will be interesting to see how Elastic balances flexibility vs control in this new serverless paradigm.

## Final Thoughts

ElasticON 2025 made one thing clear, Elastic is no longer just a search company. It’s evolving into an AI first, data intelligence platform. The focus on GenAI, hybrid search, and developer experience is exciting, but it also raises questions about licensing, competition, and long-term strategy.

As the industry shifts, so must Elastic. And for developers and businesses alike, the next few years will be an interesting ride.
