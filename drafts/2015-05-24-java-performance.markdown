---
layout: post
title: "Java Performance Toolbox"
date: "2015-05-24 19:14:55"
comments: false
categories: "Java"
---

Basic VM information

JVM tools can provide basic information about a running JVM process: how long it has been up, what JVM flags are in use, JVM system properties, and so on.

#### uptime

The length of time the JVM has been up can be found via this command:

    jcmd pid VM.uptime


#### System properties

The set of items in the `System.getProperties()` can be displayed with either of these commands:

    jcmd pid VM.system_properties
    or
    jinfo -sysprops pid

This includes all properties set on the command line with a -D option, any properties dynamically added by the application, and the set of default properties for the VMpe.


#### JVM Version

    jcmd pid VM.version


#### JVM Command Line

The command line can be displayed in the VM summary tab of jconsole, or via jcmd:

    jcmd pid VM.command_line


#### JVM Tuning Flags

The tuning flags in effect for an application can be obtained like this:

    jcmd pid VM.flags [-all]


Working with tuning flags

Platform specific tuning flag defaults for a particular JVM, the `XX:+PrintFlagsFinal` option on the command line is more useful.

    java other_options -XX:+PrintFlagsFinal -version

Output:

    ...many line omitted here...
    uintx InitialHeapSize                          := 4169431040     {product}
    intx InlineSmallCode                           = 2000            {pd product}

The colon in the first line of included output indicates that a non-default value is in use for the flag in question.

The second line (without a colon) indicates that value is the default value for this version of the JVM. Default values for some flags may be different on different platforms—which is shown in the final column of this output. `product` means that the default setting of the flag is uniform across all platforms; `pd product` indicates that the default setting of the flag is platform dependent.


### jinfo

`jinfo` is that it allows certain flag values to be changed during execution of the program.

    jinfo -flags pid

`jinfo` can inspect the value of an individual flag:

    **jinfo -flag PrintGCDetails pid**
    -XX:+PrintGCDetails

Although jinfo does not itself indicate if a flag is manageable or not, flags that are manageable (as identified when using the PrintFlagsFinal argument) can be turned on or off via jinfo:

    **jinfo -flag -PrintGCDetails pid**  # turns off PrintGCDetails
    **jinfo -flag PrintGCDetails pid**
    -XX:-PrintGCDetails
