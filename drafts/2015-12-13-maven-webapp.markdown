---
layout: post
title: "Java Web Application with Maven"
date: "2015-12-13 20:09:01"
comments: false
categories: "java"
---

Building Java web apps with Maven is really nice. These are my notes, doing so with IntelliJ IDEA 15.

Using IDEA create a new Maven module and use the vanilla `maven-archetype-webapp` which will scaffold out a directory structure. Doing this via IntelliJ will create the corresponding `.idea` project files, to provide nice IDE integration with the underlying Maven assets.

Alternatively stick to the command line:

    mvn archetype:generate -DgroupId=net.bencode -DartifactId=UsefulWebApp -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false

The result:

    .
    ├── pom.xml
    └── src
        ├── main
        │   ├── java
        │   │   └── net
        │   │       └── bencode
        │   │           └── app
        │   │               └── Application.java
        │   ├── resources
        │   └── webapp
        │       ├── css
        │       │   ├── app.css
        │       │   ├── foundation.css
        │       │   └── foundation.min.css
        │       ├── img
        │       ├── index.jsp
        │       ├── js
        │       │   ├── app.js
        │       │   ├── foundation.js
        │       │   ├── foundation.min.js
        │       │   └── vendor
        │       │       ├── jquery.min.js
        │       │       └── what-input.min.js
        │       └── WEB-INF
        │           └── web.xml
        └── test
            └── java
                └── net
                    └── bencode
                        └── app

Note, `Application.java` and the various static web assets in `/src/main/webapp` such as jQuery and the Foundation CSS framework were manually added by me.


We get the conventional Maven structure (i.e. `/src/main/java` and `/src/main/test`), the almighty [Project Object Model or `pom.xml`](https://maven.apache.org/guides/introduction/introduction-to-the-pom.html), and the web app specifics, such as `/src/main/webapp`, `WEB-INF/web.xml` and a sample JSP `index.jsp`.


Let's take a gander at the POM, i.e. Maven configuration.


{% highlight xml linenos %}
<project 
  xmlns="http://maven.apache.org/POM/4.0.0" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
  http://maven.apache.org/maven-v4_0_0.xsd">

  <modelVersion>4.0.0</modelVersion>
  <groupId>net.bencode</groupId>
  <artifactId>UsefulWebApp</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>UsefulWebApp</name>
  <url>http://www.bencode.net</url>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.8.2</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>joda-time</groupId>
      <artifactId>joda-time</artifactId>
      <version>2.9.1</version>
    </dependency>
    <dependency>
      <groupId>javax.servlet</groupId>
      <artifactId>javax.servlet-api</artifactId>
      <version>3.1.0</version>
      <scope>provided</scope>
    </dependency>
  </dependencies>

  <build>
    <finalName>UsefulWebApp</finalName>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.3</version>
        <configuration>
          <source>1.8</source>
          <target>1.8</target>
        </configuration>
      </plugin>

      <plugin>
        <groupId>org.apache.tomcat.maven</groupId>
        <artifactId>tomcat7-maven-plugin</artifactId>
        <version>2.2</version>
      </plugin>

      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <version>6.1.10</version>
        <configuration>
          <scanIntervalSeconds>10</scanIntervalSeconds>
          <connectors>
            <connector implementation="org.mortbay.jetty.nio.SelectChannelConnector">
              <port>8080</port>
              <maxIdleTime>60000</maxIdleTime>
            </connector>
          </connectors>
        </configuration>
      </plugin>
    </plugins>
  </build>

  <developers>
    <developer>
      <id>@vimjock</id>
      <name>Ben Simmonds</name>
      <email>ben@bencode.net</email>
      <url>http://www.bencode.net</url>
    </developer>
  </developers>
</project>
{% endhighlight %}


All pom's inherit from the super pom, so you can get away with a fairly minimal configuration (assuming you don't go against the grain and stick with Maven's convention). My needs for this simple web app:

- WAR packaging
- Embedded servlet container for quick testing
- Java 8
- Dependency management

Maven has an extensible plugin model, and a healthy ecosystem of [plugins](http://maven.apache.org/plugins/index.html), the bread and butter plugins being offically supported.

### WAR packaging

Line 10. Maven's [WAR plugin](http://maven.apache.org/plugins/maven-war-plugin/usage.html) takes care of packaging annoyance. It just works.

> The WAR Plugin is responsible for collecting all artifact dependencies, classes and resources of the web application and packaging them into a web application archive.

It can do other tricks like exploded format and manifest generation.

[Adding and filtering external web resources](http://maven.apache.org/plugins/maven-war-plugin/examples/adding-filtering-webresources.html)


### Rapid testing using the Jetty plugin

The [Maven Jetty plugin](https://maven.apache.org/plugins/maven-war-plugin/examples/rapid-testing-jetty6-plugin.html) automates the packaging (WAR) and container deployment steps, saving much repetitive time wasting.

    <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">

        <modelVersion>4.0.0</modelVersion>
        <groupId>net.bencode.maven</groupId>
        <artifactId>ben-on-mvn</artifactId>
        <packaging>war</packaging>
        <version>1.0-SNAPSHOT</version>
        <name>ben-on-mvn Maven Webapp</name>
        <url>http://maven.apache.org</url>

        <dependencies>
            <dependency>
                <groupId>junit</groupId>
                <artifactId>junit</artifactId>
                <version>4.8.2</version>
                <scope>test</scope>
            </dependency>
        </dependencies>

        <build>
            <finalName>ben-on-mvn</finalName>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>3.3</version>
                    <configuration>
                        <source>1.8</source>
                        <target>1.8</target>
                    </configuration>
                </plugin>

                <plugin>
                    <groupId>org.mortbay.jetty</groupId>
                    <artifactId>maven-jetty-plugin</artifactId>
                    <version>6.1.10</version>
                    <configuration>
                        <scanIntervalSeconds>10</scanIntervalSeconds>
                        <connectors>
                            <connector implementation="org.mortbay.jetty.nio.SelectChannelConnector">
                                <port>8080</port>
                                <maxIdleTime>60000</maxIdleTime>
                            </connector>
                        </connectors>
                    </configuration>
                </plugin>
            </plugins>
        </build>

        <developers>
            <developer>
                <id>@vimjock</id>
                <name>Ben Simmonds</name>
                <email>ben@bencode.net</email>
                <url>http://www.bencode.net</url>
            </developer>
        </developers>
    </project>

Run this to start the Jetty host. The plugin will scan your `target/classes` for any changes in your Java sources and `src/main/webapp` for changes to your web sources.

    mvn jetty:run

Very simple.

Useful resources and kudos

[Glen Mazza's Weblog](https://web-gmazza.rhcloud.com/blog/entry/web-service-tutorial)

