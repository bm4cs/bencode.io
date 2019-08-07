---
layout: post
title: "Container Context roots"
date: "2015-05-23 16:18:19"
comments: false
categories: "Java"
---

Occassionally the need to do multiple side-by-side deployments of the same packaged application can arise. In a scenario recently faced, it was useful to have multiple versions of our packaged EAR deployed and configured slightly differently (for example: with and without security in QA environments). As the application is expected to run hot 24/7, the need for a simple side-by-side versioning (e.g. v1, v2) scheme was also important. Allowing us to deploy `v1`, and later breaking (incompatible) versions `v2`, `v3`, given our service consumers the freedom to upgrade when convenient.

The simple and elegant solution of **context roots** came to the rescue.

In the case of WebSphere:

> The context root is combined with the defined servlet mapping (from the WAR file) to compose the full URL that users type to access the servlet. For example, if the context root is `/gettingstarted/1.0` and the servlet mapping is `MySession`, then the URL is `http://host:port/gettingstarted/1.0/MySession`

To ensure the packaged application explicitly defines a root, the application deployment descriptor (see below) should define a `context-root`.


**WEB-INF/ibm-web-ext.xml**

    <?xml version="1.0" encoding="UTF-8"?>
    <web-ext
      xmlns="http://websphere.ibm.com/xml/ns/javaee"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://websphere.ibm.com/xml/ns/javaee http://websphere.ibm.com/xml/ns/javaee/ibm-web-ext_1_1.xsd"
      version="1.1">
    
      <context-root uri="FooService/1.0" />
      <reload-interval value="3" />
      <enable-directory-browsing value="false" />
      <enable-file-serving value="true" />
      <enable-reloading value="true" />
      <enable-serving-servlets-by-class-name value="false" />
    </web-ext>



If desirable of course, can be tied into your build process. Ant for example:

**build.xml**

    wsdl.version=1.0

    <replace file="${web.info.dir}/ibm-web-ext.xml" token="FooService" value="FooService/${wsdl.version}" />



