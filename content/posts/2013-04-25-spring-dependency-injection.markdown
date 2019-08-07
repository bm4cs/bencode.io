---
layout: post
title: "Spring Dependency Injection"
date: "2013-04-25 21:58:05"
comments: false
categories: [Java]
---

Spring provides dependency injection capabilities using Setter injection, or Constructor injection. Object models can then be declaratively represented in XML. Here's a Setter injection based example using the `property` element:

    <bean name="shaker" class="net.bencode.model.Shaker">
      <property name="proteinPowder" ref="proteinPowder" />
    </bean>
    
    <bean name="proteinPowder" class="net.bencode.model.ProteinPowder">
      <property name="grams" ref="120" />
    </bean>

Or if XML isn't your thing, annotations are also an option, using a combination of `@Component` and `@Autowired`.

    @Component
    public class Shaker {
      @Autowired
      private ProteinPowder proteinPowder;
      ...
    }
    
    @Component
    public class ProteinPowder {
      private int grams;
      ...
    }


Constructor injection is similarly defined using the `constructor-arg` element. The following example works if the Shaker class has a constructor that takes in a ProteinPowder instance:

    <bean name="shaker" class="net.bencode.model.Shaker">
      <constructor-arg index="0" ref="proteinPowder" />
    </bean>
    
    <bean name="proteinPowder" class="net.bencode.model.ProteinPowder">
      <property name="grams" ref="120" />
    </bean>

