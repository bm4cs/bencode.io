---
layout: post
draft: false
title: "Clean Architecture"
slug: "cleanarch"
date: "2025-05-29 20:14:01+1000"
lastmod: "2025-05-29 20:14:01+1000"
comments: false
categories:
  - software
  - design
  - architecture
---

Domain centric architectures, like clean architecture, have inner architectural cores that model the domain. Dependency inversion is king, with inner layers defining abstractions and interfaces and outer layers implementing them. Clean architecture is a good fit when aligning to Domain Driven Design (DDD), dealing with complex business logic, high testability is desirable and/or working in a large team, as the architecture can enforce design policies.

- [Glossary](#glossary)
- [Guiding Principles](#guiding-principles)
- [Clean Architecture Layers](#clean-architecture-layers)
  - [Domain layer](#domain-layer)
    - [Entities](#entities)
    - [Value Objects](#value-objects)
    - [Domain Events](#domain-events)
  - [Application layer](#application-layer)
  - [Infrastructure layer](#infrastructure-layer)
  - [Presentation layer](#presentation-layer)
- [.NET Implementation Tips](#net-implementation-tips)
  - [Records](#records)

## Glossary

| Term                       | Definition                                                                                                                                 |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| **Aggregate**              | A cluster of domain objects that can be treated as a single unit. An aggregate has one aggregate root and enforces consistency boundaries. |
| **Aggregate Root**         | The only member of an aggregate that outside objects are allowed to hold references to. It controls access to the aggregate's internals.   |
| **Anemic Domain Model**    | An anti-pattern where domain objects contain little or no business logic, acting mainly as data containers with getters and setters.       |
| **Application Service**    | A service in the application layer that orchestrates domain objects and infrastructure to fulfill use cases.                               |
| **Bounded Context**        | A central pattern in DDD that defines explicit boundaries within which a domain model is valid and consistent.                             |
| **Clean Architecture**     | An architectural pattern that separates concerns into concentric layers, with dependencies pointing inward toward the domain.              |
| **Command**                | An object that represents a request to perform an action, often used in CQRS to separate write operations.                                 |
| **Context Map**            | A visual representation showing the relationships and integration patterns between different bounded contexts.                             |
| **CQRS**                   | Separating read and write operations into different models and potentially different databases.                                            |
| **Dependency Inversion**   | A principle stating that high-level modules should not depend on low-level modules; both should depend on abstractions.                    |
| **Domain**                 | The subject area or sphere of knowledge and activity around which the application logic revolves.                                          |
| **Domain Event**           | Something that happened in the domain that domain experts care about and that triggers side effects.                                       |
| **Domain Model**           | An object model of the domain that incorporates both behavior and data, representing the business concepts and rules.                      |
| **Domain Service**         | A service that encapsulates domain logic that doesn't naturally fit within a single entity or value object.                                |
| **Entity**                 | A domain object that has a distinct identity that runs through time and different states.                                                  |
| **Event Sourcing**         | A pattern where state changes are stored as a sequence of events rather than just the current state.                                       |
| **Hexagonal Architecture** | Also known as Ports and Adapters, isolates the core business logic from external concerns through well-defined interfaces.                 |
| **Infrastructure Layer**   | The outermost layer containing technical details like databases, external APIs, and frameworks.                                            |
| **Onion Architecture**     | Similar to Clean Architecture, organizing code in concentric layers with dependencies pointing inward.                                     |
| **Port**                   | An interface that defines how the application core communicates with external systems (part of Hexagonal Architecture).                    |
| **Query**                  | In CQRS, a request for data that doesn't change system state, optimized for reading operations.                                            |
| **Repository**             | A pattern that encapsulates the logic needed to access data sources, centralizing common data access functionality.                        |
| **Rich Domain Model**      | A domain model where business logic is encapsulated within domain objects rather than external services.                                   |
| **Saga**                   | A pattern for managing long-running business processes that span multiple aggregates or bounded contexts.                                  |
| **Specification Pattern**  | A pattern used to encapsulate business rules and criteria that can be combined and reused.                                                 |
| **Ubiquitous Language**    | A common language shared by developers and domain experts within a bounded context.                                                        |
| **Use Case**               | A specific way the system is used by actors to achieve a goal, often implemented as application services.                                  |
| **Value Object**           | An object that describes characteristics or attributes but has no conceptual identity.                                                     |

## Guiding Principles

High level qualities that a good software architecture should (and enforce) strive for; maintainability, testability and loose coupling.

1. Separation of concerns: domain from external dependencies
2. Encapsulation: information hiding and isolating components from influence of others
3. Dependency inversion: depend on abstractions at compile time, and concrete implementations at runtime
4. Explicit dependencies: honesty about dependencies
5. Single responsibility: one reason to exist and to change
6. DRY: eliminate and encapsulate repetitive behavior
7. Persistence ignorance: domain entities are agnostic of physical storage
8. Bounded contexts: DDD conceptual model that groups related entities and behaviours together

## Clean Architecture Layers

### Domain layer

The inner heart layer, houses the most important enterprise logic and business rules. Housed in class library `src\Wintermute.Domain`.

- _Entities_: Represent core business objects with a unique identity that persists over time.
- _Value objects_: Immutable objects defined by their attributes, not identity, used to describe aspects of the domain.
- _Domain events_: Notifications that something significant has happened within the domain.
- _Domain services_: Stateless operations or business logic that don't naturally fit within an entity or value object.
- _Interfaces_: Abstractions that define contracts for dependencies, enabling inversion of control and testability.
- _Exceptions_: Domain-specific errors used to signal and handle invalid states or business rule violations.
- _Enums_: Enumerations representing a fixed set of related constants, often used for domain concepts with limited options.

#### Entities

An object in your domain that has an identity, and that identity is continuous. Meaning the existance of this entity throughout the lifetime of the application is important, and that it can evolve and change over time. Another consideration is entity equality.

Desirable design traits:

1. Has a continuous id.
2. Contains behavior, rich not anemic.
3. Can be compared.
4. Does not rely solely on primitive types (primitive obsession).
5. Disallows mutation of properties outside of the entity itself (encapsulation), promoting enforcement of invariants.
6. Hides its constructor and provides a factory method.

To centralise common entity concerns like this, will build out `abstract` class `Entity`.

Entities should not expose their constructor and instead provide a static factory method, for example called `Create()`. This keeps the constructor pure in that there is less pressure to overwhelm it with non-constructor concerns (because its a convenient lifecycle hook). The killer reason however, is because a factory method is likely to be laden with side effects in the form of domain events.


For a robust and consistent equality its best practice is to:

- Override `Equals(object?)` to compare entities by their identity.
- Override `GetHashCode()` to use the Id.
- Optionally, implement `IEquatable<Entity>` for type safety and performance.
- Overload the `==` and `!=` operators for convenience.





💀 Be wary of **anemic domain models** where domain objects (entities) primarily serve as data containers with little to no embedded business logic. The business logic is instead typically placed in separate service layers or managers, leading to a procedural programming style. This contrasts with a _rich domain model_ where entities encapsulate both data and behavior.

💀 **Primitive obsession** is a code smell where you overuse basic types (like `int`, `string`, `bool`, etc.) to represent domain concepts, instead of creating dedicated types or classes. For example, using a `string` for an email address or a `decimal` for money everywhere, rather than defining `EmailAddress` or `Money` value objects. Leading to lack of encapsulation for validation and behavior, increased risk of bugs (mixing up values, invalid data) and harder to understand and maintain code. In clean architecture and DDD, you avoid primitive obsession by modeling important domain concepts as their own types, making the code more expressive, safe, and maintainable.

#### Value Objects

An object that describes characteristics or attributes but has no conceptual identity. It instead is uniquely identified by its values. Structural equality, like this, is a first-class feature of a `record` type. Some value object examples coudl be `Name`, `Desciption` and `Address` properties on an entity. Each value object can encapsulate what it means for it to be empty, null, a single character and other validity conditions and so on. 

Desirable design traits:

1. Structural equality.
2. Immutable.

```csharp
public record Address(string Country, string State, string City, string Street, string ZipCode);
var a1 = new Address("US", "CA", "LA", "Main St", "90001");
var a2 = new Address("US", "CA", "LA", "Main St", "90001");
bool areEqual = a1 == a2; // true, value-based equality
```

#### Domain Events

Something of significance that has occurred in the domain that domain experts care about and that triggers side effects.

An interface called `IDomainEvent` will be used to define the shape of such events.




### Application layer

The middle layer.

1. Responsible for orchestrating the domain.
2. Higher level business logic that doesn't "fit" in the domain.
3. Defines the use cases. Drivers of behavior in the application across domain entities. Typically encoded as a set of _Appliation services_, or alternatively as the CQRS pattern with MediatR.

### Infrastructure layer

As one of the two outer layers, takes care of interfacing with external systems (DBs, queues, caches, S3, identity, etc).

### Presentation layer

Single point of entry to the application. Requests are processed by leveraging the layers below.

Typical examples: REST API, gRPC, SPA, CLI

## .NET Implementation Tips

- 2 top tier solution folders `src` and `test`
- House domain entities in its own classlib `Wintermute.Domain` organised by domain features, such as `Trading`, `Investments`.
- `record` types are a perfect fit for representing _Value Objects_, see [Records](#records)
- Entity classes should be `sealed`, preventing unwanted inheritance relationships.
- Entity properties should lean into `private set` heavily, disallowing external mutation.
- Static factory pattern. Entities should have a private constructor and a public `Create` method

### Records

A `record` is a special reference type designed for immutable data and value-based equality. Its main purposes are:

- Value-based equality: Two record instances are considered equal if all their properties are equal, unlike classes, which use reference equality by default.
- Immutability: Records are typically used with init-only properties or positional parameters, making them ideal for immutable data models.
- Concise syntax: Records support a compact syntax for declaring data-carrying types.

Differences from `class`:

- Value-based equality by default; class uses reference equality.
- Built-in immutability patterns; class does not.
- Supports with-expressions for non-destructive mutation.

Differences from `struct`:

- Is a reference type; struct is a value type.
- `record struct` exists, but a plain record is a reference type.
- `struct` is stored on the stack (when not boxed), while `record` (reference type) is stored on the heap.


```csharp
// simple record
public record Name(string Value);

// simple record with behaviour
public record Money(decimal Amount, Currency Currency)
{
    public static Money operator +(Money left, Money right)
    {
        if (left.Currency != right.Currency)
        {
            throw new InvalidOperationException("Cannot add Money with different currencies.");
        }
        return left with { Amount = left.Amount + right.Amount };
    }
}

// custom record
public record Currency
{
    public static readonly Currency USD = new("USD");
    public static readonly Currency EUR = new("EUR");
    public static readonly Currency GBP = new("GBP");
    public static readonly Currency JPY = new("JPY");
    public static readonly Currency AUD = new("AUD");
    
    private Currency(string code) => Code = code;

    public string Code { get; init; }

    public static Currency FromCode(string code)
    {
        return All.FirstOrDefault(c => c.Code == code) ?? 
            throw new ArgumentException($"Unsupported currency: {code}", nameof(code));
    }

    public static readonly IReadOnlyCollection<Currency> All =
    [
        USD, EUR, GBP, JPY, AUD
    ];
}
```


