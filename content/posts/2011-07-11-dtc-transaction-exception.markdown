---
layout: post
title: "The BizTalk WCF SQL Binding and MSDTC"
date: "2011-07-11 07:00:00"
comments: false
categories:
- biztalk
---

Highlights a common misconfiguration of the BizTalk WCF Adapter Pack 2.0 SQL binding.

Here's an interesting tale. If you find errors and BizTalk interesting. The following, very descriptive error (it's true) occurs when you attempt to use the [BizTalk WCF Adapter Packs](http://www.microsoft.com/download/en/details.aspx?id=333) (2.0) SQL binding with a remote SQL server database, that is not configured to allow remote DTC (Distributed Transaction Coordinator) sessions to take place.

    Error Description: System.Transactions.TransactionException: The partner transaction manager has disabled its support for remote/network transactions. (Exception from HRESULT: 0x8004D025) 
       ---&gt; System.Runtime.InteropServices.COMException: The partner transaction manager has disabled its support for remote/network transactions. (Exception from HRESULT: 0x8004D025)
       at System.Transactions.Oletx.ITransactionShim.Export(UInt32 whereaboutsSize, Byte[] whereabouts, Int32&amp; cookieIndex, UInt32&amp; cookieSize, CoTaskMemHandle&amp; cookieBuffer)
       at System.Transactions.TransactionInterop.GetExportCookie(Transaction transaction, Byte[] whereabouts)
       --- End of inner exception stack trace ---
       
    Server stack trace: 
       at System.Runtime.AsyncResult.End[TAsyncResult](IAsyncResult result)
       at System.ServiceModel.Channels.ServiceChannel.SendAsyncResult.End(SendAsyncResult result)
       at System.ServiceModel.Channels.ServiceChannel.EndCall(String action, Object[] outs, IAsyncResult result)
       at System.ServiceModel.Channels.ServiceChannel.EndRequest(IAsyncResult result)


The SQL machine needs to be opened up. This can be done by using the Component Services MMC snap in (comexp.msc).

![Component Services MMC snap in](/images/b/dtc-mmc.png)


Bring up properties on the "Local DTC" node. Hit the security tab, and ensure it resembles the following.

![MSDTC Security Configuration](/images/b/dtc.png)


This still doesn’t explain why DTC is being involved in the first place. DTC's job after all is to facilitate distributed transactions across multiple resources. Well, actually as so eloquently put by [Microsoft](http://msdn.microsoft.com/en-us/library/dd787924(v=bts.10\).aspx), touching anything from BizTalk always involves multiple resources.

> Performing operations on SQL Server using BizTalk Server always involves two resources; the adapter connecting to SQL Server and the BizTalk Message Box residing on SQL Server. Hence, all operations performed using BizTalk Server are performed within the scope of an MSDTC transaction. So, to use the SQL adapter with BizTalk Server, you must always enable MSDTC.
