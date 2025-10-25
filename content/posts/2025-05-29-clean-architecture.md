---
layout: post
draft: false
title: "Clean Architecture"
slug: "cleanarch"
date: "2025-05-29 20:14:01+1000"
lastmod: "2025-09-13 13:13:01+1000"
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
    - [Domain Services](#domain-services)
    - [Interfaces](#interfaces)
    - [Results and Exceptions](#results-and-exceptions)
  - [Application layer: The Use Case Orchestrator](#application-layer-the-use-case-orchestrator)
    - [Application Layer Key Responsibilities](#application-layer-key-responsibilities)
      - [Use Case Orchestration](#use-case-orchestration)
      - [Higher Order Business Logic](#higher-order-business-logic)
      - [Cross Cutting Concerns](#cross-cutting-concerns)
      - [Exception Translation \& Handling](#exception-translation--handling)
      - [Dependency Injection Hub](#dependency-injection-hub)
    - [What the Application Layer Does NOT Do](#what-the-application-layer-does-not-do)
    - [Example Application Service](#example-application-service)
    - [Dependency Injection and MediatR Bootstrapping](#dependency-injection-and-mediatr-bootstrapping)
    - [CQRS Abstractions](#cqrs-abstractions)
    - [Handling Domain Events](#handling-domain-events)
    - [Cross Cutting Concerns with MediatR Pipelines](#cross-cutting-concerns-with-mediatr-pipelines)
      - [Logging Pipeline](#logging-pipeline)
      - [Validation Pipeline with FluentValidation](#validation-pipeline-with-fluentvalidation)
  - [Infrastructure layer](#infrastructure-layer)
    - [Infrastructure Layer Key Responsibilities](#infrastructure-layer-key-responsibilities)
      - [Data Persistence and Access](#data-persistence-and-access)
      - [External Service Integration](#external-service-integration)
      - [Cross Cutting Concerns Implementation](#cross-cutting-concerns-implementation)
      - [Event Handling Infrastructure](#event-handling-infrastructure)
    - [What the Infrastructure Layer Does NOT Do](#what-the-infrastructure-layer-does-not-do)
    - [Example Concrete Provider for IDateTimeProvider](#example-concrete-provider-for-idatetimeprovider)
    - [EF Core Setup](#ef-core-setup)
    - [Integrating Domain Entities with EF Core](#integrating-domain-entities-with-ef-core)
    - [Publishing Domain Events in the Unit of Work](#publishing-domain-events-in-the-unit-of-work)
    - [Handling Race Conditions with Optimistic Concurrency](#handling-race-conditions-with-optimistic-concurrency)
    - [Distributed Cache Service](#distributed-cache-service)
  - [Presentation layer](#presentation-layer)
    - [Presentation Layer Key Responsibilities](#presentation-layer-key-responsibilities)
    - [What the Presentation Layer Does NOT Do](#what-the-presentation-layer-does-not-do)
    - [API Controllers and Endpoints](#api-controllers-and-endpoints)
    - [Seed Data and EF Migrations](#seed-data-and-ef-migrations)
    - [Authentication (authn) with Keycloak](#authentication-authn-with-keycloak)
    - [Authorization (authz)](#authorization-authz)
      - [Role-based Authorization](#role-based-authorization)
      - [Permission-based (Policy) Authorization](#permission-based-policy-authorization)
      - [Resource-based Authorization](#resource-based-authorization)
- [.NET Implementation Tips](#net-implementation-tips)
  - [General .NET Tips](#general-net-tips)
  - [Domain Layer .NET Tips](#domain-layer-net-tips)
  - [Application Layer .NET Tips](#application-layer-net-tips)
  - [Infrastructure Layer .NET Tips](#infrastructure-layer-net-tips)
  - [Presentation Layer .NET Tips](#presentation-layer-net-tips)
- [Bonus: Contemporary .NET gems](#bonus-contemporary-net-gems)
  - [Primary Constructors](#primary-constructors)
  - [Switch Expressions](#switch-expressions)
  - [Records](#records)
  - [Async Tips](#async-tips)
  - [MediatR](#mediatr)
    - [IRequest and IRequestHandler - Request/Response](#irequest-and-irequesthandler---requestresponse)
      - [Publishing](#publishing)
    - [INotification and INotificationHandler - Pub/Sub](#inotification-and-inotificationhandler---pubsub)
      - [Publishing](#publishing-1)
    - [MediatR.Contracts Package](#mediatrcontracts-package)
  - [Visual Studio and Roslyn Code Quality Level Ups](#visual-studio-and-roslyn-code-quality-level-ups)
  - [dotnet CLI Tips](#dotnet-cli-tips)

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
| **Repository**             | A pattern that encapsulates the logic needed to access data sources, centralising common data access functionality.                        |
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

The inner heart layer, houses the most important enterprise logic and business rules. Housed in class library `src/Wintermute.Domain`.

- _Entities_: Represent core business objects with a unique identity that persists over time.
- _Value objects_: Immutable objects defined by their attributes, not identity, used to describe aspects of the domain.
- _Domain events_: Notifications that something significant has happened within the domain.
- _Domain services_: Stateless operations or business logic that don't naturally fit within an entity or value object.
- _Interfaces_: Abstractions that define contracts for dependencies, enabling inversion of control and testability.
- _Results and Exceptions_: Domain-specific errors used to signal and handle invalid states or business rule violations.
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

💀 **[Primitive obsession](https://luzkan.github.io/smells/primitive-obsession)** is a code smell where you overuse basic types (like `int`, `string`, `bool`, etc.) to represent domain concepts, instead of creating dedicated types or classes. For example, using a `string` for an email address or a `decimal` for money everywhere, rather than defining `EmailAddress` or `Money` value objects. Leading to lack of encapsulation for validation and behavior, increased risk of bugs (mixing up values, invalid data) and harder to understand and maintain code. In clean architecture and DDD, you avoid primitive obsession by modeling important domain concepts as their own types, making the code more expressive, safe, and maintainable.

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

Event driven architectures are a powerful way to keep components loosely coupled, and more importantly change and evolve behaviour over time.

- **Decoupling**: Domain logic doesn't need to know about emails, notifications, or external integrations
- **Single Responsibility**: Each handler has one clear purpose
- **Extensibility**: Easy to add new handlers without modifying existing code
- **Testability**: Handlers can be tested independently
- **Cross-Cutting Concerns**: Logging, caching, and validation can be added through MediatR behaviors

An interface called `IDomainEvent` and in-turn Mediatr's `INotification`, will be used to represent such events. For example a `SubscriptionExpiredEvent` domain event could be triggered when a customer subscription reaches expiration:

```csharp
public interface IDomainEvent : INotification { }

public class SubscriptionExpiredEvent : IDomainEvent
{
    public Guid SubscriptionId { get; }
    public Guid UserId { get; }
    public string PlanName { get; }
    public DateTime ExpiredAt { get; }
}
```

Downstream handlers might:

- Downgrade user permissions
- Send renewal reminder emails
- Archive user data
- Update billing system
- Log churn analytics

The base abstract `Entity`, which all **Entity** types inherit, is furnished with domain event handling:

```csharp
public abstract class Entity(Guid id) : IEquatable<Entity>
{
    public Guid Id { get; init; } = id;
    private readonly List<IDomainEvent> _domainEvents = [];
    public IReadOnlyList<IDomainEvent> GetDomainEvents => _domainEvents.ToList();
    public void ClearDomainEvents() => _domainEvents.Clear();
    protected void RegisterDomainEvent(IDomainEvent domainEvent)
    {
        ArgumentNullException.ThrowIfNull(domainEvent);
        _domainEvents.Add(domainEvent);
    }
}
```

Now **Entities** and **Domain Services** have a consistent way of publishing **Domain Events**, in a clean agnostic manner. For example here the `Booking` entity hooks in domain eventing:

```csharp
public static Booking Reserve(
        Apartment apartment,
        Guid userId,
        DateRange duration,
        DateTime utcNow,
        PricingService pricingService
    )
{
    // DOUBLE DISPATCH PATTERN - dispatch to a Domain Service for cleaner rich domain models
    var pricingDetails = pricingService.CalculatePrice(apartment, duration);
    var booking = new Booking(
        Guid.NewGuid(),
        apartment.Id,
        userId,
        duration,
        pricingDetails.PriceForPeriod,
        pricingDetails.CleaningFee,
        pricingDetails.AmenitiesUpcharge,
        pricingDetails.TotalPrice,
        BookingStatus.Reserved,
        utcNow
    );
    booking.RaiseDomainEvent(new BookingReservedDomainEvent(booking.Id));
    apartment.LastBookedOnUtc = utcNow;
    return booking;
}
```

#### Domain Services

**Domain Services** exist to handle business logic that doesn't naturally belong to any single **Entity** or **Value Object**, but is still core domain knowledge. They represent pure business operations that coordinate between multiple domain objects or perform calculations that require specialised domain expertise.

Create **Domain Services** when you have business logic that:

1. Operates on multiple **Entity** and/or **Value Objects** from different aggregates (logical domain groupings)
1. Doesn't conceptually belong to any single **Entity**
1. Represents a significant business operation or calculation
1. Requires domain expertise that would be awkward to place in an **Entity**

Such as a pricing calculator for AirBnb type booking service:

```csharp
// DOMAIN SERVICE - assess and work with Entity and/or Value Objects
public class PricingService
{
    public PricingDetails CalculatePrice(Apartment apartment, DateRange dateRange)
    {
        // Complex pricing logic that considers:
        // - Apartment characteristics (size, location, amenities)
        // - Date range factors (seasonality, demand, holidays)
        // - Market conditions, dynamic pricing rules
        // - Promotional discounts, loyalty programs

        return new PricingDetails(basePrice, adjustments, finalPrice);
    }
}
```

**Why a Domain Service is a good fit for this logic:**

- **Spans multi entity and value objects**: Uses both `Apartment` and `DateRange`
- **Complex business rules**: Pricing logic is sophisticated domain knowledge
- **Doesn't belong to Apartment**: An apartment doesn't "calculate its own price" - pricing is a higher order business concern
- **Pure domain logic**: No infrastructure dependencies

**Key Traits of a Domain Service**

1. **Stateless**: They don't hold state between operations
1. **Pure Business Logic**: Focus solely on domain rules and calculations
1. **Domain Language**: Methods express business concepts (CalculatePrice, ValidateBooking)
1. **No Infrastructure**: Don't depend on databases, external APIs, etc.

Common examples:

- `LoanApprovalService` that evaluates an finance application, which considers credit scoring, risk assessment, policy rules, etc.
- `ShippingCalculatorService` that determines shipping for e-commerce orders, that considers weight, distance, carriers, promotions, etc.
- `DosageCalculationService` for a healthcare provider that calculates a clients dosage needs based on age, weight, medical history, intolerances, etc.

#### Interfaces

The **Repository** and **Unit Of Work** patterns, and their associated abstractions need to live in the domain, this is critical for defining a rich domain model. The definition of "repository" can be further tightened to **Entity Repository**, each concerned with one type of domain entity - which has a few architectural benefits:

- Single Responsibility: Each repository has clear, focused methods for one type of aggregate
- Encapsulation: Repository methods can express domain specific concepts e.g. `FindOverdueOrders()` vs generic `Find()`
- Testability: Easy to mock specific entity repositories for unit testing

**What problem does the Repository Pattern actually solve?**

Without **Repository** and **Unit of Work**, domain entities become anemic i.e. they can't perform business operations that require data access because they'd need direct dependencies on infrastructure concerns like databases, ORMs, or external services. This violates the **Dependency Inversion Principle** and makes your domain layer impure.

The **Repository** abstraction allows domain entities and services to work with collections of objects as if they were in-memory, without knowing about persistence details, these benefits:

1. Domain entities can perform complex business logic that requires querying or modifying related data
2. Domain services can orchestrate operations across multiple entities without infrastructure dependencies
3. Business rules stay in the domain rather than leaking into application services

```csharp
// ANEMIC - business logic pushed to application layer
public class Order
{
    public decimal Total { get; private set; }
    public void SetTotal(decimal total) => Total = total;
}

// RICH - business logic stays in domain
public class Order
{
    public decimal CalculateTotal(IProductRepository productRepository)
    {
        var products = productRepository.GetByIds(this.ProductIds);
        return products.Sum(p => p.Price * GetQuantity(p.Id));
    }
}
```

**Unit of Work, what's its purpose?**

There will be repositories that sit across functional boundaries. A business interaction may enact change across them. This is where the UoW comes in, it ensures that all changes within a business transaction are treated as a single atomic operation - preserving domain invariants across aggregate boundaries - its key value adds to the architecture:

- Consistency: Multiple aggregate changes happen together or not at all
- Performance: Batches database operations instead of individual saves
- Transaction Management: Handles complex business processes that span multiple entities

#### Results and Exceptions

**Errors** represents something that went wrong:

```csharp
public record Error(string Code, string Name)
{
    public static Error None = new Error(string.Empty, string.Empty);
    public static Error NullValue = new("Error.NullValue", "Null value encountered");
}
```

**Result** represents a domain layer outcome:

`Result` will be used by the **Domain Layer** to return a descriptive outcome of what occurred to upper layers, specifically the **Application Layer**. Either success that the business rules were satisfied, or an error with a fault and description clearly articulating the business rule that was broken.

```csharp
using System.Net.Http.Headers;

namespace Bookify.Domain.Abstractions;

public class Result
{
    protected internal Result(bool isSuccess, Error error)
    {
        IsSuccess = isSuccess;
        Error = error;
    }

    public bool IsSuccess { get; }
    public bool IsFailure => !IsSuccess;
    public Error Error { get; }

    public static Result Success() => new(true, Error.None);
    public static Result Failure(Error error) => new(false, Error.None);
    public static Result<T> Success<T>(T value) => new(value, true, Error.None);
    public static Result<T> Failure<T>(Error error) => new (default, false, error);
    public static Result<T> Create<T>(T? value) =>
        value is not null ? Success(value) : Failure<T>(Error.NullValue);
}


public class Result<T> : Result
{
    private readonly T? _value;

    protected internal Result(T? value, bool isSuccess, Error error) : base(isSuccess, error)
    {
        _value = value;
    }

    public T Value => IsSuccess
        ? _value!
        : throw new InvalidOperationException("Cannot access Value on a failure result.");

    public static implicit operator Result<T>(T? value) => Create(value);
}
```

### Application layer: The Use Case Orchestrator

Housed in class library `src/Wintermute.Application`, the **Application Layer** is the middle layer that defines **Use Cases** by orchestrating the **Rich Domain Model**. It's the "conductor" that coordinates domain objects to fulfill business scenarios. This layer has no external concerns of its own. **CQRS** (Command Query Responsibility Segregation) is a powerful approach to organising this layer, in a nutshell split data reads (queries) and writes (commands) apart. Cross-cutting concerns will be elegantly managed using the **Decorator Pattern** with MediatR pipeline behaviours (middleware).

#### Application Layer Key Responsibilities

##### Use Case Orchestration

Defines the "what" of business operations without caring about "how", by coordinating multiple domain services, entities, and repositories as workflow of business processes.

Example: `BookApartmentUseCase` orchestrates apartment availability checking, pricing calculation, booking creation, and payment processing.

##### Higher Order Business Logic

Workflow logic that spans multiple aggregates (e.g. bookings, users, apartments, etc) by defining business rules that don't belong in any single domain entity. As this layer is now responsible for cross-aggregate interactions, it takes on the challenge of managing transactions and consistency rules.

Example: "Cancel booking if payment fails after 3 attempts" is business logic but involves multiple domains

##### Cross Cutting Concerns

- Logging: What happened, when, and by whom
- Validation: Input validation and business rule validation
- Authorization: Who can perform which operations
- Caching: Performance optimizations

Examples: Log all booking attempts, validate user permissions, cache pricing calculations.

##### Exception Translation & Handling

Translates domain exceptions into application appropriate responses. The app layer needs to deal with infrastructure failures gracefully and provides meaningful error context for upper layers.

Example: Convert `DomainExceptionXYZ` to `ApplicationExceptionXYZ` with business contextual messaging.

##### Dependency Injection Hub

Due to its higher order nature, **Application Services** typically composite many pieces from the rich domain model. Given Clean Architecture embraces the **Dependency Inversion Principle** this is first touch point in the architecture to start defining **Depending Injection** policies, including infrastructure abstractions (repositories, external services) and cross-cutting concern behaviors.

#### What the Application Layer Does NOT Do

- No business rules that belong in the domain
- No infrastructure concerns (database, external APIs, UI)
- No presentation logic (formatting, UI concerns)
- No low-level technical details

#### Example Application Service

Example Application Service (traditional) implementation:

```csharp
public class BookingApplicationService
{
    public async Task<BookingResult> BookApartment(BookApartmentRequest request)
    {
        // Orchestrate domain operations
    }
}
```

CQRS with MediatR:

```csharp
public class BookApartmentCommandHandler : IRequestHandler<BookApartmentCommand, BookingResult>
{
    public async Task<BookingResult> Handle(BookApartmentCommand command, CancellationToken cancellationToken)
    {
        // Same orchestration, different structure
    }
}
```

**Example Use Case Flow:**

```csharp
public class BookApartmentUseCase
{
    public async Task<BookingResult> Execute(BookingRequest request)
    {
        // 1. Validate input (Application concern)
        await _validator.ValidateAsync(request);

        // 2. Check availability (Domain orchestration)
        var apartment = await _apartmentRepository.GetByIdAsync(request.ApartmentId);
        var availability = _availabilityService.CheckAvailability(apartment, request.DateRange);

        // 3. Calculate pricing (Domain service)
        var pricing = _pricingService.CalculatePrice(apartment, request.DateRange);

        // 4. Create booking (Domain operation)
        var booking = apartment.CreateBooking(request.GuestId, request.DateRange, pricing);

        // 5. Save and publish events (Application orchestration)
        await _unitOfWork.SaveAsync();
        await _mediator.Publish(new BookingCreatedEvent(booking.Id));

        // 6. Return result (Application concern)
        return new BookingResult(booking.Id, pricing.Total);
    }
}
```

#### Dependency Injection and MediatR Bootstrapping

Due to its higher order nature, **Application Services** typically composite many pieces from the rich domain model. Given Clean Architecture embraces the **Dependency Inversion Principle** this is first touch point in the architecture to start defining **Depending Injection** policies, including infrastructure abstractions (repositories, external services) and cross-cutting concern behaviors.

Create a top level `DependencyInjection.cs` class.

MediatR has an incredible `IServiceCollection.AddMediatR` (aka the built-in .NET IoC container) extension method that will automatically register handler and mediator types with MediatR.

```csharp
public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddMediatR(configuration =>
        {
            configuration.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly);
        });
        services.AddTransient<PricingService>();
        return services;
    }
}
```

#### CQRS Abstractions

**CQRS** (Command Query Responsibility Segregation) is a powerful approach to organising this layer, which in a nutshell splits data reads (queries) and writes (commands) apart.

Here we define abstractions `IQuery` and `ICommand` to represent reads and writes respectively.

```csharp
// query request
public interface IQuery<TResponse> : IRequest<Result<TResponse>> { }

// query handler
public interface IQueryHandler<in TQuery, TResponse> : IRequestHandler<TQuery, Result<TResponse>>
    where TQuery : IQuery<TResponse> { } // <in TQuery> = contravariant

// command request
public interface IBaseCommand  { }
public interface ICommand : IRequest<Result>, IBaseCommand  { } // Command that returns nothing
public interface ICommand<TResponse> : IRequest<Result<TResponse>>, IBaseCommand  { } // Command that returns a response

// command handler
public interface ICommandHandler<TCommand> : IRequestHandler<TCommand, Result> where TCommand : ICommand { }
public interface ICommandHandler<TCommand, TResponse> : IRequestHandler<TCommand, Result<TResponse>> where TCommand : ICommand<TResponse> { }
```

Example of a concrete command its associated handler:

```csharp
public sealed record ReserveBookingCommand(
    Guid ApartmentId,
    Guid UserId,
    DateOnly StartDate,
    DateOnly EndDate) : ICommand<Guid>;

internal sealed class ReserveBookingCommandHandler : ICommandHandler<ReserveBookingCommand, Guid>
{
    public Task<Result<Guid>> Handle(ReserveBookingCommand request, CancellationToken cancellationToken)
    {
        throw new NotImplementedException();
    }
}
```

#### Handling Domain Events

Refer to [BookingReservedDomainEventHandler.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Application/Bookings/ReserveBooking/BookingReservedDomainEventHandler.cs).

Considerations:

1. Subscribe to **Domain Events** emitting from the **Domain Layer**, by implementing MediatR's ` INotificationHandler` contract, for example ` INotificationHandler<BookingReservedDomainEvent>`
2. Place each individual **Domain Handler** in the same directory where the respective `ICommand` and `ICommandHandler` lives, that is responsible for triggering the event. This keeps these mediation types semantically clumped together.
3. Naming convension suggestion, add the `Handler` suffix to the OG domain event name. Like this: `BookingReservedDomainEvent => BookingReservedDomainEventHandler`

```
.
├── Bookify.Application
│   ├── Bookings
│   │   └── ReserveBooking
│   │       ├── BookingReservedDomainEventHandler.cs
│   │       ├── ReserveBookingCommand.cs
│   │       └── ReserveBookingCommandHandler.cs
```

#### Cross Cutting Concerns with MediatR Pipelines

##### Logging Pipeline

One of the design traits of having all `ICommand` variations implement `IBaseCommand` is that we can hook them all as a single generic type arg when leveraging MediatR pipelines. This [LoggingBehavior.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Application/Abstractions/Behaviors/LoggingBehavior.cs) MediatR pipeline will log all `ICommand` related activity.

1. Install the `Microsoft.Extensions.Logging.Abstractions` NuGet package.
2. Create the MediatR pipeline class [LoggingBehavior.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Application/Abstractions/Behaviors/LoggingBehavior.cs)
3. Register the pipeline with the dependency injection setup.

Pipeline behavior:

```csharp
public class LoggingBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IBaseCommand
{
    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken
    )
    {
        var name = request.GetType().Name;
        try
        {
            _logger.LogInformation("Executing command {Command}", name);
            var result = await next();
            _logger.LogInformation("Command {Command} processed successfully", name);
            return result;
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "Command {Command} processing failed", name);
            throw;
        }
    }
}

```

Dependency injection setup:

```csharp
services.AddMediatR(configuration =>
{
    configuration.AddOpenBehavior(typeof(LoggingBehavior<,>));
});
```

##### Validation Pipeline with FluentValidation

**FluentValidation** is a popular .NET library for building strongly-typed validation rules for objects. It helps you separate validation logic from your models, making your code cleaner, more maintainable, and testable. TL;DR of how it works:

- You create validator classes by inheriting from `AbstractValidator<T>`, where `T` is your model type.
- Inside the validator, you define rules using a fluent API (e.g., `RuleFor(x => x.Property).NotEmpty().MaximumLength(100)`).
- Validators can be registered with the DI container using the `FluentValidation.DependencyInjectionExtensions` NuGet package.
- At runtime, you resolve and use validators to validate objects, receiving a result that lists any validation failures.

[ValidationBehavior.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Application/Abstractions/Behaviors/ValidationBehavior.cs) is a working example.

**Step 1: MediatR pipeline that evaluates FluentValidation validators**

```csharp
// src/Bookify.Application/Abstractions/Behaviors/ValidationBehavior.cs
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IBaseCommand // pipeline only applicable to command types, not queries
    where TResponse : notnull // ensure that the response type is not null, a requirement in MediatR handlers
{
    private readonly IEnumerable<IValidator<TRequest>> _validators; // all relevant validators that apply to the request type

    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken
    )
    {
        if (!_validators.Any())
        {
            return await next(cancellationToken).ConfigureAwait(false);
        }

        var validationContext = new ValidationContext<TRequest>(request);

        var validationErrors = _validators
            .Select(v => v.Validate(validationContext))
            .Where(r => !r.IsValid)
            .SelectMany(r => r.Errors)
            .Select(validationError => new ValidationError(
                validationError.PropertyName,
                validationError.ErrorMessage
            ))
            .ToList();

        if (validationErrors.Count != 0)
        {
            throw new Exceptions.ValidationException(validationErrors);
        }

        return await next(cancellationToken).ConfigureAwait(false);
    }
}
```

**Step 2 Register ValidationBehavior pipeline with dependency injection:**

```csharp
// src/Wintermute.Application/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddMediatR(configuration =>
        {
            configuration.AddOpenBehavior(typeof(ValidationBehavior<,>));
        });
        // ...
        return services;
    }
}

```

**Step 3 Create specific AbstractValidator implementations:**

```csharp
// src/Bookify.Application/Bookings/ReserveBooking/ReserveBookingCommandValidator.cs
internal class ReserveBookingCommandValidator : AbstractValidator<ReserveBookingCommand>
{
    public ReserveBookingCommandValidator()
    {
        RuleFor(c => c.UserId).NotEmpty();
        RuleFor(c => c.ApartmentId).NotEmpty();
        RuleFor(c => c.StartDate).LessThan(c => c.EndDate);
    }
}
```

**Step 4 Register Validators with DI:**

```csharp
using Microsoft.Extensions.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        // ...
        services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly);
        return services;
    }
}

```

### Infrastructure layer

> If it's about "what the business does" rather than "how we technically accomplish it," it doesn't belong in the infrastructure layer.

As one of the two outer layers, the **infrastructure layer** serves as the implementation detail layer that handles all external concerns (e.g. configuration, secrets, environment, databases, queues, caches, S3, identity, etc). It's where abstract interfaces defined in the **application layer** get their concrete implementations. This layer is intentionally placed at the outermost ring because it deals with volatile, external dependencies that change frequently.

Typically housed as either a single class library such as `Wintermute.Infrastructure`, or by individual external concern such as `Wintermute.Infrastructure.Identity`, `Wintermute.Infrastructure.Queuing` and so on.

The infrastructure layer's isolation means your business logic remains testable and portable. You can swap out SQL Server for PostgreSQL, or replace Azure Service Bus with RabbitMQ, without touching your core business rules. This separation also enables easier testing through mocking and better adherence to the dependency inversion principle.
The layer typically contains adapters, gateways, and concrete implementations that translate between your domain's needs and the external world's constraints.

#### Infrastructure Layer Key Responsibilities

##### Data Persistence and Access

Beyond just EF Core setup, this includes implementing repository patterns, unit of work patterns, database migrations, connection string management, and query optimisation such as caching. You'll often find database specific logic here like stored procedure calls, bulk operations, or database specific performance optimisations.

##### External Service Integration

This encompasses REST API clients, SOAP service consumers, message queue producers/consumers (RabbitMQ), caching implementations (Redis, in-memory), file storage (Azure Blob, AWS S3), and email/SMS service integrations.

##### Cross Cutting Concerns Implementation

Logging frameworks (Serilog, NLog), security implementations (JWT handling, encryption), configuration management, health checks, and monitoring/telemetry collection all live here.

##### Event Handling Infrastructure

The concern of domain event publishing. This includes event bus implementations, outbox pattern for reliable messaging, event serialization, and integration event handling for communication between bounded contexts.

#### What the Infrastructure Layer Does NOT Do

- **Business Logic or Domain Rules**: The infrastructure layer should never contain business validation, calculations, or decision-making logic. If you find yourself writing "if the customer is premium, then..." in a repository or service client, that logic belongs in the domain or application layer.
- **Application Flow Control or Orchestration**: It shouldn't coordinate complex workflows, handle use case orchestration, or manage application-level transactions that span multiple operations. That's the application layer's responsibility - infrastructure just executes individual technical operations.
- **Data Transformation for Business Purposes**: While it may handle technical serialization (JSON to objects), it shouldn't transform data for business reasons. Converting a customer's raw data into a "risk score" or formatting display values belongs in higher layers.
- **Cross-Boundary Business Validation**: Infrastructure components shouldn't validate business rules that span multiple aggregates or enforce complex business constraints. They can handle technical validation (like "is this a valid email format") but not business validation (like "can this customer place this order").
- **Application State Management**: It shouldn't maintain application session state, user context, or coordinate between different parts of your application flow. Infrastructure provides services to the application layer but doesn't manage the application's logical state or progression.

#### Example Concrete Provider for IDateTimeProvider

**Step 1: Application Layer Abstract Provider**

Recall how the **Application Layer** defined abstract providers and services, in effect inverting the dependency tree, a cornerstone of clean architecture. Here is a simple example:

```csharp
// Bookify.Application/Abstractions/Clock/IDateTimeProvider.cs
public interface IDateTimeProvider
{
    DateTime UtcNow { get; }
}
```

**Step 2: Concrete Infrastructure Layer Implementation**

```csharp
// Bookify.Infrastructure/Clock/DateTimeProvider.cs
internal sealed class DateTimeProvider : IDateTimeProvider
{
    public DateTime UtcNow => DateTime.UtcNow;
}
```

**Step 3: Infrastructure Layer Dependency Injection**

```csharp
// Bookify.Infrastructure/DependencyInjection.cs
public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration
    )
    {
        services.AddTransient<IDateTimeProvider, DateTimeProvider>();
        services.AddTransient<IEmailService, EmailService>();
        return services;
    }
}
```

#### EF Core Setup

Entity Framework Core is Microsoft's object relational mapper (ORM) for .NET applications. It acts as a translation layer between your C# objects and your database tables. Instead of writing raw SQL queries, you work with regular C# classes and LINQ queries, and EF Core handles converting those into the appropriate SQL statements for your database.

Key capabilities:

- **Code first development**: define your database schema using C# classes and attributes
- **Database first development**: generate C# classes from an existing database
- **Change tracking**: automatically detects when your objects are modified and generates the appropriate `UPDATE` statements
- **Migrations**: version control for your database schema changes
- **LINQ query translation**: converts your C# LINQ queries into optimised SQL

EF Core supports multiple database providers (SQL Server, PostgreSQL, SQLite, MySQL, etc.) and handles the database-specific SQL generation for you. It's particularly valuable because it reduces boilerplate data access code, provides compile-time safety for queries, and integrates well with .NET's dependency injection and configuration systems.

**Example**:

```csharp
// Instead of writing: "SELECT * FROM Customers WHERE City = 'London'"
var londonCustomers = context.Customers
    .Where(c => c.City == "London")
    .ToList();
```

In our clean architecture, EF Core typically lives in the infrastructure layer as the concrete implementation of your repository interfaces.

1. Add NuGet package `Npgsql.EntityFrameworkCore.PostgreSQL` to `Wintermute.Infrastructure`
2. Define and initialise the `DbContext` in [Wintermute.Infrastructure/ApplicationDbContext.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/ApplicationDbContext.cs) as `public sealed class ApplicationDbContext : DbContext, IUnitOfWork { }`. Interestly `DbContext` already satisfies the `IUnitOfWork` contract out of the box, and can literally be injected as the `IUnitOfWork` implementation `services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<ApplicationDbContext>());`
3. Parse the DB connection string from config and bind it to `DbContext` using the database specific driver, in this case `services.AddDbContext<ApplicationDbContext>(options => options.UseNpgsql(connectionString));`.
4. Database specific tweaks. In the case of PostgreSQL it is common practice to always use snake casing name for tables. Add NuGet package `EFCore.NamingConventions`, which adds a `UseSnakeCaseNamingConvention` extension method to the `DbContextOptionsBuilder`.

#### Integrating Domain Entities with EF Core

This is where two worlds collide, the pure rich domain model and the storage concerns that EF core is concerned with. EF Core's _code first_ approach involves using an `EntityTypeBuilder` to express how the model works relationally and other DB enforcable traits that may apply to each domain model, all using a fluent style syntax. For example, here's the configuration for the `Apartment` domain model:

```csharp
// Wintermute.Infrastructure/Configurations/ApartmentConfiguration.cs
internal sealed class ApartmentConfiguration : IEntityTypeConfiguration<Apartment>
{
    public void Configure(EntityTypeBuilder<Apartment> builder)
    {
        builder.ToTable("apartments");

        builder.HasKey(apartment => apartment.Id);

        builder.OwnsOne(apartment => apartment.Address);

        builder
            .Property(apartment => apartment.Name)
            .HasMaxLength(200)
            .HasConversion(name => name.Value, value => new Name(value));

        builder
            .Property(apartment => apartment.Description)
            .HasMaxLength(2000)
            .HasConversion(description => description.Value, value => new Description(value));

        builder.OwnsOne(
            apartment => apartment.Price,
            priceBuilder =>
            {
                priceBuilder
                    .Property(money => money.Currency)
                    .HasConversion(currency => currency.Code, code => Currency.FromCode(code));
            }
        );

        builder.OwnsOne(
            apartment => apartment.CleaningFee,
            priceBuilder =>
            {
                priceBuilder
                    .Property(money => money.Currency)
                    .HasConversion(currency => currency.Code, code => Currency.FromCode(code));
            }
        );

        builder.Property<uint>("Version").IsRowVersion();
    }
}
```

Applying model configurations can be done automatically, by hooking the `OnModelCreating` event on the custom `DbContext` sub-class and sniffing the assembly for any `IEntityTypeConfiguration` implementations.

```csharp
public sealed class ApplicationDbContext : DbContext, IUnitOfWork
{
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
```

#### Publishing Domain Events in the Unit of Work

A common place (choak point) to evaluate and publish domain events is within the Unit Of Work, which in the case of EF Core is the `DbContext`. TL;DR add `PublishDomainEventsAsync` (see below) and invoke it in an override of `SaveChangesAsync`.

```csharp
public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
{
    var result = await base.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    await PublishDomainEventsAsync().ConfigureAwait(false);  // this could fail killing the transaction, level up with outbox
    return result;
}

private async Task PublishDomainEventsAsync()
{
    var domainEvents = ChangeTracker
        .Entries<Entity>()
        .Select(e => e.Entity)
        .SelectMany(e =>
        {
            var domainEvents = e.GetDomainEvents();
            e.ClearDomainEvents();  // Event handlers could in turn further DbContexts
            return domainEvents;
        })
        .ToList();

    foreach (var domainEvent in domainEvents)
    {
        await _publisher.Publish(domainEvent).ConfigureAwait(false); // MediatR publish
    }
}
```

#### Handling Race Conditions with Optimistic Concurrency

> In EF Core, [optimistic concurrency](https://learn.microsoft.com/en-us/ef/core/saving/concurrency?tabs=data-annotations) is implemented by configuring a property as a concurrency token. The concurrency token is loaded and tracked when an entity is queried. Then, when an update or delete operation is performed during `SaveChanges()`, the value of the concurrency token on the database is compared against the original value read by EF Core.

Here can leverage EF Core's `DbUpdateConcurrencyException`. So that the **Application Layer** remains insulated from infrastructure level concerns, publish a custom `ConcurrencyException` defined in the **Domain Layer**.

```csharp
// Wintermute.Infrastructure/ApplicationDbContext.cs
public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
{
    try
    {
        var result = await base.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        await PublishDomainEventsAsync().ConfigureAwait(false);
        return result;
    }
    catch (DbUpdateConcurrencyException ex)
    {
        throw new ConcurrencyException("Concurrency exception occurred.", ex);
    }
}
```

`ICommandHandler` implementations in the **Application Layer** can react to concurrency conflicts from a business perspective, for example in `ReserveBookingCommandHandler`:

```csharp
// Wintermute.Application/Bookings/ReserveBooking/ReserveBookingCommandHandler.cs
try
{
    var booking = Booking.Reserve(
        apartment,
        user.Id,
        duration,
        _dateTimeProvider.UtcNow,
        _pricingService
    );

    _bookingRepository.Add(booking);

    await _unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

    return booking.Id;
}
catch (ConcurrencyException)
{
    return Result.Failure<Guid>(BookingErrors.Overlap);
}
```

With concurrency detection and handling in place, the remaining piece is to instruct EF Core what specific fields should be used for row versioning. This is done in the `IEntityTypeConfiguration` definitions, for example `ApartmentConfiguration`:

```csharp
builder.Property<uint>("Version").IsRowVersion();  // adds a shadow state property, which the npgsql driver will back with an xmin system column
```

Npgsql will create a [concurrency token](https://www.npgsql.org/efcore/modeling/concurrency.html) that is backed with an `xmin` system column, which holds the ID of the last transaction that updated the row.

#### Distributed Cache Service

A cache that can be shared by multiple app servers, typically maintained as an external service to the app servers that access it. Some key traits of a distributed cache vs a simple in-memory cache:

- Is coherent (consistent) across requests to multiple servers
- Survives server restarts and app deployments
- Doesn't use local memory

.NET now provides an [IDistributedCache](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.caching.distributed.idistributedcache?view=net-9.0-pp) interface. Popular providers are provided for Redis, Postgres, SQL Server, NCache and more. I'm going with Postgres.

1. Add NuGet [Microsoft.Extensions.Caching.Postgres](https://www.nuget.org/packages/Microsoft.Extensions.Caching.Postgres) package to the infrastructure layer.
2. Create an `ICacheService` contract in the application layer.
3. Create an `ICacheService` implementation, `CacheService` in the infrastructure layer. This concrete leverages an `IDistributedCache` dependency, which defines basic async CRUD operations.
4. Setup dependency injection using [`DependencyInjection.cs`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/DependencyInjection.cs) in `Wintermute.Infrastructure`, create new extension method `AddCaching` to encapsulate this setup. This will include defining the various parameters to feed to the[ `AddDistributedPostgresCache`](https://www.nuget.org/packages/Microsoft.Extensions.Caching.Postgres) extension method, such as connection string, schema and table names, disable writeahead log (WAL) and more. Refer to package docs.

### Presentation layer

The bridge between the core business logic and the outside world. Its a receptionist; greets visitors, checks if they have appointments, direct them to the right department, and communicate responses back. They don't make business decisions or handle the actual work.

By separating the concern of how data is displayed/received and how business logic operates, allows change to occur in user interfaces, API formats, or communication protocols without impacting core business rules. For example, you could switch from a web API to a desktop application, or from REST to GraphQL, while keeping all your business logic intact.

Even more compelling, it encourages multiple presentation formats for the same underlying functionality. Such as serving web APIs, mobile apps, console applications, and background services simultaneously, each with their own presentation layer implementation.

#### Presentation Layer Key Responsibilities

- **Input Handling and Validation**: The presentation layer receives requests from external sources (HTTP requests, user input, messages) and performs initial validation like format checking, required field validation, and basic data type conversion. This is only structural validation, not business rule validation.
- **Request Translation**: It converts external requests into commands, queries, or DTOs that your application layer understands. For instance, transforming HTTP POST data into a `CreateGymMemberCommand` object.
- **Response Formatting**: Takes the results from your application layer and formats them appropriately for the consumer, serializing to JSON, rendering HTML views, formatting console output, so on.
- **Authentication and Authorization**: Handles user authentication (verifying identity) and often the first level of authorization (checking if a user can access an endpoint), though business level authorization should remain in deeper layers.
- **Error Handling and Translation**: Catches exceptions from inner layers and translates them into appropriate responses for the consumer (HTTP status codes, user-friendly error messages, etc).
- **Dependency Injection Configuration**: Often responsible for wiring up the dependency injection container and configuring how different layers glue together.

#### What the Presentation Layer Does NOT Do

- **Business Logic**: Never implement business rules, calculations, or domain-specific operations. The presentation layer shouldn't know that "premium customers get 10% discount" or "orders over $100 qualify for free shipping."
- **Data Access**: Should never directly query databases, call external APIs, or handle data persistence. All data operations should flow through the application layer.
- **Complex Validation**: While it can check if an email field contains an "@" symbol, it shouldn't validate business rules like "users can only have 5 active subscriptions."
- **State Management**: Shouldn't maintain business state between requests (beyond basic session/authentication data). Each request should be stateless from a business perspective.
- **Cross-Cutting Concerns Implementation**: While it might trigger logging or caching, the actual implementation of these concerns should be handled by infrastructure components, not embedded in presentation logic.

#### API Controllers and Endpoints

```csharp
[ApiController]
[Route("api/bookings")]
public class BookingsController : ControllerBase
{
    private readonly ISender _sender; // To publish MediatR events

    public BookingsController(ISender sender)
    {
        _sender = sender;
    }

    [HttpPost]
    public async Task<IActionResult> ReserveBooking(
        ReserveBookingRequest request, // Simple DTO to decouple presentation layer representation
        CancellationToken cancellationToken
    )
    {
        var command = new ReserveBookingCommand(
            request.ApartmentId,
            request.UserId,
            request.StartDate,
            request.EndDate
        );

        Result<Guid> result = await _sender
            .Send(command, cancellationToken)
            .ConfigureAwait(false);

        if (result.IsFailure)
        {
            return BadRequest(result.Error);
        }

        // RESTful return 201 for creation with location header to corresponding GET API
        return CreatedAtAction(nameof(GetBooking), new { id = result.Value }, result.Value);
    }
}
```

When dealing with more complex objects in the API's, its important to create a layer of DTO's that glue between the MVC API and **Query** or **Command** that is delegated to internally with the API. These simple .NET records should be placed next to the `Controller` classes, so they are nearby, as they are semantically related.

#### Seed Data and EF Migrations

ASP.NET core's `IApplicationBuilder` is abstracts the bootstrapping concerns of the underlying environment and provides a bunch of levers you can pull, such as access to the dependency injected services, bind middleware and more. Create a neat collection of `IApplicationBuilder` extension methods in `src\Bookify.Api\Extensions\ApplicationBuilderExtensions.cs`.

For example, this one will invoke an EF migration:

```csharp
public static void ApplyMigrations(this IApplicationBuilder app)
{
    using IServiceScope scope = app.ApplicationServices.CreateScope();
    using ApplicationDbContext dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    dbContext.Database.Migrate();
}
```

Glue it up in the APIs entry point:

```csharp
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
    app.ApplyMigrations();
    app.SeedData();
}
```

#### Authentication (authn) with Keycloak

Deals with the problem of "who" is accessing the system.

TODO: write up implementation notes

Problems to be solved:

1. Model pure concept of a **User** into the domain layer.

#### Authorization (authz)

Deals with the "what" the identity is permitted to do. The big 3 types of authz: role-based, permission-based and resource-based based.

##### Role-based Authorization

When an identity is created it may belong to one or more roles. For example, Alice may belong to the `Administrator` and `User` roles while Scott may only belong to the `User` role. How these roles are created and managed depends on the backing store. Unlike authentication, will not be leveraging keycloak for roles based access, and will instead handle them in the app directly, providing greater flexibility.

Plan of attack:

1. Secure routes to specific roles in the presentation layer.
2. Model the pure concept of a `Role` into the domain layer, and integrate into the `User` domain model.
3. Update the user registration components, to make use of the new `user.Roles`, and update repository persistence so that these roles get stored and queried appropriately.
4. Create an `IClaimsTransformation` implementation to inject custom managed roles into the `ClaimsPrincipal`, an extensiblility point provided by the .NET security components, allowing the foundational authz to work as is.

**Secure API Routes**:

In the case of ASP.NET, the `[Authorize(Roles = "PowerUser,Affiliate")]` custom attribute is provided, which can decorate routes, or the entire controller itself. Hard coding magic role strings into the attribute violates DRY, pop these into constants instead.

```csharp
[HttpGet("me")]
[Authorize(Roles = Roles.Registered)]
public async Task<IActionResult> GetLoggedInUser(CancellationToken cancellationToken) { }
```

**Domain Modelling**:

The [`Role`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Domain/Users/Role.cs):

```csharp
public sealed class Role(int id, string name)
{
    public static readonly Role Registered = new(1, "Registered");
    public int Id { get; init; } = id;
    public string Name { get; init; } = name;
    public ICollection<User> Users { get; init; } = new List<User>();
    public ICollection<Permission> Permissions { get; init; } = new List<Permission>();
}
```

And the [`User`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Domain/Users/User.cs):

```csharp
public sealed class User : Entity
{
    private User(Guid id, FirstName firstName, LastName lastName, Email email)
        : base(id)
    {
        FirstName = firstName;
        LastName = lastName;
        Email = email;
    }

    private User() { }
    private readonly List<Role> _roles = new();

    public FirstName FirstName { get; private set; }
    public LastName LastName { get; private set; }
    public Email Email { get; private set; }
    public string IdentityId { get; private set; } = string.Empty;
    public IReadOnlyCollection<Role> Roles => _roles.ToList();

    public static User Create(FirstName firstName, LastName lastName, Email email)
    {
        var user = new User(Guid.NewGuid(), firstName, lastName, email);
        user.RegisterDomainEvent(new UserCreatedDomainEvent(user.Id));
        user._roles.Add(Role.Registered);
        return user;
    }

    public void SetIdentityId(string identityId)
    {
        IdentityId = identityId;
    }
}

```

##### Permission-based (Policy) Authorization

Under the hood, role-based authorization and claims-based authorization use a requirement, a requirement handler, and a policy. These building blocks support the expression of authorization evaluations in code. The result is a richer (fine grained), reusable, testable authorization structure. An authorization policy is made up of one or more requirements.

Plan of attack:

1. Domain model the [`Permission`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Domain/Users/Permission.cs) concept into the domain layer.
2. Enhance the [`Role`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Domain/Users/Role.cs) domain model to support a collection of permissions.
3. Create a domain model to represent the many to many relationship between a Role and a Permission, called [`RolePermission`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Domain/Users/RolePermission.cs)
4. Create supporting entity framework (EF) configurations that support these domain models. This includes [`PermissionConfiguration`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/Configurations/PermissionConfiguration.cs), [`RolePermissionConfiguration`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/Configurations/RolePermissionConfiguration.cs) and updates to the [`RoleConfiguration`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/Configurations/RoleConfiguration.cs) to support it having a 1:\* of permissions.
5. Secure the API routes using `[Authorize(Roles="users:read")]` custom attribute.
6. Implement a custom `IAuthorizationHandler` to evaluate the custom permission scheme (`users:read` and so on). See [`PermissionAuthorizationHandler`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/Authorization/PermissionAuthorizationHandler.cs).
7. Implement a custom `AuthorizationPolicyProvider` glue up authz handler based on its supported requirement type. See [`PermissionAuthorizationPolicyProvider`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/Authorization/PermissionAuthorizationPolicyProvider.cs).
8. Dependency inject these two implementations, to plumb the handler into the overarching authorization system. See `AddAuthorization` in [`DependencyInjection.cs`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/DependencyInjection.cs), providing implementations for `IClaimsTransformation`, `IAuthorizationHandler` and `IAuthorizationPolicyProvider`.

**Secure API Routes**:

Instead of hard coding magic strings into `Authorize[]` an elegant pattern is to subclass a custom `AuthorizeAttribute`.

```csharp
public sealed class HasPermissionAttribute : AuthorizeAttribute
{
    public HasPermissionAttribute(string permission)
        : base(permission) { }
}
```

Define all permissions as constants:

```csharp
internal static class Permissions
{
    public const string UsersRead = "users:read";
}
```

Hook them up to routes as you would a standard `Authorize` attribute:

```csharp
[ApiController]
public class UsersController : ControllerBase
{
    [HttpGet("me")]
    [HasPermission(Permissions.UsersRead)]
    public async Task<IActionResult> GetLoggedInUser(CancellationToken cancellationToken)
    {
        ...
    }
}
```

**IAuthorizationHandler Implementation**:

An authorization handler is responsible for the evaluation of requirements, by marking the `AuthorizationHandlerContext` if they have been satisfied e.g. `context.Succeed(requirement)`. Here [`PermissionAuthorizationHandler`](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/Authorization/PermissionAuthorizationHandler.cs) will employ the `AuthorizationService` to surface up any permissions for the active user from the database. Note ceremony of creating `PermissionRequirement` marker interface, which in turn implements `IAuthorizationRequirement`. This marker interface is used to glue the handler up based on the requirement type.

```csharp
internal sealed class PermissionAuthorizationHandler : AuthorizationHandler<PermissionRequirement>
{
    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        PermissionRequirement requirement
    )
    {
        if (context.User.Identity is not { IsAuthenticated: true }) return;
        using var scope = _serviceProvider.CreateScope();
        var authorizationService = scope.ServiceProvider.GetRequiredService<AuthorizationService>();
        var identityId = context.User.GetIdentityId();
        var permissions = await authorizationService.GetPermissionsForUserAsync(identityId);
        if (permissions.Contains(requirement.Permission))
        {
            context.Succeed(requirement);
        }
    }
}
```


##### Resource-based Authorization

Although controllers and routes may enforce authenticated identities, resource-based authz is concerned with access to resources such as data, S3 objects, media files, and so on. For example although Alice and Bob are legitimate identities that are permitted to authenticate to the system, Alice should not be allowed to query Bob's data in the system, such as his bookings.

See [`GetBookingQueryHandler`](), which post validates if the active user matches the retrieved booking.



## .NET Implementation Tips

### General .NET Tips

- Simple source tree organisation with 2 top tier solution folders `src` and `test`
- Using `DateTime.UtcNow` directly is a DRY-ness code smell. For testability and maintainability, much better option is to define a common `IDateTimeProvider` abstraction.

```csharp
public interface IDateTimeProvider  // Wintermute.Application/Abstractions/Clock/IDateTimeProvider.cs
{
    DateTime UtcNow { get; }
}


// BEFORE
var booking = Booking.Reserve(
    apartment,
    user.Id,
    duration,
    DateTime.UtcNow,
    _pricingService
);


// AFTER
var booking = Booking.Reserve(
    apartment,
    user.Id,
    duration,
    _dateTimeProvider.UtcNow,
    _pricingService
);
```

### Domain Layer .NET Tips

- House domain entities in its own class library `Wintermute.Domain`. Source should be organised into directories that represent each domain function, such as `Trades`, `Investments`, `Bookings` and so on. Shared **Entity** or **Value Objects** such as `Money`, should be placed into a `Shared` directory.
- .NET `record` types provide the perfect traits for representing **Value Objects**, see [Records](#records)
- **Entity** classes should be `sealed`, preventing unwanted inheritance relationships.
- **Entity** properties should lean into `private set` heavily, disallowing external mutation.
- Each **Entity** should be a static factory. That is, a private constructor and a public `Create` method.
- **Domain Events** should use `Mediatr.Contracts` to keep the domain events lean and framrwork agnostic. These should be placed into `Events` directories within each functional domain e.g. `Bookings/Events`, `Users/Events`.
- The base `Entity` should feature a collection of `IDomainEvent`, to represent domain events raised by the entity, including associated CRUD methods, all `public` except `RaiseDomainEvent` which is `protected`.
- The **Repository Pattern** will encapsulate the storage of a domain model. Agnostic contracts should be placed in the Domain class library, as they will work against the pure domain models that live in here.
- For saving changes (i.e. mutating) an underlying data store, the **Unit Of Work Pattern** is a good fit, with its abstraction living in the domain model as `IUnitOfWork`.
- For inter **Entity** interactions, specifically when one entity needs to modify another entity, `private set` properties are too restrictive to permit this. An interesting design choice is to leverage `internal set`, which allows types within an assembly to change each others properties. In the context of the domain assembly, this is a nice fit.

### Application Layer .NET Tips

- The **Application Layer** can enjoy more concrete couplings to packages such as MediatR and Dapper for example, for concrete `IRequestHandler` and `INotification` implementations.
- The **Application Layer** will enjoy loose coupling to the **Domain Layer** by adopting CQRS using MediatR.
- Contravariant generic arguments in C# are specified with the `in` keyword, e.g: `public interface IQueryHandler<in TQuery, TResponse> : IRequestHandler<TQuery, Result<TResponse>>`. **Contravariance** allows you to use a less derived (more general) type than originally specified. Meaning its possible to assign an `IQueryHandler<BaseQuery, TResponse>` to a variable of type `IQueryHandler<DerivedQuery, TResponse>`, where `DerivedQuery` inherits from `BaseQuery`.
- Having the different `ICommand` variations implement a common interface `IBaseCommand`, is useful, for expressing MediatR pipeline subscriptions with generic typing constraints, which will be handy when dealing with cross-cutting concerns. Its also just a handy potential maintainablilty point.
- .NET `record` types in combination with a **Primary Constructors** are an elegant way to represent concrete `IQuery` implementations, which in-turn implement MediatR `IRequest`. The (i.e. the requests, not the handlers).
- `IRequestHandler` implementation should be `internal sealed` to prevent undesirable misuse or extension outside of the **Application Layer** assembly.
- **Queries** and **Commands** will need to accept and return data respectively. These data transport definitions (e.g. `BookingResponse`) should live in the Application Layer, close-by to the query or commands that work with them. As this layer will be marshalling the data between queries/commands, these DTO's should be as plain as possible (POCOs), comprising of primtive types and flat non-nested hierarchical structures.
- CQRS sets out the architectural bluebrint for keeping query and command logic separate. Its often desirable to exploit differing techniques for querying the data versus modifying it. For example, using a micro ORM like Dapper for fast reads, but leaning into unit of work, repositories and entity framework for managing writes.
- MediatR provides `IPipelineBehavior` which is an elegant middleware like implementation, that allows you to hook and wrap `IRequest` and `INotification` events as they occur. Put these in `Wintermute.Application/Abstractions/Behaviors/`.
- An incredibly elegant way to integrate cross cutting validation is by combining MediatR pipelines and FluentValidation, see [Validation Pipeline with FluentValidation](#validation-pipeline-with-fluentvalidation). TL;DR an `IPipelineBehavior` that applies to only `IBaseCommand` types (i.e. commands not queries), that through dependency injection only receives an applicable collection of `IValidator` implementations.

### Infrastructure Layer .NET Tips

- Create a `Wintermute.Infrastructure` class library. The **Infrastructure Layer**, as one of two bottom layers (outer layers of the onion), can leverge the **Application** and **Domain** layers. Add a project reference to `Wintermute.Application`.
- Like the **Application Layer**, will take care of dependency injection concerns that relate to infrastructure. Add a top level `DependencyInjection.cs`. Using `Microsoft.Extensions.DependencyInjection`, in addition to defining the `this IServiceCollection services` extension method, at this layer will want to bind in externally defined configuration via `IConfiguration`. Not a base class library, add a NuGet package for `Microsoft.Extensions.Configuration.Abstractions`.
- [Wintermute.Infrastructure/ApplicationDbContext.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/ApplicationDbContext.cs) the specific `DbContext` implementation already satisfies the `IUnitOfWork` contract out of the box, and can literally be injected as the `IUnitOfWork` implementation `services.AddScoped<IUnitOfWork>(sp => sp.GetRequiredService<ApplicationDbContext>());`
- Dapper by default doesn't know how to encode `DateOnly` types, a [DateOnlyTypeHandler](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/Data/DateOnlyTypeHandler.cs) Dapper `TypeHandler` is used. Finally Dapper needs to know about it at bootstrapping time (for example during DI setup) `SqlMapper.AddTypeHandler(new DateOnlyTypeHandler());`

### Presentation Layer .NET Tips

- Create `Wintermute.Api`, either as a minimal web API or full blown MVC API. Add references to the `Wintermute.Infrastructure` and `Wintermute.Application` projects.
- In API's `Program.cs` where the `WebApplicationBuilder` is bootstrapped and configured, register the **Infrastructure** and **Application** layers DI setup, but calling their respective builder extension methods, `builder.Services.AddInfrastructure(builder.Configuration)` and `builder.Services.AddApplication()` respectively.
- When dealing with more complex objects in the API's, its important to create a layer of DTO's that glue between the MVC API and **Query** or **Command** that is delegated to internally with the API. These simple .NET records should be placed next to the `Controller` classes, so they are nearby, as they are semantically related.
- In API's that create data, its RESTful to return an HTTP 201, with a `Location` header to the URI of the complimentary API responsible for retrieving the object. MVC provides `CreatedAtActionResult` to encapsulating this, for example: `return CreatedAtAction(nameof(GetBooking), new { id = result.Value }, result.Value)`.
- As an outer layer, the presentation is a good candidate for driving the architecture. It has concrete configuration i.e. `appsettings.json`, connection strings to DBs, etc. Lifecycle hooks are available here, such as the `IApplicationBuilder` in an MVC web API.
- Create a collection of extension methods `src\Bookify.Api\Extensions\ApplicationBuilderExtensions.cs`. Handy for hooking up exception and logging middleware, and running EF migrations to seed the DB when in development mode.
- Time to hook up EF migrations and seed data. Two recommendations here: (1) The `Bogus` NuGet package for creating synthetic test data, and (2) `dotnet tool install dotnet-ef` for CLI tooling for EF Core, and (3) the `Microsoft.EntityFrameworkCore.Design` NuGet package to the API project which glues up with the EF CLI tools.
- The `ef` tool must be run in context of the project repsonsible for the migrations, the `Wintermute.Infrastructure`. Additionally a `IDesignTimeDbContextFactory<ApplicationDbContext>` implementation needs to exist, which the EF tool will scan for in the assembly. This is purely intended as a design time concern, and does not have the overheads of dependency injection or config management, etc. It's common to no-op these runtime concerns, see [ApplicationDesignTimeDbContextFactory.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Infrastructure/ApplicationDesignTimeDbContextFactory.cs)
- Middleware here, is a great way to deal with cross-cutting concerns.

## Bonus: Contemporary .NET gems

- Destructured conditionals: `if (context.User.Identity is not { IsAuthenticated: true })`
- `DateOnly` and `TimeOnly` structs (.NET6)
- Init properties (C#9) `public DateOnly End { get; init; }` can only be set during object initialization
- Primary Constructors (C#11) combines constructor parameters such as `public class User(string firstName)` directly with property initialization `public string FirstName { get; } = firstName;`. The optional constructor body uses the => syntax for any additional initialization logic, see [Primary Constructors](#primary-constructors)
- `switch` expressions (C#8) see [Switch Expressions](#switch-expressions)
- `null` forgiving operator e.g. `_value!` tells the compiler not to warn about `_value` possibly being `null`.
- The `implicit operator` in C# defines an implicit conversion between types, e.g. `public static implicit operator Result<T>(T? value) => Create(value)` allows assignment of a value of type `T` directly to a variable of type `Result<T>`, and the compiler will automatically convert it using the `Create` method. This simple assignment `Result<string> result = "hello";` implicitly calls `Result<string>.Create("hello")`
- `with` expressions: TODO
- Extension methods: TODO see `Wintermute.Application/DependencyInjection.cs`
- `ArgumentNullException.ThrowIfNull(foo)`
- An EF gem I like is `HasData`, which is a code-first approach to reference data seeding e.g. `builder.HasData(Permission.UsersRead)`

### Primary Constructors

```csharp
// PRIMARY CONSTRUCTORS in C# 11
public class User(string firstName, string lastName)
{
    public string FirstName { get; } = firstName;
    public string LastName { get; } = lastName;

    // Optional constructor body
    => Console.WriteLine($"Created user: {firstName} {lastName}");
}
```

### Switch Expressions

```csharp
// SWITCH EXPRESSIONS in C# 8
public static class SwitchExample
{
    public enum Direction
    {
        Up,
        Down,
        Right,
        Left
    }

    public enum Orientation
    {
        North,
        South,
        East,
        West
    }

    public static Orientation ToOrientation(Direction direction) => direction switch
    {
        Direction.Up    => Orientation.North,
        Direction.Right => Orientation.East,
        Direction.Down  => Orientation.South,
        Direction.Left  => Orientation.West,
        _ => throw new ArgumentOutOfRangeException(nameof(direction), $"Not expected direction value: {direction}"),
    };

    public static void Main()
    {
        var direction = Direction.Right;
        Console.WriteLine($"Map view direction is {direction}");
        Console.WriteLine($"Cardinal orientation is {ToOrientation(direction)}");
        // Output:
        // Map view direction is Right
        // Cardinal orientation is East
    }
}
```

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

### Async Tips

- Always use `async Task<T>` or `async Task` for async methods
- Accept `CancellationToken` in all async APIs, which enables cooperative cancellation
- Pass `CancellationToken` down call chain
- Avoid `async void` (except event handlers)
- Use `ConfigureAwait(false)` to avoid capturing context (library code, non-UI), known as a continuation.
- Never block on async code (`.Result`, `.Wait()`), which causes deadlocks
- Prefer `ValueTask<T>` for high-frequency, allocation-sensitive paths
- Use `Task.WhenAll` for parallelism, not `Task.WaitAll`
- Return completed tasks for sync paths: `Task.CompletedTask`, `Task.FromResult(value)`
- Avoid fire-and-forget unless handled (log, observe exceptions), i.e. starting a `Task` without awaiting or tracking it
  - If the `Task` fails, exceptions are unobserved (can crash process or be lost)
  - No way to know if/when the work completed or failed
  - Always log, observe, or attach a continuation to handle errors

### MediatR

MediatR is a .NET library that implements the Mediator pattern. It acts as an in-process messaging framework that decouples components by providing a simple way to publish commands, queries, and notifications without having direct dependencies between classes.

The classical mediator design pattern introduces a hub in between objects that need to communicate; instead of communicating directly with each other, they go through a central mediator. This reduces coupling and makes code more maintainable.

Key use cases in an architecture:

- Commands: Actions that change state (e.g. `CreateGymCommand`)
- Queries: Read operations that return data (e.g. `GetGymByIdQuery`)
- Notifications: Events that can have multiple handlers, aka publish/subscribe (e.g. `GymCreatedEvent`)

In clean architecture, MediatR is particularly valuable:

- Decoupling: Your controllers don't need to know about specific business logic classes
- Single Responsibility: Each handler does one thing
- Cross-cutting Concerns: You can add behaviors like logging, validation, or caching through MediatR's pipeline behaviors
- Domain Events: Perfect for publishing domain events when business rules are triggered

#### IRequest and IRequestHandler - Request/Response

`IRequestHandler<TRequest, TResponse>` handles requests (commands or queries) that expect a single response, implementing the request/response pattern. Used for commands (write operations) or queries (read operations) where only one handler processes the request and returns a result. Examples: Creating a booking, fetching booking details.

##### Publishing

`IRequest` types can be sent using `IMediator.Send`. The cleanest approach, for decoupling and testability, is to dependency inject an `ISender` into the call sites that need to publish requests.

```csharp
private readonly ISender _sender;

public ApartmentsController(ISender sender)
{
    _sender = sender;
}

[HttpGet]
public async Task<IActionResult> SearchApartments(
    DateOnly startDate,
    DateOnly endDate,
    CancellationToken cancellationToken = default
)
{
    var query = new SearchApartmentsQuery(startDate, endDate);
    var result = await _sender.Send(query, cancellationToken).ConfigureAwait(false);
    // result is Task<Domain.Abstractions.Result<IReadOnlyList<ApartmentResponse>>>
}
```

#### INotification and INotificationHandler - Pub/Sub

`INotificationHandler<TNotification>` handles notifications (events) that may have multiple handlers, or in other words the publish/subscribe pattern. Used for domain or integration events. When a notification is published, all registered handlers are invoked. Examples: Sending an email, logging, or updating a read model after something happens.

##### Publishing

`INotification` types can be published using an `IPublisher`.

#### MediatR.Contracts Package

The `MediatR.Contracts` package contains just the core interfaces and contracts without the full implementation. This is good practice for a few reasons:

1. You want to reference MediatR interfaces in your domain layer without pulling in the full library
1. You're building libraries that need to expose MediatR contracts
1. You want to keep your domain layer lightweight, keeping your domain events clean and framework-agnostic while still leveraging MediatR's powerful dispatching capabilities in your infrastructure layer

```csharp
public class GymCreatedEvent : INotification
{
    public Guid GymId { get; }
    public string Email { get; }

    public GymCreatedEvent(Guid gymId, string email)
    {
        GymId = gymId;
        Email = email;
    }
}
```

### Visual Studio and Roslyn Code Quality Level Ups

`.editorconfig` allows you to configure the default code style rules you want to apply to your C# code. This [.editorconfig](#TODO) provides a set of sensible defaults to get started with.

The `Directory.Build.props` file allows you to define default dependencies for all your projects. Such as treating compiler warnings as errors (so you'll have to fix them) and to install the `SonarAnalyzer.CSharp` library that introduces additional source code analyzers.

### dotnet CLI Tips

```sh
# add NuGet package to project
dotnet add src/Bookify.Api/Bookify.Api.csproj package Microsoft.AspNetCore.Mvc

# restore NuGet packages
dotnet restore

# build the solution/project
dotnet build

# run the app (from project dir)
dotnet run --project src/Bookify.Api/Bookify.Api.csproj

# run all tests in solution
dotnet test

# publish for deployment (self-contained, release)
dotnet publish src/Bookify.Api/Bookify.Api.csproj -c Release -r win-x64 --self-contained true -o ./publish

# update all NuGet packages in a project
dotnet outdated src/Bookify.Api/Bookify.Api.csproj

# install tools from .config/dotnet-tools.json
dotnet tool restore

# list installed tools
dotnet tool list --local

# run a tool (ex: Cake build)
dotnet cake build.cake --target="$Target" --configuration="$Configuration"
```
