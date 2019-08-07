---
layout: post
title: "soapUI freeze on Mac OS X"
date: "2015-01-25 22:31:43"
comments: false
categories:
- dev
tags:
- java
---

Well first time for everything. Messing around with some JAX-WS web services, wanted to spin up my favourite SOAP frontend, soapUI. On my Mac. Annoyingly it would just immediately hang. Completely frozen. soapUI by default will try and render a web page on startup. This doesn't seem to work out so well when running on OSX.

A handy little article I found on [Anton Perez's blog](http://antonperez.com/2012/09/05/fix-for-soapui-freezing-on-mac-os-x-lion/), made my day.


- Start 'Activity Monitor' and Force Kill your dead soapUI process.
- In Finder, `/Applications/SmartBear/soapUI-5.0.0.app` > Show Package Contents.
- Edit `/Applications/SmartBear/soapUI-5.0.0.app/Contents/java/app/bin/soapui.sh`.
- Uncomment this line`#   JAVA_OPTS="$JAVA_OPTS -Dsoapui.browser.disabled=true"`.
- Edit `/Applications/SmartBear/soapUI-5.0.0.app/Contents/vmoptions.txt`.
- Add `-Dsoapui.browser.disabled=true`.
- Start soapUI.

Checkout these commented lines in `soapui.sh`...our fix ready to go:

    if [ $SOAPUI_HOME != "" ] 
    then
        JAVA_OPTS="$JAVA_OPTS -Dsoapui.ext.libraries=$SOAPUI_HOME/bin/ext"
        JAVA_OPTS="$JAVA_OPTS -Dsoapui.ext.listeners=$SOAPUI_HOME/bin/listeners"
        JAVA_OPTS="$JAVA_OPTS -Dsoapui.ext.actions=$SOAPUI_HOME/bin/actions"
      JAVA_OPTS="$JAVA_OPTS -Djava.library.path=$SOAPUI_HOME/bin"
      JAVA_OPTS="$JAVA_OPTS -Dwsi.dir=$SOAPUI_HOME/wsi-test-tools"
    #uncomment to disable browser component
    #   JAVA_OPTS="$JAVA_OPTS -Dsoapui.browser.disabled=true"
    fi


