---
layout: post
title: "BizTalk WMI Scripting"
date: "2008-01-07 23:39:19"
comments: false
categories:
- biztalk
---

A few weeks ago we had a WSE 2.0 send port fail—resulting in the suspension of hundreds of service instances. Resumption of these suspended WSE instances resulted in a consistent general BTSException, with little useful detail. Sadly, due to lack of access to the production environment, the root cause of this problem remains a mystery. It was requested that the message part content for each be extracted for further analysis, and manual rectification. While not huge numbers, this would prove to be a tedious and monotonous task for our sysops administrator.

A comprehensive suite of WMI classes (shipped standard with the product) offers programmatic access to most of the administrative functions available in BizTalk. To get up and running quickly, half-a-dozen samples are provided in the [SDK](http://msdn2.microsoft.com/en-us/library/aa559638.aspx).

Below is a simple script that uses the `MSBTS_ServiceInstance` and `MSBTS_MessageInstance` WMI classes to enumerate all the `Suspended (resumable)` service instances for a particular host, and writes out the message parts (including context properties) to disk.

Scripting BizTalk in this manner (eg. stop and unenlist orchestrations) would tie in nicely with automated builds, deployment scripts, MOM, etc. `SaveSuspendedMessages`.


    Sub SaveSuspendedMessages
      Dim Context, FromTime, UntilTime, InstSet, Query, MsgSet, wbemFlagReturnImmediately = 16 '0x10
      
      'Permissible Service Statuses [http://msdn2.microsoft.com/en-us/library/aa510147.aspx](http://msdn2.microsoft.com/en-us/library/aa510147.aspx)
      ' Ready to run 1
      ' Active 2
      ' Suspended (resumable) 4
      ' Dehydrated 8
      ' Completed with discarded messages 16
      ' Suspended (not resumable) 32
      ' In breakpoint 64
      
      'Permissible Service Classes
      '[http://msdn2.microsoft.com/en-us/library/ms949479.aspx](http://msdn2.microsoft.com/en-us/library/ms949479.aspx)
      ' Orchestration 1
      ' Tracking 2
      ' Messaging 4
      ' MSMQT 8
      ' Other 16
      ' Isolated adapter 32
      ' Routing failure report 64
      
      Query = "SELECT * FROM MSBTS_ServiceInstance " &_
      WHERE ServiceStatus = 4 AND ServiceClass = 4 " &_
      AND ServiceName LIKE '%MyApp%'"
      
      Set InstSet = GetObject("Winmgmts:!root\MicrosoftBizTalkServer").ExecQuery(Query, "WQL", wbemFlagReturnImmediately)
      
      For Each Inst In InstSet
        Query = "SELECT * FROM MSBTS_MessageInstance " &_
                "WHERE ServiceInstanceID = '" & Inst.InstanceID & "'"
        Set MsgSet = GetObject("Winmgmts:!root\MicrosoftBizTalkServer").ExecQuery(Query, "WQL", wbemFlagReturnImmediately)
        wscript.echo Inst.InstanceID + " " + Inst.HostName
      
        For Each Msg in MsgSet
          Msg.SaveToFile(strDirectory)
        Next
      Next
    End Sub
