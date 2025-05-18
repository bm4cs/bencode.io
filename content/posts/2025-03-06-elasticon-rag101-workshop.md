---
layout: post
draft: true
title: "ElasticON RAG workshop"
slug: "esgems"
date: "2025-03-06 15:46:56+1100"
lastmod: "2025-03-06 15:46:56+1100"
comments: false
categories:
  - elasticsearch
---

> "A RAG process takes a query and assesses if it relates to subjects defined in the paired knowledge base. If yes, it searches its knowledge base to extract information related to the user’s question. Any relevant context in the knowledge base is then passed to the LLM along with the original query, and an answer is produced." [source](https://kimfalk.org/2023/10/25/what-is-retrieval-augmented-generation-rag/)


- [Common use cases](#common-use-cases)
  - [Dense `e5-small`](#dense-e5-small)
  - [Sparse](#sparse)
- [Vector Databases](#vector-databases)
- [Chunking](#chunking)
- [Semantic Text](#semantic-text)
- [Inference API](#inference-api)
  - [Register an inference endpoint](#register-an-inference-endpoint)
  - [Test generating ELSER embeddings](#test-generating-elser-embeddings)
- [Prime data](#prime-data)
  - [Configure chat completion LLM endpoint](#configure-chat-completion-llm-endpoint)
- [Hard questions](#hard-questions)
- [Resources](#resources)



## Common use cases

- Question and answer chatbots: Incorporating LLMs with chatbots allows them to automatically derive more accurate answers from company documents and knowledge bases. Chatbots are used to automate customer support and website lead follow-up to answer questions and resolve issues quickly.
- Search augmentation: Incorporating LLMs with search engines that augment search results with LLM-generated answers can better answer informational queries and make it easier for users to find the information they need to do their jobs.
- Knowledge engine (like HR, compliance documents): Company data can be used as context for LLMs and allow employees to get answers to their questions easily, including HR questions related to benefits and policies and security and compliance questions.


Vector search ranks objects by similarity, usually across many dimensions.

TODO: Great starwars visualisation.

Two kinds of vector models.

### Dense `e5-small`

E5

Support multi-linguals

### Sparse

Token weighted pairs

ELSERv2: Elastic Learned Sparse EncodeR

- CPU only inferenece
- Based on Lucene
- ELSER vs Open Transformer Models

Inspired by SPLADEv2 TODO: find the paper for this

```
POST _ml/
```

Passes the input tokens through a neural network expansion.

## Vector Databases

Stores the meaning of text, images and audio encoded in a high dimensinoal dense and sparse vectors.

Indexes ANN (Approximate Nearest Neighbor), Elastic uses optimised HNSW data structure.

Get Elastic benefits: cross cluster, security

## Chunking

Splitting text into smaller pieces (chunks), used for longer passages of text, like a novelm emails.

Strategies:

- Paragraphs
- Sentence
- Words

Text is split into 250 words chunks. Overlap is benefitial, each chunk includes 100 words from the previous chunks.

Rank eval is provided to help find the sweet spot.

## Semantic Text

Autopilots most of these choices.

- Quantizes dense vectors
- Auto chunking of long documents
- Auto generates embeddings

https://ela.st/elasticon-genai

## Inference API

### Register an inference endpoint

This will automatically deploy ELSER with the configured settings
This will then allow us to generate embeddings for our uploaded text and queries

```
PUT _inference/sparse_embedding/my-elser-endpoint
{
  "service": "elser",
  "service_settings": {
    "num_allocations": 8,
    "num_threads": 1
  }
}
```

Validate the inference was made and check its model `.elser_model_2_linux-x86_64`:

```
GET _inference/my-elser-endpoint
```

### Test generating ELSER embeddings

```
POST _inference/sparse_embedding/my-elser-endpoint
{
  "input": "How many adult mallard ducks fit in an american football field?"
}
```

Which evaluates embeddings:

```json
{
  "sparse_embedding": [
    {
      "is_truncated": false,
      "embedding": {
        "ducks": 1.6971637,
        "football": 1.6908726,
        "mall": 1.6816322,
        "field": 1.6378394,
        "duck": 1.5755934,
        "adult": 1.4338976,
				...
				        "people": 0.013541508,
        "?": 0.007936609,
        "golf": 0.006012804
      }
    }
  ]
}
```

## Prime data

Download [restaurant data set](https://github.com/elastic/instruqt-workshops-take-away-assets/blob/main/search/genai-101/kaggle_datasets_restaurant-reviews.csv).

Patch up mappings using new `semantic_text` data type:

```
"Restaurant": {
  "type": "keyword",
  "fields": {
    "text": {
      "type": "text"
    }
  }
},
...
"Review": {
  "type": "text",
  "copy_to": [
    "semantic_body"
  ]
},
...
"semantic_body": {
  "type": "semantic_text",
  "inference_id": "my-elser-endpoint",
  "model_settings": {
    "task_type": "sparse_embedding"
  }
},
```

### Configure chat completion LLM endpoint

```
PUT _inference/completion/openai_chat_completions
{
    "service": "openai",
    "service_settings": {
        "api_key": "sk-H1x8pJT0fY61ieumaZjOIw",
        "model_id": "gpt-4o",
        "url": "https://litellm-proxy-service-1059491012611.us-central1.run.app/v1/chat/completions"
    }
}
```

Validate the model is deployed:

```
POST _inference/completion/openai_chat_completions
{
  "input": "How many male malard ducks fit in an american football field?"
}
```

## Hard questions

- Chunking configuration, what is optimal?
- Changing your embedding parameters post ingestion?

## Resources

- [A Practitioners Guide to Retrieval Augmented Generation (RAG)](https://cameronrwolfe.substack.com/p/a-practitioners-guide-to-retrieval)
-
