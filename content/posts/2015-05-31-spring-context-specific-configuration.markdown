---
layout: post
title: "Spring Context Specific Configuration Files"
date: "2015-05-31 21:22:05"
comments: false
categories:
- dev
tags:
- java
---

Spring can be configured in lots of different ways and using context specific XML configuration is one of the preferred approaches. Context specific configuration in other words is simply a chunk of XML specific to a single concern (e.g. servlet config, jpa config, and whatever else you need). A classic example of this is the `servlet-config.xml` that the Dispatcher Servlet binds against:

{% highlight xml %}
<servlet>
  <servlet-name>fitTrackerServlet</servlet-name>
  <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
  <init-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>/WEB-INF/config/servlet-config.xml</param-value>
  </init-param>
</servlet>
{% endhighlight %}
Other Context specific configuration files can be registered by hacking your `web.xml`. Here's an example for defining a place to stick JPA related cruft:

{% highlight xml %}
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath:/jpaContext.xml</param-value>
</context-param>

<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
{% endhighlight %}
