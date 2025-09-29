---
layout: post
draft: false
title: "18 Month Software Project Retrospective"
slug: "retro25"
date: "2025-06-20 13:13:00+1000"
lastmod: "2025-06-20 13:13:00+1000"
comments: false
categories:
  - software
  - retro
  - develeloper
---

This retrospective reflects my observations about technology and human matters as a result of working on a complex 2 year software development project in a geographically dispersed team.

- [Key Successes](#key-successes)
  - [Technical Achievements](#technical-achievements)
  - [Process Improvements](#process-improvements)
- [Project Management Challenges](#project-management-challenges)
  - [Individuals and Interactions over Processes and Tools](#individuals-and-interactions-over-processes-and-tools)
  - [Working Software over Comprehensive Documentation](#working-software-over-comprehensive-documentation)
  - [Customer Collaboration over Contract Negotiation](#customer-collaboration-over-contract-negotiation)
  - [Responding to Change over Following a Plan](#responding-to-change-over-following-a-plan)
- [Challenges and Learnings](#challenges-and-learnings)
  - [Technical Challenges](#technical-challenges)
  - [Team and Communication](#team-and-communication)
  - [Architecture Decisions](#architecture-decisions)
- [What Worked Well](#what-worked-well)
  - [Technology Stack](#technology-stack)
  - [Team Dynamics](#team-dynamics)
- [Recommendations for Future Projects](#recommendations-for-future-projects)
- [Personal Growth](#personal-growth)
- [Lessons for Future Projects](#lessons-for-future-projects)

## Key Successes

### Technical Achievements

- Successfully built a big data horizontally scalable ingestion system using Kubernetes and leaned into cloud native approaches early on
- Established heavy use of Python type hints early on, which improved code quality and editor aid
- Evangelised Elasticsearch early in the design phase:
  - Led the adoption of Elasticsearch for read workloads, in the face of aprehension and inexperience in the broader team
  - Implemented and tuned sophisticated text analysis pipelines
  - Optimised search with ngram tokenizers, stemming, and asciifolds
  - Designed efficient denormalised document structures and indexing strategies
  - Lesson learned how important it is to make the the most appropriate data storage and management choices, make or break analytic solutions such as the one we collectively built. What consistency guarantees do are required? How fast? How are you going to calculate aggregations? What kind of read or write workloads need to be handled? Can these be separated and tackled as different problems?
  - Elasticsearch is a HUGE reason why we were successful
- Created flexible hierarchy layering design, allowing differing customers to stamp the data with their own ways of doing things.
- Integrated OpenTelemetry for comprehensive observability
- Developed optimistic locking scheme and deep linking capabilities
- Automated deployments and quality verification with a gigantic test suite investment (unit and integration), linting, autoformatting, all orchestrated with a `Makefile` frontend and Bamboo CI pipeline
- The team embraced containers heavily from day 1. From running local vendor infra containers (redis, mongo, elasticsearch, etc) to running repeatable build workloads.

### Process Improvements

- Adopted `Make` for development automation, significantly boosting productivity
- Leveraged code generation effectively for complex scenarios, an ever powerful technique
- Implemented comprehensive integration testing with containerization
- Successfully broke down the system into functional components early
- Established well-defined data schemas upfront, which provided stability

## Project Management Challenges

### Individuals and Interactions over Processes and Tools

Team structure and collaboration issues:

- Lack of clear role definitions created power dynamics uncertainty
- Limited team buy-in; developers focused on ticket completion over quality
- No regular showcases or knowledge sharing sessions, creating a culture of us vs them, broken window syndrome and morale issues
- Missed tremendous opportunities for team growth and cross-pollination of ideas

### Working Software over Comprehensive Documentation

Release and Quality Issues:

- Monthly or multi-month release cycles led to integration problems
- Releases often proved buggy in production environments
- No test environment with production-like data sets
- Limited end-to-end testing before deployment
- Developers often didn't run or test their own code
- Missing system evolution planning:
  - No strategy for database schema migrations
  - Limited consideration for data evolution over time

### Customer Collaboration over Contract Negotiation

Stakeholder Engagement Gaps:

- No regular stakeholder involvement or feedback loops
- Missing showcase demonstrations
- Long feedback cycles due to infrequent releases
- Limited understanding of real-world usage patterns
- No continuous validation of features against user needs

### Responding to Change over Following a Plan

Process Inflexibility:

- Heavy-handed waterfall approach limited adaptability
- Rigid upfront planning without room for iteration
- Long release cycles prevented quick adjustments
- Limited ability to incorporate feedback and learnings
- Adding large features went through a double litigation review process, resulting in double handling, unnessary time lag to getting good enough code merged

## Challenges and Learnings

### Technical Challenges

- Python-specific challenges:
  - General struggles with Python's magic; pytest fixture injection or complex runtime challenges (e.g. wrong event loop when working with async) frequently producing incorrect code. It turns out [AI agents struggle](https://lucumr.pocoo.org/2025/6/12/agentic-coding/) to write correct Python too.
  - Unstable toolchain. We evolved from `requirements.txt` to `pyproject.toml`, using `pip`, using rawdog `venv`, using `poetry`, using `uv`. They all have there pros/cons. Every python tutorial out there seems to preach differing recommedations (e.g. Python Packaging in 202X). This distracted the team throughout and plagued the team non-deterministic builds (devs on Windows, MacOS, Linux usually got differing results).
  - Type system limitations and related codebase churn
  - Import resolution and circular dependency issues
  - Async programming complexities:
    - Event loop conflicts in async code
    - Difficulty debugging wrong event loop scenarios
    - AI tools and static analyzers struggling with async patterns
  - Runtime "magic" causing significant issues:
    - Pytest fixture injection complexity leading to subtle bugs
    - Import-time side effects causing hard-to-debug issues
    - Dynamic runtime behaviors making static analysis less effective
  - Performance bottlenecks:
    - Test suite execution time took on average 15-20 minutes, and that was after performance tuning and parallelisation efforts
    - Limited improvement despite parallelization efforts
    - Significant overhead in import time and startup
- Initial struggles with API versioning between frontend and backend
- Struggle with NoSQL document databases and evolving schemas and representations over time. I think this is a hidden upfront trade off, that you end up paying for down the road. Stuffing unversioned pydantic models into MongoDB and Elasticsearch indices will bite you.
- Test suite maintenance and mock complexity
- No common environments or tooling standards
- Team broadly unskilled in software architecture and design generally, linux basics, kubernetes and helm

### Team and Communication

- Remote collaboration challenges with a large international team
- PR process was overly rigid and focused on perfection over progress. The PR process carried the weight of poor communication across the team, reviewers often having zero context.
- Narrow knowledge sharing and cross-team collaboration
- Waterfall-style management created friction with agile development needs
- Team commitment and ownership could have been stronger
- Opportunties for training to bring the team up to a baseline set of skills were missed
- Technical training would have paid huge dividends, and in the long run is always a cheap investment

### Architecture Decisions

- The team struggled to make forest (big things that matter) from trees (small things that don't really matter) decisions. The result a fairly dirty hard to maintain codebase, that didn't embrace clean architecture, SOLID principles, etc.
- Early time investment in technical decisions (linters, formatters, etc.) was possibly excessive
- Data access layer needed more upfront architectural patterns (Unit of Work, CQRS)
- Model separation proved valuable (API, business layer, data access layer)
- FastAPI, polylith, poetry, and pydantic provided needed structure, however found the python eco-system around toolchains to be unreliable

## What Worked Well

### Technology Stack

- Python's cross-platform compatibility
- VSCode with Python extensions
- Kubernetes for scalability
- Elasticsearch expertise development:
  - Deep understanding of text analysis pipelines
  - Mastery of search optimization techniques
  - Successful implementation of complex search requirements
- Make for development automation
- Poetry for dependency management

### Team Dynamics

- Australian team's resilience and problem-solving approach
- Strong technical leadership in specific areas - at this senior stage in my career I would argue that people skills prove to be far more valuable than technical skills
- Ability to influence and drive technical decisions respectfully

## Recommendations for Future Projects

Technical Recommendations

- Invest in architectural patterns and design principles upfront
- Consider NATS or similar for message queuing
- Leverage lightweight Kubernetes for integration testing
- Balance type checking with pragmatic development

Process Recommendations

- Move to shorter release cycles
- Implement continuous integration/deployment
- Require developers to test their own code
- Create automated test data generation
- Establish clear data migration patterns
- Regular stakeholder demos and feedback sessions

Team Collaboration

- Foster more cross-team ownership
- Encourage more collaborative problem-solving
- Balance upfront planning with agile flexibility
- Implement better knowledge sharing practices

Agile Implementation

- Implement regular sprint showcases
- Establish clear team roles and responsibilities early
- Create shorter feedback loops with stakeholders
- Set up production-like test environments
- Plan for system evolution and data migration
- Foster team ownership through collaborative practices

Architecture Foundation

- Design security model from day one
- Implement field-level security patterns early
- Consider security implications in data store choices
- Plan for scale in security implementation
- Follow SOLID principles and clean architecture
- Design for future security requirement evolution

## Personal Growth

- Adapted to early morning international collaboration (4AM starts) - I now love rising early and seizing the day
- Developed a love for TUI based tools
- Reinforced appreciation for simple, reliable tools
- Enhanced leadership and influence skills
- I now appreciate that software projects are more about people than code

## Lessons for Future Projects

- Early role definition is crucial for team dynamics
- System evolution planning should be part of initial architecture
- Production-like test environments are essential
- Regular showcases drive quality and engagement
- Shorter release cycles enable better feedback loops
- Team buy-in requires more than just ticket assignment
- Continuous stakeholder involvement is critical
- Security architecture must be a day-one consideration
- Field-level security needs early design consideration
- Data store choices must account for security requirements
- Clean architecture principles enable security evolution
