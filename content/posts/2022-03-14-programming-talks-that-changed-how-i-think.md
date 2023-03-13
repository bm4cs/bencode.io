---
layout: post
draft: false
title: "Talks that changed The way I think about programming"
slug: "hackertalks"
date: "2022-03-14 16:34:20+11:00"
lastmod: "2022-03-14 16:34:25+11:00"
comments: false
categories:
    - talks
tags:
    - programming
    - inspirational
    - hacking
    - coding
    - dev
    - mustsee
---

[Oliver Powell](http://www.opowell.com/) put [this amazing original list](http://www.opowell.com/post/talks-that-changed-the-way-i-think-about-programming/) together in 2016. While I didn't appreciate the gravity of the list at the time, the talks have actually changed how I think about programming. Each of the presenters is not only incredibly intelligent but they have some serious credentials and achievements behind them. They in essence have much wisdom to impart. For example Rich Hickey, the creator of Closure, is brilliantly articulate and thought provoking.

I have started to sprinkle in other talks that have deeply impacted the way I think about software and complex systems. For example, [Bryan Cantrill](https://en.wikipedia.org/wiki/Bryan_Cantrill) from his Sun Microsystems fame most renown for DTrace, is perhaps my favourite computer scientist to watch. All of his talks are bursting with passion and wisdom.

-   [Rich Hickey on Simple Made Easy](#rich-hickey-on-simple-made-easy)
-   [Mike Acton on Data-orientated Design](#mike-acton-on-data-orientated-design)
-   [Jonathan Blow on Programming Aesthetics learned from making independent games](#jonathan-blow-on-programming-aesthetics-learned-from-making-independent-games)
-   [Eskil Steenberg on How I program in C](#eskil-steenberg-on-how-i-program-in-c)
-   [Rich Hickey on Hammock Driven Development](#rich-hickey-on-hammock-driven-development)
-   [Brian Will on Why OOP is Bad](#brian-will-on-why-oop-is-bad)
-   [Abner Coimbre on What Programming is Never About](#abner-coimbre-on-what-programming-is-never-about)
-   [Jeff and Casey Show on The Evils of Non-native Programming](#jeff-and-casey-show-on-the-evils-of-non-native-programming)
-   [Jeff and Casey’s Guide to Becoming a Bigger Programmer](#jeff-and-casey’s-guide-to-becoming-a-bigger-programmer)
-   [Hadi Hariri on The Silver Bullet Syndrome](#hadi-hariri-on-the-silver-bullet-syndrome)
-   [Bryan Cantrill on Fork Yeah! The Rise and Development if illumos](#bryan-cantrill-on-fork-yeah!-the-rise-and-development-if-illumos)
-   [Rob Pike on Concurrency Is Not Parallelism](#rob-pike-on-concurrency-is-not-parallelism)

## Rich Hickey on Simple Made Easy

[YouTube](https://www.youtube.com/watch?v=LKtk3HCgTa8)

> Simplicity is the ultimate sophistication - Leonardo da Vinci

Incredibly profound. Rich debunks many fads software developers jump into without thinking about too deeply.

-   Simple is NOT easy, and easy is NOT simple
-   Simple is _One fold/braid_, _One task_, _One concept_, _One dimension_ (NOT _One instance_, or _One operation_)
-   Simple is about lack of interleaving, not cardinality
-   Easy is _Near, at hand_
-   Simple is HARD
-   Complecting; the act of making something complex and tangled, often through the act of EASY decisions
-   Refactoring and TDD do not aid in deep understanding on a distilling simplicity. They are like slamming your car into the guard rails on the roadside.

> Complecting; To interleave, entwine, braid

Complex abstractions vs simple abstractions:

| Complexity                    | Simplicity                    |
| ----------------------------- | ----------------------------- |
| State, Objects                | Values                        |
| Methods                       | Functions, Namespaces         |
| `vars`                        | Managed refs                  |
| Inheritance, switch, matching | Polymorphism a la carte       |
| Syntax                        | Data                          |
| Imperative loops, fold        | Set functions                 |
| Actors                        | Queues                        |
| ORM                           | Declarative data manipulation |
| Conditionals                  | Rules                         |
| Inconsistency                 | Consistency                   |

Rich's simplicity toolkit:

| Construct                     | Get it by                                                                   |
| ----------------------------- | --------------------------------------------------------------------------- |
| Values                        | `final`, persistent collections                                             |
| Functions                     | Stateless methods                                                           |
| Namespaces                    | Language support                                                            |
| Data                          | Maps, arrays, set, XML, JSON (NOT objects!)                                 |
| Polymorphism a la carte       | Protocols, type classes, interfaces                                         |
| Managed refs                  | Clojure or Haskell refs                                                     |
| Set functions                 | Libraries                                                                   |
| Queues                        | Libraries                                                                   |
| Declarative data manipulation | SQL, LINQ, Datalog                                                          |
| Rules                         | Use declarative rule systems (NOT embedding conditions in our raw language) |
| Consistency                   | Transactions, values                                                        |

Designing simple constructs:

-   Abstract _definition; to draw away_
-   Seeks answers to who, what, when, where, why and how
-   What? Declarative contract of operations (with polymorphism tool lang gives you), small cohesive sets, don't complect with How. By strictly separating what from how, is the key to making how something else's problem (e.g. database or logic engine you figure out how to solve this problem).
-   Who? Entities implementing abstractions, build entities from injected and granular subcomponents, smaller interfaces, way more subcomponents
-   How? Implementing the actual logic. Connect abstractions and entities using polymorphism constructs. Abstractions should not dictate how. Implementations should be islands.
-   When and Where? Stenuously avoid complecting these with anything in the design. Often seep in via directly connected objects (e.g., A directly invokes B, A must know about B now and also when B is ready to receive a message). Use queues extensively to break this coupling. Use queues RIGHT NOW.
-   Why? Policy and rules of the application. Hard. Often scattered in logic everywhere. Find a declarative or rules system.

Information is simple:

-   Don't ruin information.
-   By hiding it behind a micro-language (i.e., a class with information specific methods)
-   Mashing information in objects thwarts generic data composition (i.e., ruins the ability to build generic data manipulation)
-   If you leave data alone, you can build things once that manipulate data and re-use them all over the place.
-   Packing data into objects ties logic to representation, complecting
-   Represent data as data; start using maps and sets directly, not writing a new class for each new piece of information!

Simplicity made easy:

-   Choose simple constructs over complexity generating constructs (see toolkits above)
-   Create abstractions with simplicity as a basis
-   Simplify the problem space before starting
-   Simplicity often means making more things, not fewer (i.e., rather have more straight things hanging down simply, than fewer strands all twisted together).

## Mike Acton on Data-orientated Design

[YouTube](https://www.youtube.com/watch?v=rX0ItVEVjHc&t=1306s)

## Jonathan Blow on Programming Aesthetics learned from making independent games

[YouTube](https://www.youtube.com/watch?v=JjDsP5n2kSM)

-   Avoid optimization (and wasting time thinking about it). You don't usually need it in most cases.
-   Use Arrays for everything. Data structures are about optimisation.
-   Don't build generalized systems. They are worse than hard-coded ones.
-   Deleting code is better than adding code.
-   Prefer big top-to-bottom straightforward functions, instead of function calls

## Eskil Steenberg on How I program in C

[YouTube](https://www.youtube.com/watch?v=443UNeGrFoM)

This is a talk I (@eskilsteenberg) gave in Seattle in October of 2016. I cover my way of programing C, the style and structure I use and some tips and tricks. Fair warning: There is a fair bit of Programming religion in this talk.

## Rich Hickey on Hammock Driven Development

[YouTube](https://www.youtube.com/watch?v=f84n5oFoZBc)

[Presentation breakdown and notes](https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/HammockDrivenDev.md)

Many gems, here's one:

-   Problem solving is definitely a skill. Polya wrote this amazing book called, 'How to Solve It' in 1945 which is about how to practice and what the techniques of solving math problems, in this case. It's a terrific book, full of great insight and if you've never read it, go onto Amazon right after my talk and order yourself a copy.

## Brian Will on Why OOP is Bad

[YouTube](#todo)

## Abner Coimbre on What Programming is Never About

[YouTube](#todo)

## Scott Meyers on CPU Caches and Why You Care

[YouTube](#todo)

## Jeff and Casey Show on The Evils of Non-native Programming

[YouTube](#todo)

## Jeff and Casey’s Guide to Becoming a Bigger Programmer

[YouTube](#todo)

## Hadi Hariri on The Silver Bullet Syndrome

[YouTube](#todo)

## Bryan Cantrill on Fork Yeah! The Rise and Development if illumos

[YouTube](https://m.youtube.com/watch?v=-zRN7XLCRhc)

Some great history about Sun Microsystems. Perhaps my favourite quote (copied from [news.ycombinator](https://news.ycombinator.com/item?id=5170246)):

> As you know people, as you learn about things, you realize that these generalizations we have are, virtually to a generalization, false. Well, except for this one, as it turns out. What you think of Oracle, is even truer than you think it is. There has been no entity in human history with less complexity or nuance to it than Oracle. And I gotta say, as someone who has seen that complexity for my entire life, it's very hard to get used to that idea. It's like, 'surely this is more complicated!' but it's like: Wow, this is really simple! This company is very straightforward, in its defense. This company is about one man, his alter-ego, and what he wants to inflict upon humanity -- that's it! ...Ship mediocrity, inflict misery, lie our asses off, screw our customers, and make a whole shitload of money. Yeah... you talk to Oracle, it's like, 'no, we don't fucking make dreams happen -- we make money!' ...You need to think of Larry Ellison the way you think of a lawnmower. You don't anthropomorphize your lawnmower, the lawnmower just mows the lawn, you stick your hand in there and it'll chop it off, the end. You don't think 'oh, the lawnmower hates me' -- lawnmower doesn't give a shit about you, lawnmower can't hate you. Don't anthropomorphize the lawnmower. Don't fall into that trap about Oracle.

## Rob Pike on Concurrency Is Not Parallelism

[Vimeo](https://vimeo.com/49718712)

## James Mickens on JavaScript

[YouTube](https://www.youtube.com/watch?v=D5xh0ZIEUOE)

## Liz Rice on Containers From Scratch

[YouTube](https://www.youtube.com/watch?v=8fi7uSYlOdc)

## James Mickens on Why Do Keynote Speakers Keep Suggesting That Improving Security Is Possible?

[YouTube](https://www.youtube.com/watch?v=ajGX7odA87k)
