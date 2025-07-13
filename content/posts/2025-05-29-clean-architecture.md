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
    - [Domain Services](#domain-services)
    - [Interfaces](#interfaces)
    - [Results and Exceptions](#results-and-exceptions)
  - [Application layer: The Use Case Orchestrator](#application-layer-the-use-case-orchestrator)
    - [Dependency Injection and MediatR Bootstrapping](#dependency-injection-and-mediatr-bootstrapping)
    - [CQRS Abstractions](#cqrs-abstractions)
    - [Handling Domain Events](#handling-domain-events)
    - [Cross Cutting Concerns with MediatR Pipelines](#cross-cutting-concerns-with-mediatr-pipelines)
      - [Logging](#logging)
      - [Validation with FluentValidation](#validation-with-fluentvalidation)
  - [Infrastructure layer](#infrastructure-layer)
  - [Presentation layer](#presentation-layer)
- [.NET Implementation Tips](#net-implementation-tips)
  - [General .NET Tips](#general-net-tips)
  - [Domain Layer .NET Tips](#domain-layer-net-tips)
  - [Application Layer .NET Tips](#application-layer-net-tips)
  - [Bonus: Contemporary .NET gems](#bonus-contemporary-net-gems)
  - [Records](#records)
  - [MediatR](#mediatr)
    - [INotification and INotificationHandler](#inotification-and-inotificationhandler)
    - [IRequest and IRequestHandler](#irequest-and-irequesthandler)
    - [MediatR.Contracts Package](#mediatrcontracts-package)
  - [Visual Studio and Roslyn Code Quality Level Ups](#visual-studio-and-roslyn-code-quality-level-ups)

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


The five **Application Layer** key conerns:

**1. Use Case Orchestration**

Defines the "what" of business operations without caring about "how", by coordinating multiple domain services, entities, and repositories as workflow of business processes.

Example: `BookApartmentUseCase` orchestrates apartment availability checking, pricing calculation, booking creation, and payment processing.


**2. Higher-Level Business Logic**

Workflow logic that spans multiple aggregates (e.g. bookings, users, apartments, etc) by defining business rules that don't belong in any single domain entity. As this layer is now responsible for cross-aggregate interactions, it takes on the challenge of managing transactions and consistency rules.

Example: "Cancel booking if payment fails after 3 attempts" is business logic but involves multiple domains


**3. Cross-Cutting Concerns**

- Logging: What happened, when, and by whom
- Validation: Input validation and business rule validation
- Authorization: Who can perform which operations
- Caching: Performance optimizations

Examples: Log all booking attempts, validate user permissions, cache pricing calculations.


**4. Exception Translation & Handling**

Translates domain exceptions into application appropriate responses. The app layer needs to deal with infrastructure failures gracefully and provides meaningful error context for upper layers.

Example: Convert `DomainExceptionXYZ` to `ApplicationExceptionXYZ` with business contextual messaging.


**5. Dependency Injection Hub**

Due to its higher order nature, **Application Services** typically composite many pieces from the rich domain model. Given Clean Architecture embraces the **Dependency Inversion Principle** this is first touch point in the architecture to start defining **Depending Injection** policies, including infrastructure abstractions (repositories, external services) and cross-cutting concern behaviors.


**What the Application Layer Does NOT Do:**

- No business rules that belong in the domain
- No infrastructure concerns (database, external APIs, UI)
- No presentation logic (formatting, UI concerns)
- No low-level technical details


**Example Application Serivces:**

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

##### Logging

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

##### Validation with FluentValidation

**FluentValidation** is a popular .NET library for building strongly-typed validation rules for objects. It helps you separate validation logic from your models, making your code cleaner, more maintainable, and testable. TL;DR of how it works:

- You create validator classes by inheriting from `AbstractValidator<T>`, where `T` is your model type.
- Inside the validator, you define rules using a fluent API (e.g., `RuleFor(x => x.Property).NotEmpty().MaximumLength(100)`).
- Validators can be registered with the DI container using the `FluentValidation.DependencyInjectionExtensions` NuGet package.
- At runtime, you resolve and use validators to validate objects, receiving a result that lists any validation failures.

[ValidationBehavior.cs](https://github.com/bm4cs/PragmaticCleanArchitecture/blob/master/source/Bookify/src/Bookify.Application/Abstractions/Behaviors/ValidationBehavior.cs) is a working example.


**Step 1: MediatR pipeline that evaluates FluentValidation validators**

```csharp
// src\Bookify.Application\Abstractions\Behaviors\ValidationBehavior.cs
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
// src\Wintermute.Application\DependencyInjection.cs
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

```



### Infrastructure layer

As one of the two outer layers, takes care of interfacing with external systems (DBs, queues, caches, S3, identity, etc).

### Presentation layer

Single point of entry to the application. Requests are processed by leveraging the layers below.

Typical examples: REST API, gRPC, SPA, CLI



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
- .NET `record` types in combination with a **Primary Constructors** are an elegant way to represent concrete `IQuery` implementations, which in-turn implement MediatR `IRequest`. The  (i.e. the requests, not the handlers).
- `IRequestHandler` implementation should be `internal sealed` to prevent undesirable misuse or extension outside of the **Application Layer** assembly.
- **Queries** and **Commands** will need to accept and return data respectively. These data transport definitions (e.g. `BookingResponse`) should live in the Application Layer, close-by to the query or commands that work with them. As this layer will be marshalling the data between queries/commands, these DTO's should be as plain as possible (POCOs), comprising of primtive types and flat non-nested hierarchical structures.
- CQRS sets out the architectural bluebrint for keeping query and command logic separate - its often desirable to exploit differing techniques for querying the data versus modifying it. For example, using a micro ORM like Dapper for fast reads, but leaning into unit of work, repositories and entity framework for managing writes.
- MediatR provides `IPipelineBehavior` which is an elegant middleware, that allows you to hook and wrap `IRequest` and `INotification` events as they occur. Put these in `Wintermute.Application/Abstractions/Behaviors/`.
- 



### Bonus: Contemporary .NET gems

- `DateOnly` and `TimeOnly` structs (.NET6)
- Init properties (C#9) `public DateOnly End { get; init; }` can only be set during object initialization
- Primary Constructors (C#11) combines constructor parameters such as `public class User(string firstName)` directly with property initialization `public string FirstName { get; } = firstName;`. The optional constructor body uses the => syntax for any additional initialization logic.
- `switch` expressions (C#8)
- `null` forgiving operator e.g. `_value!` tells the compiler not to warn about `_value` possibly being `null`.
- The `implicit operator` in C# defines an implicit conversion between types, e.g. `public static implicit operator Result<T>(T? value) => Create(value)` allows assignment of a value of type `T` directly to a variable of type `Result<T>`, and the compiler will automatically convert it using the `Create` method. This simple assignment `Result<string> result = "hello";` implicitly calls `Result<string>.Create("hello")`
- `with` expressions: TODO
- Extension methods: TODO see `Wintermute.Application/DependencyInjection.cs`


**Primary Constructors:**

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

**Switch Expressions**:

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



#### INotification and INotificationHandler

`INotificationHandler<TNotification>` handles notifications (events) that may have multiple handlers, or in other words the publish/subscribe pattern. Used for domain or integration events. When a notification is published, all registered handlers are invoked. Examples: Sending an email, logging, or updating a read model after something happens.

#### IRequest and IRequestHandler

`IRequestHandler<TRequest, TResponse>` handles requests (commands or queries) that expect a single response, implementing the request/response pattern. Used for commands (write operations) or queries (read operations) where only one handler processes the request and returns a result. Examples: Creating a booking, fetching booking details.



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

