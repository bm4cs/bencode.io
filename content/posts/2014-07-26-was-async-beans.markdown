---
layout: post
title: "Asynchronous Workloads with WebSphere Application Server"
date: "2014-07-26 20:16:10"
comments: false
categories: [Java]
---

So I've been using WebSphere for a while now, and continue to discover new functionality in this powerhouse of an application server. This post focuses on performing background work in WebSphere Application Server (WAS) 7.0, which is an EE 5 compliant container.

Firstly a quick outline of the problem. Across a series of web service calls, there exist a number of intensive processes that need to take place. I wanted a way to perform work this asynchronously somewhere else within the application server, without being bound to the request/response cycle that HTTP web services impose...in essence making the actual service calls appear super snappy. 

My initial instinct was to look at leveraging JMS (messaging) and a stateless EJB (business component). But this seemed to involve way too much manual plumbing. The EJB 3.1 spec eliminated most of this boilerplate plumbing with the introduction of the [`@Asynchronous`](http://docs.oracle.com/javaee/6/tutorial/doc/gkkqg.html) annotation. Sadly wasn't an option for me here with WebSphere 7.0, which only supports EJB 3.0.

Digging into the [WebSphere 7.0 Knowledge Center](http://www-01.ibm.com/support/knowledgecenter/?lang=en#!/SSAW57_7.0.0/as_ditamaps/welcome_nd.html) a little deeper, I stumbled onto [Asynchronous Beans](http://www-01.ibm.com/support/knowledgecenter/?lang=en#!/SSAW57_7.0.0/com.ibm.websphere.soafep.multiplatform.doc/info/ae/asyncbns/concepts/casb_asbover.html?cp=SSAW57_7.0.0%2F8-1-3-2) and its underlying [Work Manager API](http://www-01.ibm.com/support/knowledgecenter/?lang=en#!/SSAW57_7.0.0/com.ibm.websphere.soafep.multiplatform.doc/info/ae/asyncbns/concepts/casb_workmgr.html?cp=SSAW57_7.0.0%2F8-1-3-2-0).





> A work manager is a thread pool created for Java Platform, Enterprise Edition (Java EE) applications that use asynchronous beans. Using the administrative console, an administrator can configure any number of work managers. The properties of the work manager are defined, including the Java EE context inheritance policy for any asynchronous beans that use the work manager, and the binding of each work manager to a unique place in Java Naming and Directory Interface (JNDI).


Work managers can be found in the WAS adminstration console tucked away under the Resources > Asynchronous beans > Work manager left navigation menu. 

![Work Managers via the administration console](/images/was_abean1.jpg)

Behaviours of the work manager can be tweaked through the WAS admin console (or programmatically via the management API), and includes options such as the work timeout, the request pipeline size, thread pool sizing, and more:


![Available Work Manager configuration options](/images/was_abean3.jpg)



The Work Manager API has been around for yonks, and provides really powerful out of the box functionality:

- A managed pool of processes, ready to do your heavy lifting, configurable through the WebSphere management interface.
- Intelligent context propagation. The process you are allocated is passed the relevant classpath information, transactional state, security context, and so on. In essence, you can assume the container will perform the work as if the work manager is running within your current Web context. But the magic is, its truly a independent process of it own.

![Work Managers context switching overview](/images/was_abean2.gif)

Source: [IBM WebSphere Developer Technical Journal](http://www.ibm.com/developerworks/websphere/techjournal/0606_johnson/0606_johnson.html#download)


While the underlying mechanics are complex, actually using this API is rather simple. When you want your Web module to perform an action, you create an implementation of the `Work` interface and submit that instance to the work manager. The work manager daemon creates another thread, which invokes the run method of your `Work` implementation. Hence, using a thread pool the work manager can create threads for as many `Work` implementations submitted to it. Not only that, the work manager takes a snapshot of the current Java EE context on the thread when the work is submitted.

To demonstrate, the following three classes from `com.ibm.ws.runtime.jar` (`lib` directory of your WebSphere installation, e.g. C:\IBM\SDP\runtimes\base_v7\plugins\com.ibm.ws.runtime.jar) `Work`, `WorkManager`, and `WorkItem` are required.

OK, so to kick things of a simple SOAP web service, with operation `sayHello`.

    package net.bencode.fooservice;
    
    import java.util.ArrayList;
    import java.util.Arrays;
    import java.util.Collections;
    import java.util.List;
    import java.util.Random;
    
    import javax.naming.InitialContext;
    import javax.naming.NamingException;
    
    import net.bencode.work.SampleWork;
    
    import com.ibm.websphere.asynchbeans.WorkException;
    import com.ibm.websphere.asynchbeans.WorkItem;
    import com.ibm.websphere.asynchbeans.WorkManager;
    
    @javax.jws.WebService (endpointInterface="net.bencode.fooservice.FooService", targetNamespace="http://www.bencode.    net/FooService/", serviceName="FooService", portName="FooServiceSOAP")
    public class FooServiceSOAPImpl{
    
        public String sayHello(String name) {
          String message = String.format("hello %s", name);
          this.scheduleWork(); // long running async task
          return message;
        }
    
        private void scheduleWork() {
          try {
            WorkManager workManager = getWorkManager();
            SampleWork sampleWork = new SampleWork();
            workManager.startWork(sampleWork);
            
            // optional: block 1 second for work completion
            // WorkItem workItem = workManager.startWork(sampleWork);
            // ArrayList workList = new ArrayList();
            // workList.add(workItem);
            // workManager.join(workList, WorkManager.JOIN_AND, 1000);
            
          } catch (WorkException e) {
            e.printStackTrace();
          } catch (IllegalArgumentException e) {
            e.printStackTrace();
          }
        }
        
        public WorkManager getWorkManager() {
          WorkManager workManager = null;
          
          try {
            InitialContext ctx = new InitialContext();
            String jndiName = "java:comp/env/wm/default";
            workManager = (WorkManager)ctx.lookup(jndiName);
            System.out.println("WorkManager obtained");
          } catch(Exception ex) {
            System.out.println("Unable to lookup workmanager: " + ex.getMessage());
          }
          
          return workManager;
        }
    }


And here's `SampleWork.java`, a simple `Work` implementation. It will loop four times, sleeping the thread for five seconds each time.

    package net.bencode.work;
    
    import com.ibm.websphere.asynchbeans.Work;
    
    public class SampleWork implements Work {
    
      private boolean released = false;
      
      @Override
      public void run() {
        System.out.println("Starting SampleWork");
        
        try {
          for (int i = 0; i < 4; i++) {
            if (released) {
              System.out.println("SampleWork has been released");
              return;
            }
            Thread.sleep(5000);
            System.out.println("work work...");
          }
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
        
        System.out.println("Completed SampleWork");
      }
    
      @Override
      public void release() {
        System.out.println("Releasing SampleWork");
        released = true;
      }
    }




Since we want to exercise the Work Manager from a Web Module, it is treated as any other container provided resource (e.g. a JDBC Data Source) and a resource binding must be registered in your `web.xml` and `ibm-web-bnd.xml` configurations:

**web.xml**

    <web-app id="WebApp_ID" version="2.5" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd">
      <display-name>WasZenWeb</display-name>
      <welcome-file-list>
        <welcome-file>b.jsp</welcome-file>
      </welcome-file-list>
      <resource-ref>
        <description>WorkManager</description>
        <res-ref-name>wm/default</res-ref-name>
        <res-type>com.ibm.websphere.asynchbeans.WorkManager</res-type>
        <res-auth>Container</res-auth>
        <res-sharing-scope>Shareable</res-sharing-scope>
      </resource-ref>
    </web-app>

**ibm-web-bnd.xml**

    <web-bnd xmlns="http://websphere.ibm.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://websphere.ibm.com/xml/ns/javaee http://websphere.ibm.com/xml/ns/javaee/ibm-web-bnd_1_0.xsd" version="1.0">
      <virtual-host name="default_host" />
      <resource-ref name="wm/default" binding-name="wm/default" />
    </web-bnd>


If you don't register the JNDI lookup will explode, example:

    javax.naming.NameNotFoundException: Name comp/env/wm not found in context "java:".
      at com.ibm.ws.naming.ipbase.NameSpace.getParentCtxInternal(NameSpace.java:1837)
      at com.ibm.ws.naming.ipbase.NameSpace.lookupInternal(NameSpace.java:1166)
      at com.ibm.ws.naming.ipbase.NameSpace.lookup(NameSpace.java:1095)
      at com.ibm.ws.naming.urlbase.UrlContextImpl.lookup(UrlContextImpl.java:1233)
      at com.ibm.ws.naming.java.javaURLContextImpl.lookup(javaURLContextImpl.java:395)
      at com.ibm.ws.naming.java.javaURLContextRoot.lookup(javaURLContextRoot.java:220)
      at com.ibm.ws.naming.java.javaURLContextRoot.lookup(javaURLContextRoot.java:160)
      at javax.naming.InitialContext.lookup(InitialContext.java:436)
      at net.bencode.fooservice.FooServiceSOAPImpl.scheduleWork(FooServiceSOAPImpl.java:45)
      at net.bencode.fooservice.FooServiceSOAPImpl.sayHello(FooServiceSOAPImpl.java:24)


Using an HTTP test client, such as soapUI, can see the WAS server returns the response very quickly (e.g. 19ms in this instance):

![Consuming the demo service with soapUI](/images/was_abean_soapui.jpg)

Meanwhile, I can see the WAS application server happily carrying on with processing in the background.

    [26/07/14 20:55:55:425 EST] 000000a7 SystemOut     O work work...
    [26/07/14 20:55:59:144 EST] 000000a6 SystemOut     O work work...
    [26/07/14 20:56:00:425 EST] 000000a7 SystemOut     O work work...
    [26/07/14 20:56:04:144 EST] 000000a6 SystemOut     O work work...
    [26/07/14 20:56:04:144 EST] 000000a6 SystemOut     O Completed SampleWork

