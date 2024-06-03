---
layout: post
title: "Classloaders"
date: "2016-04-20 20:33:10"
comments: false
categories:
- dev
tags:
- java
---


First some kudos and credits to the below. None of the material in this post is original, and I have documented it for my personal learning. Please refer to the below original (and superior) articles.


- ZeroTurnaround's Jevgeni Kabanov awesome and most practical [Do You Really Get Classloaders?](http://zeroturnaround.com/rebellabs/rebel-labs-tutorial-do-you-really-get-classloaders)
- Oracle's A Sundararajan [Understanding Java class loading](https://blogs.oracle.com/sundararajan/entry/understanding_java_class_loading)
- All the way from 1996 by Chuck Mcmanis [The basics of Java classloaders](http://www.javaworld.com/article/2077260/learn-java/learn-java-the-basics-of-java-class-loaders.html)


# Hello java.lang.ClassLoader #

A Java class is loaded (i.e. born into the JVM) by a concrete implementation of `java.lang.ClassLoader`. If a class must be class loaded, what loads the `java.lang.ClassLoader` class itself (i.e. who loads the loader)? It turns out that there is a bootstrap classloader wired into the JVM. The bootstrap loader loads `java.lang.ClassLoader` in additional to many other Java platform classes (e.g. `java.lang.*`) into memory. The essential API:

{% highlight java %}
package java.lang;

public abstract class ClassLoader {

  public Class loadClass(String name);
  protected Class defineClass(byte[] b);

  public URL getResource(String name);
  public Enumeration getResources(String name);
  
  public ClassLoader getParent();
}
{% endhighlight %}


To load a specific Java class, say `net.bencode.Foo`, the JVM invokes `loadClass()` of a chosen `java.lang.ClassLoader`. `loadClass()` receives name of the class to load and returns a freshly baked `java.lang.Class` instance. `loadClass()` first figures out where the physical bytes of the `.class` file are (e.g. a local file system), and then if successful invokes `defineClass()` to assemble a `java.lang.Class` from the bytes.

The classloader for which `loadClass()` is called is referred as *initiating loader*. The *initiating loader* may not do the heavy lifting of resolving the bytecode for a given class itself, but has the option of delegating to another classloader, which in turn may delegate to another classloader and so on.

Eventually a classloader instance in the [chain](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern) is elected, and will fire it's `defineClass` method to load the class definition for `net.bencode.Foo`. The classloader that is eventually elected, is referred to as the *defining loader* of `net.bencode.Foo`.

At runtime, a Java class is uniquely identified using this pair:

- the fully qualified name of the class
- its defining loader



# Delegation Hierarchy #

Even in the most simple of Java programs, there will be a minimum three classloaders involved.

### Bootstrap Class Loader ###

- Loads platform classes (e.g. `java.lang.Object`, `java.lang.Thread`) from `rt.jar`
- `-Xbootclasspath` may be used to alter the boot class path `-Xbootclasspath/p:` (to prepend) and `-Xbootclasspath/a:` (to append).
- In the Oracle implementation, the system property `sun.boot.class.path` can be used to determine the boot class path.
- This bootstrap loader is represented by `null`. For example, `java.lang.Object.class.getClassLoader()` would return `null`.

### Extension Class Loader ###

- As part of the Java [extension mechanism](http://docs.oracle.com/javase/tutorial/ext/index.html), loads classes from optional `jars` in `$JRE_HOME/lib/ext`.
- `-Djava.ext.dirs` can be used to change the extension directories.
- In the Oracle implementation, this is an instance of `sun.misc.Launcher$ExtClassLoader`.
- System property `java.ext.dirs` can be used to determine which directories are used as extension directories.

### Application Class Loader ###

- Loads classes from application classpath, set using environment variable `CLASSPATH`, or, `-cp` or `-classpath` option with the Java launcher. If both of these are missing, `.`, the current directory is used.
- System property `java.class.path` can be used to determine the application class path.
- `java.lang.ClassLoader.getSystemClassLoader()` returns this loader.
- This loader is also (confusingly) known as the *system classloader* or the *system classpath classloader*, not to be confused with the *bootstrap classloader*.
- In the Oracle implementation, is an instance of `sun.misc.Launcher$AppClassLoader`.
- The default application loader uses the *extension loader* as it's parent loader.
- Command line switch `-Djava.system.class.loader` can be used change the application classloader. This value specifies name of a subclass of `java.lang.ClassLoader` class. First the default *application loader* loads the named class (hence this loader class must exist in `CLASSPATH` or `-cp`) and makes an instance of it. The newly created loader is then used to load application main class.


{% highlight java %}
public class Foo {
  public static void main(String[] args) {
    System.out.println(Foo.class.getClassLoader());
    java.sql.Connection connection = java.sql.DriverManager.getConnection("");
  }
}
{% endhighlight %}

Running this:

    $ java -cp loaderfun.jar net.bencode.Foo
    sun.misc.Launcher$AppClassLoader@4283874e


### The Hierarchy In Action ###

{% highlight java %}
public class Programmer {
  public void createCode() {
    Keyboard kb = new Keyboard(Switch.CherryBlue);
    kb.type();
  }
}
{% endhighlight %}

`Keyboard kb = new Keyboard(Switch.CherryBlue)` is semantically the same as `Keyboard kb = Programmer.class. getClassLoader().loadClass("KeyBoard").newInstance(Switch.CherryBlue)`. In Java every object is associated with its class (`Programmer.class`), and every class is associated with its classloader (`Programmer.class.getClassLoader()`).

Whenever a reference to another class is made (`Keyboard kb = new Keyboard(Switch.CherryBlue)`), the JVM will use the *defining classloader* of the housing class (`Programmer.class.getClassLoader()`), the *system classpath classloader*, as *initiating classloader*. To load the class `java.sql.DriverManager` for example, the JVM will use the *system classpath classloader* as initiating loader. The *system classpath classloader* delegates to the *extension classloader*, which in turn checks whether it is a bootstrap class (using private method `ClassLoader.findBootstrapClass`), and if so, delegates to the *bootstrap classloader*, which defines the class by loading it from `rt.jar`.

When reference to `SomeOtherClass` is stumbled upon, the JVM rince and repeats:

1. It assigns *system classloader* as the *initiating classloader*.
2. The *system classloader* delegates to *extension classloader*.
3. The *extension classloader* delegates to *bootstrap classloader*.
4. The *bootstrap classloader* scans `rt.jar` and fails to find `SomeOtherClass`.
5. The *extension classloader* scans all extension jars and fails to find `SomeOtherClass`.
6. The *system classloader* will then scan all `.class` bytes on the applications classpath, and if successful defines the class, and if unsuccessful, will throw a `NoClassDefFoundError`.





# Parent First vs Child First #

Thanks to the delegation hierarchy, classloaders typically delegate finding classes and resources to their parent before searching their own classpath. If the parent classloader cannot find a class or resource, only then does the classloader attempt to find them locally. In effect, a classloader is responsible for loading only the classes not available to the parent. Classes loaded by a classloader higher in the hierarchy cannot refer to classes available lower in the hierarchy.

In Java server side arrangments (e.g. Java EE) however, the order of the lookups is often reversed. A classloader may try to find classes locally before going to the parent.


### Java EE Delegation Model ###

The Java Servlet specification recommends that a web modules` classloader look to the local classloader before delegating to its parent. The parent classloader is only used as a last resort, for classes unable to be located within the module.

One reason for reversing the ordering between child and parent lookups, is that application containers often ship with many libraries (e.g. log4j) in their own release cycles, that may conflict with those consumed by applications.






# Troubleshooting Toolkit #

### URLClassLoader ###

A `NoClassDefFoundError` is thrown if the JVM or a given classLoader instance fails to load in the definition of a class. To be clear, this is a runtime problem, not a compile time one. To dump the locations that the classloader is reading from, you can cast it to a `URLClassLoader`, and ask for all its paths.

{% highlight java %}
public class Programmer {
  public static void main(String[] args) {
    Programmer linus = new Programmer();
    linus.hack();
  }
  
  public void hack() {
    System.out.println(
      Arrays.toString(
        ((URLClassLoader)this.getClass().getClassLoader()).getURLs()
      )
    );
  }
}
{% endhighlight %}

    $ java -cp long-black.jar:/home/ben/java/lib/auto-value-1.2.jar:/foo/bar net.bencode.Programmer
    [file:/home/ben/java/long-black.jar, file:/home/ben/java/lib/auto-value-1.2.jar, file:/foo/bar]



### jconsole ###

Depending on your application container, the `URLClassLoader` option may not be possible, or feasible. An alternative approach is to query management beans (mbean) exposed by the JVM instrumentation.

On the Oracle JVM, expand:

- java.lang > Classloading: for statistics on loads and unloads.
- java.lang > Runtime > Attributes > ClassPath: the colon delimitered list of paths attempting to load resources from.

![jconsole](/images/classloader_jconsole.png)



### grep ###

This cheeky one liner (credit to the ZeroTurnaround [post](http://zeroturnaround.com/rebellabs/rebel-labs-tutorial-do-you-really-get-classloaders/4/)), will open up all jars, list out all their class files, and pattern match them against a name.

    $ find . -name *.jar -exec jar -tf '{}' \; | grep 'ParseRequest'
    autovalue/shaded/com/google$/common/primitives/$ParseRequest.class


### Tracing with -verbose:class ###

JVM's often support various tracing flags (such as `-verbose:class`, or `-XX:+TraceClassLoading` and `-XX:+TraceClassUnloading`) to gain insights into how your classloaders are really behaving. Obviously this is not so helpful for the likes of solving `NoClassDefFoundError`, but incredibly useful for the likes of `NoSuchMethodError`, which occurs when a classloader selects a differing and incompatible definition for a given class.

Here's the classloader activity that takes occurs:

    $ java -verbose:class -cp long-black.jar:/home/ben/Downloads/auto-value-1.2.jar:/foo/bar net.bencode.Programmer
    [Opened /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.Object from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.io.Serializable from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.Comparable from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.CharSequence from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.String from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.reflect.AnnotatedElement from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.reflect.GenericDeclaration from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.reflect.Type from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.Class from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.Cloneable from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.ClassLoader from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.System from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.Throwable from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.Error from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.ThreadDeath from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    ...
    ... many, many ommitted for clarity
    ...
    [Loaded java.lang.Shutdown from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]
    [Loaded java.lang.Shutdown$Lock from /usr/java/jdk1.8.0_40/jre/lib/rt.jar]


### Tracing with getResource ###

Another clever option highlighted by the ZeroTurnaround [post](http://zeroturnaround.com/rebellabs/rebel-labs-tutorial-do-you-really-get-classloaders/4/), if you are able to make a code change, is that `getResource` searches the same classpath as `loadClass`. So you can sniff out exactly where a class definition is found.

{% highlight java %}
System.out.println(Main.class.getClassLoader().getResource(
  Programmer.class.getName().replace('.', '/') + ".class"));
{% endhighlight %}

Results in:

    file:/home/ben/java/long-black/bin/net/bencode/Programmer.class

Decompile the class bytecode, and examine it's API for the incompatibility:

    $ cd /home/ben/java/long-black/bin/net/bencode
    $ javap -private Programmer
    Warning: Binary file Programmer contains net.bencode.Programmer
    Compiled from "Programmer.java"
    public class net.bencode.Programmer {
      public net.bencode.Programmer();
      public void hack();
    }

In a similar vein, the `ClassCastException` is caused by two (often identical) variations of a class definition, loaded by multiple classloaders. This situation is possible through the reversed (child first) classloaders employed by some web and application classloaders. The key thing to remember, is that a class is uniquely identified by the JVM as (1) its fully qualified name, and (2) the classloader responsible for loading it. If the same class (e.g. `java.lang.String`) is loaded by multiple classloaders, they are considered completely different classes.

`ClassCastException`, `LinkageError` and `IllegalAccessError` are all symptoms of the same problem; classes being loaded by different classloaders.


### Tracing with Enterprise Containers ###

EE containers generally provide a way to monitor classloader activity. WebSphere for example, under Troubleshooting > Class loader viewer, provides a neat report of classloader activity:


    JDK Extension: sun.misc.Launcher$ExtClassLoader
    Delegation: true 
    Classpath:
    file:/C:/IBM/8_5/AppServer/tivoli/tam/PD.jar 
    file:/C:/IBM/8_5/AppServer/tivoli/tam/PolicyDirector/ 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/access-bridge-64.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/CmpCrmf.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/dnsns.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/dtfj-interface.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/dtfj.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/dtfjview.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/gskikm.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/healthcenter.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmcac.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmcmsprovider.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmjcefips.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmjceprovider.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmkeycert.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmpkcs11impl.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmsaslprovider.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/IBMSecureRandom.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmspnego.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmxmlcrypto.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/ibmxmlencprovider.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/iwsorbutil.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/jaccess.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/JavaDiagnosticsCollector.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/javascript.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/JawBridge.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/jdmpview.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/localedata.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/traceformat.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/xmlencfw.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/jre/lib/ext/zipfs.jar 
    
    JDK Application: sun.misc.Launcher$AppClassLoader
    Delegation: true 
    Classpath:
    file:/C:/IBM/8_5/AppServer/profiles/AppSrv01/properties/ 
    file:/C:/IBM/8_5/AppServer/properties/ 
    file:/C:/IBM/8_5/AppServer/lib/startup.jar 
    file:/C:/IBM/8_5/AppServer/lib/bootstrap.jar 
    file:/C:/IBM/8_5/AppServer/lib/jsf-nls.jar 
    file:/C:/IBM/8_5/AppServer/lib/lmproxy.jar 
    file:/C:/IBM/8_5/AppServer/lib/urlprotocols.jar 
    file:/C:/IBM/8_5/AppServer/deploytool/itp/batchboot.jar 
    file:/C:/IBM/8_5/AppServer/deploytool/itp/batch2.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/lib/tools.jar 
    file:/C:/vdi/usr/ 
    
    OSGI: org.eclipse.osgi.internal.baseadaptor.DefaultClassLoader
    n/a
    
    Extension: com.ibm.ws.bootstrap.ExtClassLoader
    Delegation: true 
    Classpath:
    file:/C:/IBM/8_5/AppServer/java_1.7_64/lib/ 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/lib/dt.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/lib/ibmorbtools.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/lib/jconsole.jar 
    file:/C:/IBM/8_5/AppServer/java_1.7_64/lib/tools.jar 
    file:/C:/IBM/8_5/AppServer/profiles/AppSrv01/classes 
    file:/C:/IBM/8_5/AppServer/classes 
    file:/C:/IBM/8_5/AppServer/lib/ 
    file:/C:/IBM/8_5/AppServer/lib/COBOLCallStubGenerator.zip 
    file:/C:/IBM/8_5/AppServer/lib/EJBCommandTarget.jar 
    file:/C:/IBM/8_5/AppServer/lib/IVTClient.jar 
    file:/C:/IBM/8_5/AppServer/lib/OTiSConvertTime.jar 
    file:/C:/IBM/8_5/AppServer/lib/activation-impl.jar 
    file:/C:/IBM/8_5/AppServer/lib/admin.config.jobcl.jar 
    file:/C:/IBM/8_5/AppServer/lib/admin.config.rules.jar 
    file:/C:/IBM/8_5/AppServer/lib/admin.config.sched.jar 
    file:/C:/IBM/8_5/AppServer/lib/aspectjrt.jar 
    file:/C:/IBM/8_5/AppServer/lib/batch.wccm.jar 
    file:/C:/IBM/8_5/AppServer/lib/batchpmi.jar 
    file:/C:/IBM/8_5/AppServer/lib/batchprops.jar 
    file:/C:/IBM/8_5/AppServer/lib/batchutilsfep.jar 
    file:/C:/IBM/8_5/AppServer/lib/batfepapi.jar 
    file:/C:/IBM/8_5/AppServer/lib/bootstrap.jar 
    file:/C:/IBM/8_5/AppServer/lib/bsf-engines.jar 
    file:/C:/IBM/8_5/AppServer/lib/com.ibm.rls.jdbc.jar 
    file:/C:/IBM/8_5/AppServer/lib/commandlineutils.jar 
    file:/C:/IBM/8_5/AppServer/lib/commons-discovery.jar 
    file:/C:/IBM/8_5/AppServer/lib/databeans.jar 
    file:/C:/IBM/8_5/AppServer/lib/ffdcSupport.jar 
    file:/C:/IBM/8_5/AppServer/lib/htmlshell.jar 
    file:/C:/IBM/8_5/AppServer/lib/iscdeploy.jar 
    file:/C:/IBM/8_5/AppServer/lib/j2ee.jar 
    file:/C:/IBM/8_5/AppServer/lib/jNative2ascii.jar 
    file:/C:/IBM/8_5/AppServer/lib/jacl.jar 
    file:/C:/IBM/8_5/AppServer/lib/jrom.jar 
    file:/C:/IBM/8_5/AppServer/lib/launchclient.jar 
    file:/C:/IBM/8_5/AppServer/lib/lmproxy.jar 
    file:/C:/IBM/8_5/AppServer/lib/mail-impl.jar 
    file:/C:/IBM/8_5/AppServer/lib/openwebbeans.jar 
    file:/C:/IBM/8_5/AppServer/lib/pc-appext.jar 
    file:/C:/IBM/8_5/AppServer/lib/pmirm4arm.jar 
    file:/C:/IBM/8_5/AppServer/lib/rrd-appext.jar 
    file:/C:/IBM/8_5/AppServer/lib/rsadbutils.jar 
    file:/C:/IBM/8_5/AppServer/lib/rsahelpers.jar 
    file:/C:/IBM/8_5/AppServer/lib/serviceadapter.jar 
    file:/C:/IBM/8_5/AppServer/lib/setup.jar 
    file:/C:/IBM/8_5/AppServer/lib/startup.jar 
    file:/C:/IBM/8_5/AppServer/lib/tcljava.jar 
    file:/C:/IBM/8_5/AppServer/lib/urlprotocols.jar 
    file:/C:/IBM/8_5/AppServer/lib/wasservicecmd.jar 
    file:/C:/IBM/8_5/AppServer/lib/wses_dynaedge.jar 
    file:/C:/IBM/8_5/AppServer/lib/wsif-compatb.jar 
    file:/C:/IBM/8_5/AppServer/installedChannels 
    file:/C:/IBM/8_5/AppServer/web/help 
    file:/C:/IBM/8_5/AppServer/deploytool/itp/plugins/com.ibm.etools.ejbdeploy/runtime/ 
    file:/C:/IBM/8_5/AppServer/deploytool/itp/plugins/com.ibm.etools.ejbdeploy/runtime/batch.jar 
    file:/C:/IBM/8_5/AppServer/deploytool/itp/plugins/com.ibm.etools.ejbdeploy/runtime/ejbdeploy.jar 
    file:/C:/IBM/8_5/AppServer/deploytool/itp/plugins/com.ibm.etools.ejbdeploy/runtime/ejbmapvalidate.jar 
    file:/C:/IBM/8_5/AppServer/derby/lib/derby.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/sib.api.jmsra.rar/ 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/ 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.commonservices.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.connector.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.headers.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.jmqi.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.jmqi.local.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.jmqi.remote.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.jmqi.system.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.jms.admin.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mq.pcf.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.mqjms.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.commonservices.j2se.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.commonservices.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.jms.internal.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.jms.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.matchspace.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.provider.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.ref.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.wmq.common.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.wmq.factories.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.wmq.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/com.ibm.msg.client.wmq.v6.jar 
    file:/C:/IBM/8_5/AppServer/installedConnectors/wmq.jmsra.rar/dhbcore.jar 
    file:/C:/vdi/Db2Drivers-V9.1-FixPack12/db2jcc.jar 
    file:/C:/vdi/Db2Drivers-V9.1-FixPack12/db2jcc_license_cu.jar 
    file:/C:/vdi/Db2Drivers-V9.1-FixPack12/db2jcc_license_cisuz.jar 
    file:/C:/Program Files/apache-activemq-5.8.0/activemq-all-5.8.0.jar 
    
    WebSphere Application Server Protection Class Loader: com.ibm.ws.classloader.ProtectionClassLoader
    
    Module: com.ibm.ws.classloader.CompoundClassLoader
    Delegation: true 
    Classpath:
    file:/C:/workspace/default/.metadata/.plugins/com.genuitec.eclipse.blue.websphere.core/WebSphere_20_Application_20_Server_20_8_2e_5_20_at_20_localhost/hackplantEAR/hackplantEJB 
    file:/C:/git/myapp/hackplantRooftopEJB/bin 
    file:/C:/git/myapp/hackplantEJBClient/bin 
    file:/C:/workspace/default/.metadata/.plugins/com.genuitec.eclipse.blue.websphere.core/WebSphere_20_Application_20_Server_20_8_2e_5_20_at_20_localhost/hackplantEAR/hackplantCommon 
    file:/C:/git/myapp/hackplantEAR/commons-beanutils-1.9.2.jar 
    file:/C:/git/myapp/hackplantEAR/commons-collections-3.2.1.jar 
    file:/C:/git/myapp/hackplantEAR/commons-logging-1.1.1.jar 
    file:/C:/git/myapp/hackplantEAR/log4j-1.2.6.jar 
    file:/C:/workspace/default/.metadata/.plugins/com.genuitec.eclipse.blue.websphere.core/WebSphere_20_Application_20_Server_20_8_2e_5_20_at_20_localhost/hackplantEAR/hackplantWSC 
    file:/C:/git/myapp/hackplantEAR/axis-ant.jar 
    file:/C:/git/myapp/hackplantEAR/axis.jar 
    file:/C:/git/myapp/hackplantEAR/commons-discovery-0.2.jar 
    file:/C:/git/myapp/hackplantEAR/javaxzombie.jar 
    file:/C:/git/myapp/hackplantEAR/jaxrpc.jar 
    file:/C:/git/myapp/hackplantEAR/SystemUtils.jar 
    file:/C:/git/myapp/hackplantCore/bin 
    file:/C:/git/myapp/hackplantEAR/jdom.jar 
    file:/C:/git/myapp/hackplantJaxWSC/bin 
    file:/C:/git/myapp/hackplantEAR/wss4j-1.6.12.jar 
    file:/C:/git/myapp/hackplantEAR/xmlsec-1.5.5.jar 
    file:/C:/git/myapp/hackplantEAR/wsdl4j-1.5.1.jar 
    file:/C:/git/myapp/hackplantRooftopEJBClient/bin 
    file:/C:/git/myapp/hackplantEAR/commons-lang3-3.3.2.jar 
    
    Module: com.ibm.ws.classloader.CompoundClassLoader
    Delegation: true 
    Classpath:
    file:/C:/git/myapp/hackplantWS/WebContent/WEB-INF/classes 
    file:/C:/git/myapp/hackplantWS/WebContent 


# Dynamic Classloaders #

Full credit to the ZeroTurnaround [post](http://zeroturnaround.com/rebellabs/rebel-labs-tutorial-do-you-really-get-classloaders) for this code. This really drives homes some important points about Java and classloaders. Overlooking exception handling the code for a working dynamic classloader is quite minimal.

{% highlight java %}
public class CounterFactory {

  public static ICounter newInstance() {
    URLClassLoader tmp = new URLClassLoader(new URL[] { getClassPath() }) {
      public Class loadClass(String name) {
        try {
          if ("Counter".equals(name))
            return findClass(name);

          return super.loadClass(name);
        } catch (ClassNotFoundException e) {
          e.printStackTrace();
        }

        return null;
      }
    };

    try {
      return (ICounter) tmp.loadClass("Counter").newInstance();
    } catch (InstantiationException | IllegalAccessException | ClassNotFoundException e) {
      e.printStackTrace();
    }

    return null;
  }

  public static URL getClassPath() {
    try {
      return new URL("file:/home/ben/java/long-black.jar");
    } catch (MalformedURLException e) {
      e.printStackTrace();
    }
    return null;
  }
}

public class Counter implements ICounter {
  private int counter;

  public String message() {
    return "Version 1";
  }

  public int plusPlus() {
    return counter++;
  }

  public int counter() {
    return counter;
  }
}

public interface ICounter {
  String message();
  int plusPlus();
}

public class Main {
  private static ICounter counter1;
  private static ICounter counter2;

  public static void main(String[] args) {
    counter1 = CounterFactory.newInstance();

    while (true) {
      counter2 = CounterFactory.newInstance();

      System.out.println("1) " + counter1.message() + " = " + counter1.plusPlus());
      System.out.println("2) " + counter2.message() + " = " + counter2.plusPlus());
      System.out.println();

      try {
        Thread.sleep(3000);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  }
}
{% endhighlight %}

Notice the inline classloader sets up a classpath of `file:/home/ben/java/long-black.jar`. This is the source of the `Counter` class definition that will used.

Running the above produces (expected results):

    1) Version 1 = 0
    2) Version 1 = 0
    
    1) Version 1 = 1
    2) Version 1 = 0
    
    1) Version 1 = 2
    2) Version 1 = 0


As the second counter is being created from the factory within each roll of the loop, what happens if the `Counter` class `message()` method is modified to return "Version 2", and the jar is repackaged, while the application is running.

    1) Version 1 = 15
    2) Version 1 = 0
    
    1) Version 1 = 16
    2) Version 2 = 0
    
    1) Version 1 = 17
    2) Version 2 = 0

Unfortunately Java provide no "first class" support for modifying the class of an existing object. State should be propagated carefully between object instances, never assuming that one instance is using the same class definition as another, as highlighted above.


