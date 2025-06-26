---
layout: post
draft: false
title: "Software Project Retrospective"
slug: "retrox"
date: "2025-06-20 13:13:00+1000"
lastmod: "2025-06-20 13:13:00+1000"
comments: false
categories:
  - software
  - retro
  - develeloper
---

This retrospective reflects my perspective on a two-year international software development collaboration, on both technical and human sides of software development.

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

- Successfully built a horizontally scalable ingest system using Kubernetes and leaned into cloud native approaches early on
- Established a strong typing system in Python that improved code quality
- Was the project's Elasticsearch expert:
  - Implemented and tuned sophisticated text analysis pipelines
  - Optimized search with ngram tokenizers, stemming, and asciifolding
  - Designed efficient document structures and indexing strategies
  - Led the adoption of Elasticsearch for read workloads
- Created flexible hierarchy layering design
- Integrated OpenTelemetry for comprehensive observability
- Developed optimistic locking scheme and deep linking capabilities
- Automated deployment and quality verification through Bamboo CI pipeline

### Process Improvements

- Adopted Make for development automation, significantly boosting productivity
- Leveraged code generation effectively for complex scenarios
- Implemented comprehensive integration testing with containerization
- Successfully broke down the system into functional components early
- Established well-defined data schemas upfront, which provided stability

## Project Management Challenges

### Individuals and Interactions over Processes and Tools

Team structure and collaboration issues:

- Lack of clear role definitions created power dynamics uncertainty
- Limited team buy-in; developers focused on ticket completion over quality
- No regular showcases or knowledge sharing sessions
- Missing opportunities for team growth and cross-pollination of ideas

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

## Challenges and Learnings

### Technical Challenges

- Python-specific challenges:
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
    - Test suite execution time growing to 15-20 minutes
    - Limited improvement despite parallelization efforts
    - Significant overhead in import time and startup
- Initial struggles with API versioning between frontend and backend
- Test suite maintenance and mock complexity
- No common environments or tooling standards
- Team broadly unskilled in software architecture and design generally, linux basics, kubernetes and helm

### Team and Communication

- Remote collaboration challenges with a large international team
- Initial PR process was overly rigid and focused on perfection over progress
- Limited knowledge sharing and cross-team collaboration
- Waterfall-style management created friction with agile development needs
- Team commitment and ownership could have been stronger
- Opportunties for training to bring the team up to a baseline set of skills were missed

### Architecture Decisions

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
