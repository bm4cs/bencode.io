---
layout: post
title: "Spring MVC"
date: "2015-05-31 21:16:05"
comments: false
categories:
- dev
tags:
- java
---

Some of my learning notes about using the excellent [Spring MVC](https://spring.io/guides/gs/serving-web-content/) framework to build a simple MVC based web application. Spring MVC is an action oriented framework. For a good overview on the differences between UI Component and Action oriented frameworks checkout this [link](http://www.oracle.com/technetwork/articles/java/mvc-2280472.html).

> In action oriented MVC land, the controller dispatches to a specific action, based on information in the request. Each action does a specific thing to transform the request and take action on it, possibly updating the model tier. This approach does not try to hide the request/response model of the underlying HTTP, and it also says absolutely nothing about the specifics of the HTML/CSS/JS comprising the UI.


## View Resolvers

Once Spring's DispatcherServlet servlet is registered, Spring provides the concept of resolvers, and more specifically view resolvers, which provide a view agnostic way of rendering object models (e.g. could be JSPs, Velocity or even XSLT). Here's a simple example. UrlViewResolver is a simple convention based resolver which works if URI path names match up with the actual view names.

    <bean id="viewResolver" class="org.springframework.web.servlet.view.UrlBasedViewResolver">
      <property name="prefix" value="/WEB-INF/jsp/"/>
      <property name="suffix" value=".jsp"/>
    </bean>

If I requested `http://tehhost/bar/resistor` and a controller action was wired up, a JSP called `resistor.jsp` within `/WEB-INF/jsp/` would be used.

Its interested to note that multiple view resolvers can be daisy chained together.


## Static Files

A common requirement is to serve up static web assets such as images, stylesheet and/or scripts. Spring makes this fairly straightforward:


*web.xml*

    <web-app version="2.5" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd">    
      <display-name>ohai spring mvc</display-name>
      <servlet>
        <servlet-name>helloServlet</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
          <param-name>contextConfigLocation</param-name>
          <param-value>/WEB-INF/config/servlet-config.xml</param-value>
        </init-param>
      </servlet>
      <servlet-mapping>
        <servlet-name>helloServlet</servlet-name>
        <url-pattern>/content/**</url-pattern>
      </servlet-mapping>
    </web-app>

*servlet-config.xml* define an mvc:resources servlet config element. Double asterisk (**) recurses within the location.

<beans
  xmlns="http://www.springframework.org/schema/beans"
  xmlns:p="http://www.springframework.org/schema/p"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:context="http://www.springframework.org/schema/context"
  xmlns:mvc="http://www.springframework.org/schema/mvc"
  xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-2.5.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-2.5.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-2.5.xsd http://www.springframework.org/schema/mvc http://www.springframework.org/schema/mvc/spring-mvc.xsd">

    <mvc:annotation-driven />
    <mvc:resources location="content" mapping="/content/**" />
    <context:component-scan base-package="net.bencode.controllers" />
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" p:prefix="/WEB-INF/jsp/" p:suffix=".jsp" />
</beans>





## Tags

### [spring.tld](http://static.springsource.org/spring/docs/current/spring-framework-reference/html/spring.tld.html)

When using JSPs as the chosen view technology, Spring provides tags for evaluating errors, setting themes and outputting internationalized messages.

`bind`
`escapeBody`
`hasBindErrors`
`htmlEscape`
`message`
`nestedPath`
`theme`
`transform`
`url`
`eval`

### [spring-form.tld](http://static.springsource.org/spring/docs/current/spring-framework-reference/html/spring-form.tld.html)


*servlet-config.xml*

    <bean id="messageSource" class="org.springframework.context.support.ResourceBundleMessageSource" p:basename="messages" />

*resources/messages.properties*

    goal.text=How many minutes did you pump your guns for today?

*hello.jsp*

    <ul>
      <li><spring:message code="goal.text" /><form:input path="minutes" /></li>
      <li><input type="submit" value="Enter Exercise" /></li>


## Session

Server side session can automagically maintained by specifying both the `@SessionAttributes` (to define what the session tracked variable is called) and `@ModelAttribute` (to define what the session varible is, that is its type, and where it is coming from, that is its source) annotations, for example:

    @Controller
    @SessionAttributes("proteinPowder")
    public class ProteinPowderController {
    
      @Autowired
      private ProteinPowderService proteinPowderService;
    
      @RequestMapping(value = "addPowder", method = RequestMethod.GET)
      public String addPowder(Model model, HttpSession session) {
        Goal goal = (Goal)session.getAttribute("proteinPowder");

        if (goal == null) {
          goal = new Goal();
          p.setName("Donkey Kong 5000");
          p.setGramsPer30g(26);
          p.setCostPerKilogram(34);
        }

        model.addAttribute("proteinPowder", p);
        return "addPowder";
      }
      
      @RequestMapping(value = "addPowder", method = RequestMethod.POST)
      public String updatePowder(@Valid @ModelAttribute("proteinPowder") Powder p, BindingResult result) {

        if(result.hasErrors()) {
          return "addPowder";
        }
        else {
            proteinPowderService.save(p);
        }
        
        return "redirect:index.jsp";
      }


## Interceptors

Registered in the request lifecycle. They provide pre and post processing hooks into the web request pipeline. A bit like HttpModules in ASP.NET. Callbacks are used to override or modify state.


    <mvc:interceptors>
      <bean class="org.springframework.web.servlet.i18n.LocaleChangeInterceptor" p:paramName="language" /> 
    </mvc:interceptors>


## REST

Requesting content in varying formats, for example, `application/pdf`, `text/xml` or even `text/json` requires content negotiation to be performed. This is where Spring's ContentNegotiationViewResolver comes in handy. It simply defines content rules (based on the resource extension or the `Accept` HTTP header), and based on the content type deemed suitable will delegate the rendering work to the most appropriate view resolver. In short, it routes view resolvers based on the desired content. Here's an example of how to configure it.

    <bean class="org.springframework.web.servlet.view.ContentNegotiatingViewResolver">
      <property name="mediaTypes">
        <map>
          <entry key="atom" value="application/atom+xml"/>
          <entry key="html" value="text/html"/>
          <entry key="json" value="application/json"/>
        </map>
      </property>
      <property name="viewResolvers">
        <list>
          <bean class="org.springframework.web.servlet.view.BeanNameViewResolver"/>
          <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
            <property name="prefix" value="/WEB-INF/jsp/"/>
            <property name="suffix" value=".jsp"/>
          </bean>
        </list>
      </property>
      <property name="defaultViews">
        <list>
          <bean class="org.springframework.web.servlet.view.json.MappingJackson2JsonView" />
        </list>
      </property>
    </bean>
    
    <bean id="content" class="com.springsource.samples.rest.SampleContentAtomView"/>

A nice little Spring tag to avoid hardcoding/managing REST endpoints in scripts, is the `url` tag. For example, consider this jQuery snippet:

    $.getJSON(
      '<spring:url value="powders.json" />', 
      { ajax: true }, 
      function(data) { }
    );
