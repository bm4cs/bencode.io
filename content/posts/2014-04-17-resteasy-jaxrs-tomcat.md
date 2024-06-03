---
layout: post
title: "REST APIs with RESTEasy and Tomcat"
date: "2014-04-17 21:48:10"
comments: false
categories:
- dev
tags:
- java
---

Java EE application servers at times can feel big and heavy...as in behemoth. I'm "lucky" enough to work with an old version of WebSphere AS on a daily basis at the moment. To keep things fast, I've resorted to using lighter weight containers for the job at hand. [Tomcat](http://tomcat.apache.org/) is king when it comes to meeting the servlet specification, and no more.

Its hell fast. As a result is very lean on what it offers out of the box. I needed to whip up a quick and dirty REST API using Tomcat and ideally using something based on [JAX-RS](https://jax-rs-spec.java.net/). [RESTEasy](http://www.jboss.org/resteasy) is a JBoss project that provides and surfaces various frameworks (e.g. [Jackson](https://github.com/FasterXML/jackson) for JSON serialisation) for building RESTful services, and is a fully certifed and portable implementation of the JAX-RS specification. Perfect.

Step 1, create an empty web app. I use IDEA and used the simple "web app" maven archetype like so:

    mvn archetype:generate -DgroupId=org.bufferboy -DartifactId=TinyWebApi -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false

Regardless of the approach taken, you want to end up with an empty EE styled web app structure, something like:

    lib
    src
    web
      WEB-INF
        web.xml

Step 2, add the necessary dependencies. If your using maven, you get to leverage dependency resolution...good for you. Add `resteasy-jaxrs` to your `pom.xml` and your good to go. If no maven, [download](https://sourceforge.net/projects/resteasy/files/Resteasy%20JAX-RS/) the latest RESTEasy distibution. Unpack, and add the following `jar` dependencies into your projects classpath. Using IntelliJ pull up the *Project Structure* settings dialog, and hit the *Libraries* option. You'll need to add the following:

    /usr/local/apache-tomcat-7.0.52/lib/servlet-api.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jaxrs-api-3.0.7.Final.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-annotations-2.3.2.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-core-2.3.2.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-core-asl-1.9.12.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-databind-2.3.2.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-jaxrs-1.9.12.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-jaxrs-base-2.3.2.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-jaxrs-json-provider-2.3.2.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-mapper-asl-1.9.12.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-module-jaxb-annotations-2.3.2.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jackson-xc-1.9.12.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/javax.json-1.0.3.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/javax.json-api-1.0.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/jaxb-api-2.2.7.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/resteasy-cache-core-3.0.7.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/resteasy-jackson-provider-3.0.7.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/resteasy-jaxb-provider-3.0.7.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/resteasy-jaxrs-3.0.7.jar
    /usr/local/resteasy-jaxrs-3.0.7/lib/resteasy-jettison-provider-3.0.7.jar

Step 3, write some code.

### HelloServlet.java

A vanilla servlet for testing purposes, if RESTEasy doesnt work out first time.

    package org.bufferboy;
     
    import javax.servlet.ServletException;
    import javax.servlet.http.HttpServlet;
    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;
    import java.io.IOException;
    import java.io.PrintWriter;
     
    public class HelloServlet extends HttpServlet {
     
      public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        out.println("b3n was here 2014");
      }
    }


### Programmer.java

A model to bind the REST service to.

    package org.bufferboy;
     
    import javax.xml.bind.annotation.XmlElement;
    import javax.xml.bind.annotation.XmlRootElement;
     
    @XmlRootElement(name = "programmer")
    public class Programmer {
      private String id;
      private String name;
      private String[] languages;
     
      @XmlElement
      public String[] getLanguages() {
        return languages;
      }
     
      public void setLanguages(String[] languages) {
        this.languages = languages;
      }
     
      @XmlElement
      public String getName() {
        return name;
      }
     
      public void setName(String name) {
        this.name = name;
      }
     
      @XmlElement
      public String getId() {
        return id;
      }
     
      public void setId(String id) {
        this.id = id;
      }
     
      public static Programmer make(String id, String name, String[] languages) {
        Programmer programmer = new Programmer();
        programmer.setId(id);
        programmer.setName(name);
        programmer.setLanguages(languages);
        return programmer;
      }
    }


### FooApplication.java

A JAX-RS application, which publishes available REST services to the runtime.

    package org.bufferboy;
     
    import javax.ws.rs.core.Application;
    import java.util.HashSet;
    import java.util.Set;
     
    public class FooApplication extends Application {
      private Set<Object> singletons = new HashSet<Object>();
     
      public FooApplication() {
        singletons.add(new FooService());
      }
     
      @Override
      public Set<Object> getSingletons() {
        return singletons;
      }
    }


### FooService.java

An actual REST service. Notice the clean JAX-RS based namespace imports, making it straight forward to migrate to a full fledged EE Application Server if required.

    package org.bufferboy;
     
    import javax.ws.rs.GET;
    import javax.ws.rs.Path;
    import javax.ws.rs.PathParam;
    import javax.ws.rs.Produces;
    import java.util.ArrayList;
    import java.util.HashMap;
    import java.util.List;
    import java.util.Map;
     
    @Path("/foo")
    public class FooService {
     
      private static Map<String, Programmer> hackers = new HashMap<String, Programmer>();
     
      static {
        Programmer dennis = Programmer.make("1", "Dennis Richie", new String[] { "c", "assembler" });
        hackers.put(dennis.getId(), dennis);
     
        Programmer richard = Programmer.make("2", "Richard Stallman", new String[] { "c", "java", "ruby" });
        hackers.put(richard.getId(), richard);
      }
     
      @GET
      @Path("/hello")
      @Produces("text/plain")
      public String hello() {
        return "b3n was here 2014";
      }
     
      @GET
      @Path("/echo/{message}")
      @Produces("text/plain")
      public String echo(@PathParam("message")String message) {
        return message;
      }
     
      @GET
      @Path("/hackers")
      @Produces("text/xml")
      public List<Programmer> listHackers() {
        return new ArrayList<Programmer>(hackers.values());
      }
     
      @GET
      @Path("/hacker/{id}")
      @Produces("text/xml")
      public Programmer getHacker(@PathParam("id")String id) {
        return hackers.get(id);
      }
     
      @GET
      @Path("/json/hackers")
      @Produces("text/json")
      public List<Programmer> listHackersJson() {
        return new ArrayList<Programmer>(hackers.values());
      }
     
      @GET
      @Path("/json/hacker/{id}")
      @Produces("text/json")
      public Programmer getHackerJson(@PathParam("id")String id) {
        return hackers.get(id);
      }
    }


### web.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <web-app xmlns="http://java.sun.com/xml/ns/javaee"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
        http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
        version="2.5">
     
      <context-param>
        <param-name>resteasy.servlet.mapping.prefix</param-name>
        <param-value>/api</param-value>
      </context-param>
     
      <servlet>
        <servlet-name>HelloServlet</servlet-name>
        <servlet-class>org.bufferboy.HelloServlet</servlet-class>
      </servlet>
      <servlet>
        <servlet-name>Resteasy</servlet-name>
        <servlet-class>org.jboss.resteasy.plugins.server.servlet.HttpServletDispatcher</servlet-class>
        <init-param>
          <param-name>javax.ws.rs.Application</param-name>
          <param-value>org.bufferboy.FooApplication</param-value>
        </init-param>
      </servlet>
     
      <servlet-mapping>
        <servlet-name>HelloServlet</servlet-name>
        <url-pattern>/servlets/servlet/HelloServlet</url-pattern>
      </servlet-mapping>
      <servlet-mapping>
        <servlet-name>Resteasy</servlet-name>
        <url-pattern>/api/*</url-pattern>
      </servlet-mapping>
    </web-app>


### Demonstration

Given the above sample code, and the default Tomcat port binding of 8080, you should be able to pull back some sensible HTTP responses using your favourite test client. If you dont have one, get [Postman](http://www.getpostman.com/) immediately. Its the bomb. For troubleshooting purposes I've also included a vanilla servlet [`HelloServlet`](http://localhost:8080/servlets/servlet/HelloServlet).

`http://localhost:8080/api/foo/json/hackers`

![Postman showing JSON response](/images/pman01.png)


`http://localhost:8080/api/foo/hackers`

![Postman showing XML response](/images/pman02.png)
