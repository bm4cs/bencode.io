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

Thoughts and ideas from Uncle Bob's [Clean Architecture]()

## SOLID

### Single Responsibility Principle

SRP is commonly misconceived as doing one thing well. Instead is aimed at minimising the blast radius of change as the software itself relates to the real world concepts it represents. A module should have only one reason to change, which means it should be responsible to only one actor. This principle aims to avoid accidental duplication and ensure that changes in one part of the system don't unnecessarily affect other parts.

### Open-Closed Principle

Bertrand Meyer's premise from OOSC in the 80's, that software should be open for extension, but closed for modification. This means you should be able to add new functionality without changing existing code. This is achieved by separating the things that change for different reasons and then properly organising dependencies.

### Liskov Substitution Principle

Barbara Liskov's 1988 definition of subtypes, states that subtypes must be substitutable for their base types without altering the correctness of the program. It promotes building systems from interchangable pieces, which adhere to contacts that allowing each piece to be swapped out for another.

### Interface Segregation Principle

Avoid depending on things not used. The principle suggests that if a class uses only a subset of the operations of another class, it should not depend on the entire class. Depending on things that are not needed can lead to unexpected troubles and unnecessary redeployment. The ISP is a specific case of the more general principle, "Don't depend on things you don't need".

Dynamically typed langs like Python are less susceptible to inadvertant coupling to a type and all its symbols by design; statically typed and compiled langs like C# and Rust need to navigate, validate and bind these public facing symbols between components, effectively gluing them together regardless of use. Concrete example, all the functions with a struct get coupled to the call site in other components that use the struct, even if only a single function is used.

### Dependency Inversion Principle

The most flexible systems are those in which source code dependencies refer only to abstractions, not to concretions. High-level policies should not depend on low-level details; rather, details should depend on policies. The principle says to depend on abstractions (interfaces or abstract classes) rather than concrete implementations. The DIP inverts the direction of source code dependencies against the flow of control.
