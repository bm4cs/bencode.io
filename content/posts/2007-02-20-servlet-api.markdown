---
layout: post
title: "The Servlet API"
date: "2007-02-20 13:12:10"
comments: false
categories: "Java"
---

As you start out building Java web applications, you soon find that it sit upon several well designed building blocks. Once the penny drops, and an intuition about these building blocks is gained, creating web apps on Java becomes a delight.

Two key, top level concepts are the mighty *Servlet API* and *JavaServer Pages* (JSP). These are deployed to a Web container, also commonly referred to a Servlet (or Web) container.

The Servlet container, a vendor neutral bubble, provides several well defined subsystems and interfaces (knobs and dials) as defined by the Java specification. The container provides the underlying plumbing for services such as request dispatching, life cycle management, session management and security for example.



- [Layout](#Layout)
  - [Development Tree](#DevelopmentTree)
  - [Web Application Archive (WAR)](#WebApplicationArchive)
- [Configuration (web.xml)](#Configuration)
  - [Alias Paths](#AliasPaths)
  - [Context and initialisation parameters](#Contextandinitialisationparameters)
- [The Servlet API](#TheServletAPI)
  - [Parameters](#Parameters)
  - [Attributes](#Attributes)
  - [Includes](#Includes)
  - [Forwarding](#Forwarding)
    - [Dispatcher](#Dispatcher)
  - [Redirection](#Redirection)
  - [Lifecycle Event Listeners](#LifecycleEventListeners)
  - [Filters](#Filters)
  - [Localisation](#Localisation)
  - [Threading Model](#ThreadingModel)
    - [Synchronized block](#Synchronizedblock)
    - [Servlet Pooling](#ServletPooling)
  - [Session Tracking](#SessionTracking)





<a name="Layout" />

# Layout #


<a name="DevelopmentTree" />

## Development Tree ##

Here's a sample web application development structure made by Eclipse.

    .
    ├── src
    │   └── net
    │       └── bencode
    │           └── servlet
    │               └── PopServlet.java
    └── WebContent
        ├── css
        │   └── app.css
        ├── img
        │   └── hero.png
        ├── index.jsp
        ├── js
        │   ├── app.js
        │   └── jquery.min.js
        ├── META-INF
        │   └── MANIFEST.MF
        └── WEB-INF
            ├── lib
            └── web.xml



<a name="WebApplicationArchive" />

## Web Application Archive (WAR) ##

The `war` is the neatly packaged deployment bundle, ready to be slotted into a web container.

Web applications can be deployed either as an assembled `war` file, or as an unpacked (or exploded) directory tree following the same tree layout.

Given the above sample development tree, here's the corresponding WAR layout. Notice how bytecode (`class` files) and library dependencies (`jar` files) are neatly packaged under `WEB-INF\classes` and `WEB-INF\lib` respectively.

    .
    ├── css
    │   └── app.css
    ├── index.jsp
    ├── js
    │   ├── app.js
    │   └── jquery.min.js
    ├── META-INF
    │   └── MANIFEST.MF
    └── WEB-INF
        ├── classes
        │   └── net
        │       └── bencode
        │           └── servlet
        │               └── PopServlet.class
        ├── lib
        │   ├── joda-time-2.9.1.jar
        │   └── slf4j-api-1.7.12.jar
        └── web.xml


Also note how static web content (e.g. html, images, css, js) are simply placed into the root of the structure.

Assuming you have a tree layout that conforms, assembling a `war` is simple. In fact, as for a `jar`, its nothing more than a compressed archive. Therefore in the root directory of the web application, to assemble yourself a `war`, could run:

    jar cfv fun.war .




<a name="Configuration" />

# Configuration (web.xml) #

The `web.xml` is also commonly referred to as the *web application deployment descriptor*, and from a birds eye view looks like this:

- Alias Paths - the most important, defines addressing needs.
- Context and initialisation parameters
- Event listeners
- Filter mappings
- Error mappings
- Environment and Resource references

Beware `web.xml` is a little touchy. Not only is it case sensative, its elements are order sensative. Configuration element should appear in the following order:

1. icon
1. display-name
1. description
1. distributable
1. context-param
1. filter
1. filter-mapping
1. listener
1. servet
1. servlet-mapping
1. session-config
1. mime-mapping
1. welcome-file-list
1. error-page
1. taglib
1. resource-env-ref
1. resource-ref
1. security-constraint
1. login-config
1. security-role
1. env-entry
1. ejb-ref
1. ejb-local-ref



<a name="AliasPaths" />

### Alias Paths ###

Maps out what web components will serve what specific HTTP requests.

{% highlight xml %}
<servlet>
  <servlet-name>watermelon</servlet-name>
  <servlet-class>net.bencode.servlet.WatermelonServlet</servlet-class>
</servlet>
<servlet>
  <servlet-name>drpepper</servlet-name>
  <servlet-class>net.bencode.servlet.DrPepperServlet</servlet-class>
</servlet>
<servlet>
  <servlet-name>kernel</servlet-name>
  <jsp-file>/kernel.jsp</jsp-file>
</servlet>

<servlet-mapping>
  <servlet-name>watermelon</servlet-name>
  <url-pattern>/fruit/summer/*</url-pattern>
</servlet-mapping>
<servlet-mapping>
  <servlet-name>drpepper</servlet-name>
  <url-pattern>*.dr</url-pattern>
</servlet-mapping>
<servlet-mapping>
  <servlet-name>drpepper</servlet-name>
  <url-pattern>/yummy</url-pattern>
</servlet-mapping>
<servlet-mapping>
  <servlet-name>kernel</servlet-name>
  <url-pattern>*.kernel</url-pattern>
</servlet-mapping>
{% endhighlight %}




<a name="Contextandinitialisationparameters" />

### Context and initialisation parameters ###

Represents an application context for all web components, within the same `war` file.

{% highlight xml %}
<context-param>
  <param-name>foo</param-name>
  <param-value>12341234</param-value>
</context-param>
{% endhighlight %}

Using the context is simple:

{% highlight java %}
ServletContext context = request.getServletContext();
String magicValue = context.getInitParameter("foo");
{% endhighlight %}

In addition to global context level parameters, servlet scoped initialisation parameters defined in the deployment descriptor (`web.xml`) are accessable in the `init` method:

{% highlight xml %}
<servlet>
  <servlet-name>watermelon</servlet-name>
  <servlet-class>net.bencode.servlet.WatermelonServlet</servlet-class>
  <init-param>
    <param-name>driver</param-name>
    <param-value>org.postgresql.Driver</param-value>
  </init-param>
  <init-param>
    <param-name>url</param-name>
    <param-value>jdbc:postgresql://localhost/eden</param-value>
  </init-param>
</servlet>
{% endhighlight %}


{% highlight java %}
@Override
public void init(ServletConfig config) throws ServletException {
  super.init(config);

  String driver = getInitParameter("driver");
  String url = getInitParameter("url");
  ...
{% endhighlight %}






<a name="TheServletAPI" />

# The Servlet API #

> A servlet is a small Java program that runs within a Web server. Servlets receive and respond to requests from Web clients, usually across HTTP.

`GenericServlet` is the base class that all protocol specific implementation, such as `HttpServlet` inherit from. GenericServlet's `service` method is responsible for implementing protocol related plumbing, and dispatching to hooks such as `doGet` and `doPut` in the case of `HttpServlet`.

An example HTTP Servlet by extending `HttpServlet`:

{% highlight java %}
package net.bencode.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class WatermelonServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    response.setContentType("text/plain");
    PrintWriter out = response.getWriter();
    out.append("watermelon is yummy");
  }

  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    PrintWriter out = response.getWriter();

    if (request.getParameter("firstname") != null) {
      out.append(request.getParameter("firstname") + " ");
    }

    doGet(request, response);
  }
}
{% endhighlight %}



<a name="Parameters" />

## Parameters ##

HTTP parameters (from either an HTTP `GET` or `POST` event) are parsed and made conveniently available through `ServletRequest.getParameter("name")`.

{% highlight html %}
<form action="fruit/summer/watermelon" method="post">
  <input type="text" placeholder="First name" name="firstname">
  <input type="text" placeholder="Last name" name="lastname">
  <input type="number" value="100" name="puppies">
  <input type="submit" class="button" value="Submit">
</form>
{% endhighlight %}

{% highlight java %}
protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
  PrintWriter out = response.getWriter();

  if (request.getParameter("firstname") != null) {
    out.append(request.getParameter("firstname") + " ");
  }
{% endhighlight %}



<a name="Attributes" />

## Attributes ##

`HttpServletRequest` attributes provide a way for the Servlet container to make available additional information about a request. For example, the `javax.servlet.request.X509Certificate` attribute for HTTPS.

    request.getAttribute("foo");

Also a useful temporary place to stick state that will live for only the request/repsonse cycle, by calling `setAttribute`. For example, possibly useful for communicating between multiple Servlets.





<a name="Includes" />

## Includes ##

Syntax:

{% highlight java %}
RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/bison");
dispatcher.include(request, response);
{% endhighlight %}

Includes are useful for injecting the content generated by another Servlet/JSP. While includes can write to the response output stream, they are unable to modify other aspects of the response such as headers and cookies for example.


{% highlight java %}
@WebServlet("/logs")
public class LogServlet extends HttpServlet {

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    PrintWriter out = response.getWriter();
    out.println("<!DOCTYPE html><html><head><title>Log Servlet</title></head><body>");
    out.println("<h1>Log viewer Servlet</h1>");
    getServletContext().getRequestDispatcher("/bison").include(request, response);
    out.println("</body></html>");
  }
}
{% endhighlight %}




<a name="Forwarding" />

## Forwarding ##

Syntax:

{% highlight java %}
RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/bison");
dispatcher.forward(request, response);
{% endhighlight %}

Forwarding is a server side concept, where one Servlet completely delegates to another Servlet. From the clients point of view, the original resource they requested comes back as a result, and is none the wiser that a chain of server side forwards may have occured in order to accomplish the rendering.

Forwarding can be useful in pre-processing scenarios, i.e. where one Servlet might perform some function, and then hand over to another Servlet to take care of generating the response.



<a name="Dispatcher" />

### Dispatcher ###

A great example that server-side forwarding enables, is the *dispatcher* pattern, for applying a common set of pre-processing a request or response. In the below example, a master page (a common template to be applied to all responses) is implemented as a dispatcher.

First the Servlet:

**DispatcherServlet.java**:

{% highlight java %}
public class DispatcherServlet extends HttpServlet {
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String servletPath = request.getServletPath();
    String shortServletPath = servletPath.substring(0, servletPath.indexOf('.'));
    request.setAttribute("selectedScreen", shortServletPath);
    request.getRequestDispatcher("/template.jsp").forward(request, response);
  }
}
{% endhighlight %}

All requests are poored through `template.jsp`, which applies a common layout. In the deployment descriptor (`web.xml`), all requested with the `*.ben` suffix are configured to go through the dispatcher. The dispatcher then removes the `.ben` extension, and stores this in request scope, so later on `template.jsp` can do an include.


**template.jsp**:

{% highlight jsp %}
<%@ page errorPage="error.jsp" %>
<html>
<body>
<h1>Standard Template</h1>
<%
String selectedScreen = (String)request.getAttribute("selectedScreen");
%>
<jsp:include page="<%=selectedScreen %>"></jsp:include>
</body>
</html>
{% endhighlight %}


**web.xml**:

{% highlight xml %}
<web-app>
  <servlet>
    <servlet-name>dispatcher</servlet-name>
    <servlet-class>net.bencode.servlet.DispatcherServlet</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>dispatcher</servlet-name>
    <url-pattern>*.ben</url-pattern>
  </servlet-mapping>
</web-app>
{% endhighlight %}

An HTTP request such as `http://localhost:8080/app/logs.ben` will result in `template.jsp` being rendered, with an include to `/logs` (which may for example be a static resource, Servlet or JSP). Not too shabby.




<a name="Redirection" />

## Redirection ##

Syntax:

    response.setStatus(response.SC_MOVED_PERMANENTLY);
    response.setHeader("Location", "http://slashdot.org");

Or alternatively:

    response.sendRedirect("http://slashdot.org");




<a name="LifecycleEventListeners" />

## Lifecycle Event Listeners ##

Allows a Servlet to be notified of interesting events that occur within the container, such as `ServletContext` startup/shutdown and attribute changes, `HttpSession` creation and modifications.

Listener interfaces:

- `ServletContextListener`: hooks for `contextInitialized` and `contextDestroyed`.
- `ServletContextAttributeListener`: hooks for `attributeAdded`, `attributeRemoved`, and `attributeReplaced`.
- `HttpSessionListener`: hooks for `sessionCreated`, `sessionDestroyed`, `sessionHttpSessionEvent`.
- `HttpSessionBindingListener`: causes an object to be notified when it is bound to or unbound from a session, with `valueBound` and `valueUnbound`.
- `HttpSessionAttributeListener`: hooks for `attributeAdded`, `attributeRemoved` and `attributeReplaced`.
- `HttpSessionActivationListener`: hooks for `sessionWillPassivate` and `sessionDidActivate`. When the container either migrates a session between JVMs or persists sessions.

Here's the stub for a ServletContext Listener:

{% highlight java %}
public final class ContextListener
  implements ServletContextListener {

  @Override
  public void contextInitialized(ServletContextEvent event) {
    System.out.println("ServletContext has just been bootstrapped");
    event.getServletContext().setAttribute("coreDAO", ...);    
  }
  
  @Override
  public void contextDestroyed(ServletContextEvent event) {
    System.out.println("ServletContext is being destroyed");
  }
}
{% endhighlight %}

Then bind it in the deployment descriptor:

{% highlight xml %}
<web-app ...>
  <listener>
    <listener-class>net.bencode.listeners.ContextListener</listener-class>
  </listener>
</web-app>
{% endhighlight %}




<a name="Filters" />

## Filters ##

A servlet filter is a flow through component that allow some code to (transparently) execute within the servlet request/response pipeline. A logging filter, for example, might log the details of HTTP requests into a database. This section of the deployment descriptor, maps which filters are applied to requests, and in what sequence. This can also be achieved using the `@WebFilter` annotation.

{% highlight xml %}
<filter>
  <filter-name>PepperFilter</filter-name>
  <filter-class>net.bencode.filter.PepperFilter</filter-class>
</filter>
<filter-mapping>
  <filter-name>PepperFilter</filter-name>
  <url-pattern>*.dr</url-pattern>
</filter-mapping>
{% endhighlight %}


{% highlight java %}
package net.bencode.filter;

@WebFilter("*.dr")
public class PepperFilter implements Filter {
  public void init(FilterConfig fConfig) throws ServletException { }

  public void destroy() { }

  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
    System.out.println("its dr pepper time");
    chain.doFilter(request, response);
  }
}
{% endhighlight %}




<a name="Localisation" />

## Localisation ##

Browsers and devices can indicate a language preference to the server, as the `Accept-Language` header.

    POST /ben-on-mvn/fruit/summer/watermelon HTTP/1.1
    Host: localhost:8080
    Connection: keep-alive
    Content-Length: 41
    Cache-Control: max-age=0
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
    Origin: http://localhost:8080
    Upgrade-Insecure-Requests: 1
    User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64) AppleWebKit/537.36 (KHTML, like     Gecko) Chrome/49.0.2623.87 Safari/537.36
    Content-Type: application/x-www-form-urlencoded
    Referer: http://localhost:8080/ben-on-mvn/index.jsp
    Accept-Encoding: gzip, deflate
    Accept-Language: en-US,en;q=0.8
    Cookie: JSESSIONID=B775CE728B750AFC4EF89C4CCEC9C853


To see this in action, throw a couple of `properties` files into `src/main/resources`, so Maven will know to bundle them into the `war`.

*messages.properties*:

    greeting=g'day

*messages_en_US.properties*:

    greeting=greets

*messages_en_DE.properties*:

    greeting=guten tag


You'll see the Locale API plays nicely with Servlets:

{% highlight java %}
Locale locale = request.getLocale();
String greeting = ResourceBundle.getBundle("messages", locale).getString("greeting");
{% endhighlight %}


The WAR:

    ├── css
    │   ├── app.css
    │   ├── foundation.css
    │   └── foundation.min.css
    ├── index.jsp
    ├── js
    │   ├── app.js
    │   ├── foundation.js
    │   ├── foundation.min.js
    │   └── vendor
    │       ├── jquery.min.js
    │       └── what-input.min.js
    ├── META-INF
    │   └── MANIFEST.MF
    └── WEB-INF
        ├── classes
        │   ├── messages_en_US.properties
        │   ├── messages.properties
        │   └── net
        │       └── bencode
        │           ├── app
        │           │   └── Application.class
        │           ├── filter
        │           │   └── FunFilter.class
        │           └── servlet
        │               ├── DrPepperServlet.class
        │               ├── PopServlet.class
        │               └── WatermelonServlet.class
        ├── lib
        │   └── joda-time-2.9.1.jar
        └── web.xml




<a name="ThreadingModel" />

## Threading Model ##

By default, a single `Servlet` instance can be invoked by many request threads. Therefore it's important to protect the `_service()` method from the family of issues that can arise from multi-threading, such as race conditions, dead locks, and inconsistent state.

Common approaches to Servlet synchronisation:


<a name="Synchronizedblock" />

### Synchronized block ###

Guarantees only a single thread can access a section of code. 

{% highlight java %}
synchronized(this) {
  int number = counter;
  Thread.sleep(500);
  counter = number + 1;
}
{% endhighlight %}



<a name="ServletPooling" />

### Servlet Pooling ###

Servlets can also implement `javax.servlet.SingleThreadModel`. This will instruct the servlet container to allocate a pool of instances of the servlet, assigning a dedicated instance to each request thread.

**Warning**: Due to poor design, this interface has been deprecated, and should no longer be used. I'm listing it here, because I still come across them in the wild.

> SingleThreadModel does not solve all thread safety issues. For example, session attributes and static variables can still be accessed by multiple requests on multiple threads at the same time, even when SingleThreadModel servlets are used.

Instead remove state, so that the same servlet can be used by multiple threads concurrently.

{% highlight java %}
@WebServlet("/bison")
public class BisonServlet extends HttpServlet implements SingleThreadModel {

  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
  }

  //...
}
{% endhighlight %}





<a name="SessionTracking" />

## Session Tracking ##

Three methods of tracking a session identifier to a stateless HTTP client; cookies, URL rewriting and/or hidden form fields.

- *Cookies*: persistent across browser shutdowns, might not be available.
- *URL Rewriting*: involves recrafting the URL (with `encodeURL`) specific to each consumer like this `http://foo.com/servlet?session=1337`. Ubiquitous, only works for dynamic pages.
- *Hidden form fields*: `<input type="hidden" name="session" value="1337" />`. Same benefits and shortfalls as URL rewriting.

The servlet API provides a session abstraction called `HttpSession`. The API will attempt to make use of cookies, falling back to URL rewriting if required. You can use `HttpSession` to manipulate the session identifer, creation time, last accessed time, and store objects.

{% highlight java %}
HttpSession session = request.getSession(true);
log.info(session.getId()); //537A9BE6AF82024F30AAC012E27DD1C8
log.info(session.getMaxInactiveInterval()); //1800
Programmer user = (Programmer) session.getAttribute("user");

if (user != null) {
  response.getWriter().append("<p>" + user.greeting() + "</p>");
}
else {
  session.setAttribute("user", new Programmer("Linus Torvalds", "C"));
}
{% endhighlight %}


![JSESSIONID in Chrome DevTools](/images/jsessionid_devtools.png)

Sessions can be explicitly cleaned up (i.e. not by waiting for a timeout) by calling `session.invalidate()`.



