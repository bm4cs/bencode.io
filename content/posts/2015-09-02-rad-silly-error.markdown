---
layout: post
title: "Eclipse brain damage"
date: "2015-09-02 10:58:33"
comments: false
categories: [Java]
---

In my current project we use IBM's version of Eclipse. On a Windows 7 VM. The VM crashes weekly.

Not only has this made me paranoid about loosing my work (I stash my changes in version control like a demon), it seems to corrupt my RAD/Eclipse instance.

Starting RAD produces the useful "An error has occured" error message:

![Eclipse error](/images/rad-error.png)

    !SESSION 2015-09-02 10:53:50.331 -----------------------------------------------
    eclipse.buildId=unknown
    java.fullversion=JRE 1.7.0 IBM J9 2.6 Windows 7 amd64-64 Compressed References 20140313_192258 (JIT enabled, AOT enabled)
    J9VM - R26_Java726_SR6_20140313_1318_B192258
    JIT  - r11.b05_20131003_47443.02
    GC   - R26_Java726_SR6_20140313_1318_B192258_CMPRSS
    J9CL - 20140313_192258
    BootLoader constants: OS=win32, ARCH=x86_64, WS=win32, NL=en_AU
    Framework arguments:  -product com.ibm.rational.rad.product.v80.ide
    Command-line arguments:  -os win32 -ws win32 -arch x86_64 -product com.ibm.rational.rad.product.v80.ide

    !ENTRY org.eclipse.equinox.app 0 0 2015-09-02 10:53:52.658
    !MESSAGE Product com.ibm.rational.rad.product.v80.ide could not be found.

    !ENTRY org.eclipse.osgi 4 0 2015-09-02 10:53:54.131
    !MESSAGE Application error
    !STACK 1
    java.lang.RuntimeException: No application id has been found.
      at org.eclipse.equinox.internal.app.EclipseAppContainer.startDefaultApp(EclipseAppContainer.java:242)
      at org.eclipse.equinox.internal.app.MainApplicationLauncher.run(MainApplicationLauncher.java:29)
      at org.eclipse.core.runtime.internal.adaptor.EclipseAppLauncher.runApplication(EclipseAppLauncher.java:110)
      at org.eclipse.core.runtime.internal.adaptor.EclipseAppLauncher.start(EclipseAppLauncher.java:79)
      at org.eclipse.core.runtime.adaptor.EclipseStarter.run(EclipseStarter.java:353)
      at org.eclipse.core.runtime.adaptor.EclipseStarter.run(EclipseStarter.java:180)
      at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
      at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:88)
      at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:55)
      at java.lang.reflect.Method.invoke(Method.java:618)
      at org.eclipse.equinox.launcher.Main.invokeFramework(Main.java:629)
      at org.eclipse.equinox.launcher.Main.basicRun(Main.java:584)
      at org.eclipse.equinox.launcher.Main.run(Main.java:1438)
      at org.eclipse.equinox.launcher.Main.main(Main.java:1414)

The error log isn't much help. Something somewhere is corrupt. Asking Eclipse to clean itself seems to fix things:

    c:\IBM\SDP\eclipse.exe -clean

