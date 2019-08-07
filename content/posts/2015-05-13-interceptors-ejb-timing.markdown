---
layout: post
title: "EJB Timing with Interceptors"
date: "2015-05-13 15:36:19"
comments: false
categories: "Java"
---

Java EE is packed tight with useful functionality. The humble `Interceptor` provides cross cutting functionality external to the targetted code, without modifying the code itself. In other words [AOP](http://en.wikipedia.org/wiki/Aspect-oriented_programming). The API is rather simple an involves using `@AroundInvoke`.

The following highlights just how simple it is to log all EJB service call execution times, without the need to modify a single bean.


**META-INF/ejb-jar.xml**

    <?xml version="1.0" encoding="UTF-8"?>
    <ejb-jar xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/ejb-jar_3_1.xsd" version="3.1">
      <display-name>SerivceModuleEJB</display-name>
      <assembly-descriptor>
        <interceptor-binding>
          <ejb-name>*</ejb-name>
          <interceptor-class>
            net.bencode.common.ServicePerformanceInterceptor
          </interceptor-class>
        </interceptor-binding>
      </assembly-descriptor>
    </ejb-jar>


**ServicePerformanceInterceptor.java**

    package net.bencode.common;
    
    import javax.interceptor.AroundInvoke;
    import javax.interceptor.InvocationContext;
    import org.slf4j.Logger;
    import org.slf4j.LoggerFactory;
    
    public class ServicePerformanceInterceptor
    {
      private static Logger logger = LoggerFactory.getLogger("timings");
     
      @AroundInvoke 
      public Object callLog(InvocationContext ctx) throws Exception {
        String methodName = ctx.getMethod().getName();
        String className = ctx.getTarget().getClass().getName();
        long startTime = System.currentTimeMillis();
        Object result = null;
    
        try {
          result = ctx.proceed();
        }
        finally {
          logger.debug("##### Total Execution Time Of " + methodName  
                    + " Is " + (System.currentTimeMillis() - startTime) + "MS"
                    + " within " + className);
        }
        return result;
      }  
    }
