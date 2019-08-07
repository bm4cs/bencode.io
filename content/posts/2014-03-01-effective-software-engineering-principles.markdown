---
layout: post
title: "Essential software development toolkit"
date: "2014-03-01 21:46:37"
comments: false
categories: [General]
---

Sometimes life in the world of software can seem like complete chaos, and other times a well planned cathedral. Perhaps this is due to subjective nature of software itself. Like any other engineering related discipline (e.g. building construction), beauty is in the eyes of the creator. Also a happy customer is a happy customer...even if they want a [pink color scheme and pictures of kittens](http://theoatmeal.com/comics/design_hell) on their screens. Unlike the construction industry, a customer does not happily accept a product built on unreliable foundations, that is unmaintainable mess. Problems such as software quality and longevity, and even the impediance mismatch between customers and engineers, are by no means new problems, and have been solved in a plethora of ways a long time ago.


If I wanted to build some significant software right now, what are some of the best bang for buck, timeworn principles that can be applied?


### Humans (wetware)

The single most challenging subject. Humans. A common theme in modern methodologies and manifestos, such as agile/xp/reactive/devops/whatevs reminds us of the fruits that are born as a result of better communication, collaboration and integration with teams and people.


### Abstraction
One of the most beautiful characteristics of software, is the ability to separate ideas from specific instances of those ideas.

> Abstraction tries to factor out details from a common pattern so that programmers can work close to the level of human thought, leaving out details which matter in practice, but are exigent to the problem being solved.

Don't tie dependencies into the software too deeply. For example, would it not be useful to be able to swap out a particular library out for another implementation, not to be tied to a specific database vendor, adjust a piece of business logic without dumping everything like a stack of cards, and so on. Pluggabilty, facades, inversion of control, are just a few common approaches to abstraction.


### SOLID
Unless you're writing software for operating system kernels, the software you're working on is probably a representation of some sort of real-world problem. The real world unlike software is imperfect, and is constantly changing. The ability for a system to be easily maintained and extended over time is of great importance. If a system has not been designed to cope with change, as has been proven failed project after failed project, you face [the big ball of mud](http://blog.codinghorror.com/the-big-ball-of-mud-and-other-architectural-disasters/), [Gilligan's Island phenomenon](http://blog.codinghorror.com/escaping-from-gilligans-island/), and other similar architectural disasters. SOLID outlines five key principles when combined together, results in more "bendable" software:

*   **Single responsibility** - sometimes referred to as the "UNIX philosophy". A class (or a software entity) should only have a single concern. That is, it should be cohesive.
*   **Open/closed** - a class should be open for extension, but closed to modification. Guiding the nature of extension or future extensions that take place.
*   **Liskov substitution** - objects should be swappable with instances of their subtypes. A side effect of design by contract (DBC).
*   **Interface segregation** - 
*   **Dependency inversion** - dependencies should be based on abstractions, not concrete implementations. One of my favorite and most effective techniques.


### Broken Window Syndrome
A gem from [The Pragmatic Programmer](http://en.wikipedia.org/wiki/The_Pragmatic_Programmer). An great analogy of how, if we accept or tolerate small degradations in our software (e.g. bugs or bad design decisions), it is inevitable that the quality of the software will continue to decay with time. In other words don't turn a blind eye to broken things, even small things. Fix them.


### Design By Contract (DBC) 
I first read about the concept in Bertrand Meyer's classic [Object Oriented Software Construction](http://en.wikipedia.org/wiki/Object-Oriented_Software_Construction) (OOSC). DBC is a metaphor on how software entities collaborate, based on the real world metaphor where a "client" and a "supplier" agree on a contract (expectations and guarantees are formalised). 


### DRY (Don't Repeat Yourself)
Another veteran tip from [The Pragmatic Programmer](http://en.wikipedia.org/wiki/The_Pragmatic_Programmer). Involves eliminating (or reducing) the repetition of information. Layered architectures are particularly bad at this (e.g. quick litmus test: how many changes are required to add/remove a field from an entity - user interface, business logic, data access layer (DAL), database schema, service contracts, etc). Can't beat the original definition:

> "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system."


### Self Healing
I first heard about this concept in [The Lean Startup](http://theleanstartup.com), and it really resonated with me. In essence (the way I interpreted it anyway) as a software product evolves, it can go through many hardships (especially if you take the lean approach), but the general idea is that you are constantly learning from mistakes/bugs/errors that crop up. This should be viewed as extremely valuable data...dealing with these is a powerful way of injecting a dose of quality into the software. Therefore it is wise to invest in building a "first-aid" sub-system into the software, that has one responsibility. Taking care of the health and well being of the software. Some ways it might do this is by monitoring aspects of the environment when under load, and hypothesizing why things break when (see machine learning technique [anomaly detection](http://en.wikipedia.org/wiki/Anomaly_detection) for more), and in general just learning about the overall health of the software.


### Agile Manifesto
The [Manifesto for Agile Software Development](http://agilemanifesto.org).

> Individuals and interactions over processes and tools. Working software over comprehensive documentation. Customer collaboration over contract negotiation. Responding to change over following a plan.


### Richardson Maturity Model (REST)
[RMM](http://martinfowler.com/articles/richardsonMaturityModel.html) is a useful way to rank your API, given the constraints that REST imposes. The highest level (hypermedia controls) introduces the common (and ugly) HATEOAS acronym, Hypertext As The Engine Of Application State.


### Performance is a Feature
Inspired from the book [In The Plex](http://www.stevenlevy.com/index.php/books/in-the-plex). Assuming the book is true, Larry Page is obsessively focused on **performance**. So much so, he believes it to be the most important feature when designing and building software. Think about this...how wonderful is it when software is fast. It oozes good vibes, solid engineering. A user is far more likely to be delighted using the software. This thinking is evident in most Google based software I can think of.


### YAGNI (You Aren't Going to Need It)


### Command Query Responsibility Segregation (CQRS)
Defined eloquently by [Martin Fowler](http://martinfowler.com/bliki/CQRS.html). An architecture that is appropriate in specific instances. Put simply, is the use of different model to update information than the model used to read information. Unclear of the amount of uptake in the industry, but conceptually a wonderful idea.


### Don't Reinvent the Wheel
It's important to know your tools. This is particularly relevant if you have new players in your team that haven't been coding for long. If your coding Java for example, invest time in learning the ins-and-outs of the [API specification](http://docs.oracle.com/javase/7/docs/api/), and popular community driven libraries such as [Google Guava libraries](https://code.google.com/p/guava-libraries/).


### Fault Tolerance and Testing Failure Often
The behavior of software designs, especially distributed ones that depend on a number of subsystems, needs to be verified when certain resources and/or dependencies are eliminated. Inspired by one of my distributed system hero's [Udi Dahan](http://www.udidahan.com/) and his, what I call the "million dollar purchase order message" analogy. Consider every message that flows through a distributed system to be a million dollar purchase order...its very precious, and its unacceptable to loose the message due to the myriad of transient failures that can actually take place. Ask the "how can this fail?" question frequently. Udi's [Build Scalable Systems That Handle Failure Without Losing Data](http://msdn.microsoft.com/en-us/magazine/cc663023.aspx) article glosses over basic distributed system theory including durable messaging, system consistency, transactional messaging, transient conditions, and more.

> The mindset that served us well at every decision point was "how could this fail?" This lead to good judgment around the choice of technologies and how to design service contracts for stateful interactions.


### The Reactive Manifesto

[The Reactive Manifesto](http://www.reactivemanifesto.org/)

> We believe that a coherent approach to systems architecture is needed, and we believe that all necessary aspects are already recognised individually: we want systems that are Responsive, Resilient, Elastic and Message Driven. We call these Reactive Systems.


### Documentation
Depending on the code, it can be frustrating to reverse engineer your (or worse someone else's) thinking by going through code line by line, and unraveling peoples thought processes. The value in having some documentation (i.e. not hundreds of spewed out reverse engineered diagrams) that provide insights into the thinking and design, cannot be overstated. Wiki it, or maintain a little markdown file in the source repository so there is zero resistance to jot thinking down while in your code editor.


### OWASP (Open Web Application Security Project) Top 10

> The [OWASP Top Ten](https://www.owasp.org/index.php/Top10#OWASP_Top_10_for_2013) represents a broad consensus about what the most critical web application security flaws are. Project members include a variety of security experts from around the world who have shared their expertise to produce this list.


### The Worklist



### Automate The Build



### DevOps

> DevOps is a software development method that stresses communication, collaboration, integration, automation and measurement of cooperation between software developers and other information-technology (IT) professionals.


### Web Developer Checklist

A good [checklist](http://webdevchecklist.com/) helps consider "the web" from several perspectives, or gives you a bunch of different hats to try on. Put your usability and accessibility hats on for a moment...[accessibility validation](http://achecker.ca/checker/index.php), WCAG, favicon, print-friendly style sheets, color contrast validation, and a custom 404 page. What sort of [SenSEO](http://www.sensational-seo.com/) score does your site get? Did you remember an [XML sitemap](http://www.xml-sitemaps.com/) and [`robots.txt`](http://en.wikipedia.org/wiki/Robots_exclusion_standard) for SEO. What about a [`humans.txt`](http://humanstxt.org/) to attribute the [1337 h4x0r's](http://www.urbandictionary.com/define.php?term=1337%20h4x0r) that slapped the code together?


### Non-functionals Checklist

*   **Performance** (response times, processing times, query and reporting times)
*   **Security** (login requirements, password requirements)
*   **Upgradability** (patching, reverse patching)
*   **Audit** (audited elements, audited fields, audit file characteristics)
*   **Capacity** (throughput, storage, year-on-year growth)
*   **Availability** (hours of operation, locations of operation)
*   **Reliability** (mean time between failures, mean time to recovery)
*   **Integrity** (fault trapping, bad data trapping, data integrity)
*   **Recovery** (process, recovery time scales, backup frequencies, backup generations)
*   **Compatibility** (shared applications, 3rd party applications, operating systems, different platforms)
*   **Maintainability** (conformance to architecture standards, conformance to design standards, conformance to coding standards)
*   **Usability** (look and feel standards, internationalization/localization)

