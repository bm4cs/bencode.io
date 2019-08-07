---
layout: post
title: "WMI with System.Management"
date: "2008-03-18 00:18:33"
comments: false
categories: BizTalk
---

Lately i've come across the requirement to provide diagnostic/environmental information from within BizTalk itself. Integration solutions can become unwieldy as the number of participating scheduled processes, windows services, web services, databases, COM+ components, queues and so on increases.

The deployment of such scenarios often involves a number of independent installers and/or release procedures—eg. one for each vendor system and one for the integration (ie. BizTalk) solution itself.

Ensuring that the correct environmental configuration files, databases, business rules etc. have been put in place, can make a sysadmins life rather tedious. Providing the ability to ascertain key environmental configuration can ease deployment headaches when things don't seem to be working.

In addition to probing participating systems for their environmental (eg. service account/s names, database connection details, dll versions, server time, etc.) information, providing BizTalk environmental details is also useful. Whether your gathering the BizTalk environmental data from an orchestration, pipeline, or map it soon  becomes clear that BizTalk's runtime configurable + agnostic approach to physical ports/adapters will require some way of querying the setup details of particular adapters. To complicate things a little, custom adapter configuration is securely stored in BizTalk's Enterprise Single Sign-On (ESSO) subsystem.

Fortunately BizTalk is highly instrumented to the Windows Management Instrumentation (WMI) infrastructure. API's in the `System.Management` namespace provide access to this infrastructure, here's a sample C# snippet that queries off a given send ports URI (primary transport address):

    public static string SendPortUrl(string sendPortName)
    {
      string queryString = String.Format(
        "SELECT * FROM MSBTS_SendPort WHERE  Name = \"{0}\"",
        sendPortName);
    
      string scopeString = String.Format(
        "\\\\{0}\\root\\MicrosoftBizTalkServer",
        Environment.MachineName);
    
      ObjectQuery query = new ObjectQuery(queryString);
      ManagementScope scope = new ManagementScope(scopeString);
      ManagementObjectSearcher search = new ManagementObjectSearcher(scope, query);
      ManagementObjectCollection results = search.Get();
    
      foreach (ManagementObject sendPort in results)
      {
        return sendPort["PTAddress"].ToString();
      }

      return "Could not resolve send port.";
    }
