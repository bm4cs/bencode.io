---
layout: post
title: "Architecture"
date: "2016-07-13 22:13:10"
comments: false
categories: "Geek"
---

A collection of software concepts I plan to apply to some up coming projects. Some fundamental philosophies:

- Automation everywhere.
- A clean (agnostic) contract with the underlying operating system, promoting portability between execution environments.
- Can scale without major changes to tooling, architecture or development.
- Smallest possible delta between development and production, enabling continuous integration.


## Deployment ##

- Processes are first class citizens. Execute the application as one or more **stateless** processes.
- Model *process types* explicitly, e.g. HTTP requests might be handled by a web process, while long running backend tasks by a worker process.
- Always rely on the operating systems user-space process manager (e.g. systemd, Upstart) to manage output streams, respond to crashed processes and handle user initiated restarts and shutdowns.
- Concurrency; 
- Physical distribution and clean contract with operating system, e.g. containers (e.g. docker).
- Versioning; the ability to deploy and hotswap versions side by side.
- Pluggable; ability to snap modules into architecture (punch through all layers), see *attached resources* under *backing services*.
- Store all runtime configuration as environmental variables. They are a language and OS agnostic standard, and unlike other config options such as Java System Properties, are not accidentially added into the source code repo.

> The array of process types and number of processes of each type is known as the process formation.


## "Backing" Services Layer ##

- Treat [backing services](http://12factor.net/backing-services) as attached resources.
- Represent these resources, both local and third-party, as *resource handles*; e.g. `postgres://auth@host/db`, `smtp://auth@host/`, `https://auth@s3.aws.com/`, `rabbitmq://auth@host/q`.
- Resources can be attached and detacted at will.
- Queuing.
- Events are king; model them as first class citizens.
- Contract first.
- Mapping layer.
- Idempotency - i.e. the ability to call a service multiple times with the same data, without it being lame.
- Security.
- Serialization e.g. protobuf.


## Integration ##

- Publish subscribe.
- Mapping layer.
- Circuit breakers/retry.
- Flow control.
- Dependency injection; mockable, can change.
- Transactions; i.e. "the million dollar invoice message" (JMS).
- Compensation/failure.
- Versioning.
- Facades around all third party APIs.
- Tracing for diagnostics.
- Auditing.
- Transport and message level security.
- Distributed event bus (kafka).


## Business Layer ##

- Loose coupling via contracts and publish subscribe.
- Events.
- Entities.
- Dependency injection.
- Mockable and testable.
- Reactive (non-blocking concurrency).
- Business rule engine.


## Exception Handling and Logging ##

- Treat logs as event streams e.g. kafka.
- Central facade.
- Policy driven e.g. abililty to alter behaviour without rewriting code.
- Distributed tracing e.g. zipkin.
- Regressions should be pinned down with unit tests.


## Monitoring and Health

- ELK (elasticsearch, logstash and kibana) stack.
- Health check REST endpoint.
- Capacity monitoring and logs.
- Infrastructure monitoring (jvm, database, disk, memory, processor).
- Self healing (proactive forecasting).


## Peristence ##

- DB vendor agnostic.
- ORM (object relational mapper).
- Replication.
- Hashing/encryption.
- Schema modification control scheme (e.g. dbup).
- Reference data control scheme.
- Distributed cache (Memcached).


## Adminstration ##

- Run administrative tasks (e.g. database migrations, accessing a REPL to inspect the live app, running one off scripts that are committed into the source repo, etc) as one-off processes.



## Build Tooling ##

- Dependency management (i.e. Maven, Gradle).
- Static analysis (e.g. FindBugs, Sonarqube).
- Task and issue management (JIRA).
- Security analysis.
- Unit tests, stubs, fakes, mocks.
- Repeatable robust builds (autotools, Maven).


## Reporting

- Pre-aggregated document objects.
- Hadoop.


## User Interface ##

- Action based MVC, e.g. Spring MVC.
- Clean data contracts with UI, enabling stateful clients; e.g. Angular, React.
- Stateless (session = evil), see *processes* above. Session state is a prime candidate for a datastore that offer time-expiration, e.g. Memcached, Redis.
- Web; minification, bundling.
- CSS with benefits - e.g. SASS/LESS.
- Bot interfaces (i.e. conversational based).
- Assign user unique identifier.
