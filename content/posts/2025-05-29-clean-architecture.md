---
layout: post
draft: false
title: "Clean Architecture"
slug: "clean"
date: "2025-01-29 20:14:01+1100"
lastmod: "2025-01-29 20:14:01+1100"
comments: false
categories:
  - software
  - design
  - architecture
---

- [Guiding design principles](#guiding-design-principles)
- [Clean architecture](#clean-architecture)
- [SOLID](#solid)
  - [Single Responsibility Principle](#single-responsibility-principle)
  - [Open-Closed Principle](#open-closed-principle)
  - [Liskov Substitution Principle](#liskov-substitution-principle)
  - [Interface Segregation Principle](#interface-segregation-principle)
  - [Dependency Inversion Principle](#dependency-inversion-principle)

## Clean Architecture Fundamentals

### Guiding design principles

High level qualities that a good software architecture should (and enforce) strive for; maintainability, testability and loose coupling.

1. Separation of concerns: domain from external dependencies
2. Encapsulation: information hiding and isolating components from influence of others
3. Dependency inversion: depend on abstractions at compile time, and concrete implementations at runtime
4. Explicit dependencies: honesty about dependencies
5. Single responsibility: one reason to exist and to change
6. DRY: eliminate and encapsulate repetitive behavior
7. Persistence ignorance: domain entities are agnostic of physical storage
8. Bounded contexts: DDD conceptual model that groups related entities and behaviours together

### Clean architecture

Domain centric architectures, like clean, have inner architectural cores that model the domain. Dependency inversion is king, with inner layers defining abstractions and interfaces and outer layers implementing them.

Clean architecture is a good fit when:

- Apply Domain Driven Design (DDD)
- Dealing with complex business logic
- High testability is desirable
- Working in a large team, as the architecture can enforce design policies

### Clean architecture layers

#### Domain layer

The inner heart layer, houses the most important enterprise logic and business rules.

- *Entities*: Represent core business objects with a unique identity that persists over time.
- *Value objects*: Immutable objects defined by their attributes, not identity, used to describe aspects of the domain.
- *Domain events*: Notifications that something significant has happened within the domain.
- *Domain services*: Stateless operations or business logic that don't naturally fit within an entity or value object.
- *Interfaces*: Abstractions that define contracts for dependencies, enabling inversion of control and testability.
- *Exceptions*: Domain-specific errors used to signal and handle invalid states or business rule violations.
- *Enums*: Enumerations representing a fixed set of related constants, often used for domain concepts with limited options.

#### Application layer

The middle layer.

1. Responsible for orchestrating the domain.
2. Higher level business logic that doesn't "fit" in the domain.
3. Defines the use cases. Drivers of behavior in the application across domain entities. Typically encoded as a set of *Appliation services*, or alternatively as the CQRS pattern with MediatR.

#### Infrastructure layer

As one of the two outer layers, takes care of interfacing with external systems (DBs, queues, caches, S3, identity, etc).


#### Presentation layer

Single point of entry to the application. Requests are processed by leveraging the layers below.

Typical examples:

- REST API
- gRPC
- SPA
- CLI
