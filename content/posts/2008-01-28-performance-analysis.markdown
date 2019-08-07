---
layout: post
title: "Performance Analysis"
date: "2008-01-28 12:46:48"
comments: false
categories:
- biztalk
---

[Log Parser](http://www.microsoft.com/downloads/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07&displaylang=en): An elegant utility that does all the real grunt work. It is well worth spending some time with this guy as it will come in handy for other unexpected situations, like analysing your web server logs, or parsing through custom CSV files etc.

[Microsoft Office 2003 Web Components](http://www.microsoft.com/downloads/details.aspx?FamilyId=7287252C-402E-4F72-97A5-E0FD290D4B76&displaylang=en): Some COM components that provide for graph generation of the statistical data.

[Performance Analysis of Logs](http://www.codeplex.com/PAL): A script that automates the "leg work" involved in real-world performance analysis, such as managing the set of counters to be used for particular situations (eg. BizTalk 2006 analysis), invocation of log parser to do the actual analysis of each counter, detection of threshold breaches when things seem to be fishy. PAL is implemented as a VBScript, and comes with a little .NET WinForm GUI which can be (optionally) used to setup the arguments to be fed into the VBScript. The result, a comprehensive HTML report complete with alerts (threshold breaches), graphs and explanations.

PAL analyses log files, it does not collect them—although there is talk of a future version supporting this. However, a suite of helper scripts (again VBScript) ship with PAL 1.1.7 and higher. These are tucked away in the %PAL_Directory%\PerfmonLogScripts directory. Here's what I did for my BizTalk test box—invocation to remote servers is supported.

1. `cscript CreateAndStartPerfmonLogs.vbs MyTestBox BizTalk CounterList_BizTalk2006.txt`

2. Stop the performance counter collector set when done. There is a script to help do this, but I found it easier to stop the collector set using perfmon. Fire up Perfmon > Data Collector Sets > User Defined > HealthCheck_BizTalk_MyTestBox > Click the stop button. There should be a performance log that corresponds to the collection just ran in `c:\perflogs`.

3. Start up the PAL (PAL.exe) front-end to configure its arguments. Point it to the newly created performance log file, and make sure that the threshold file drop-down corresponds to the counters which you collected (eg. its not as useful to use the "System Overview" threshold template when you have the performance data for "BizTalk Server 2006"). The rest of the form is self-explanatory. After a period of time (depending how much data has been collected) an HTML report should present itself.

