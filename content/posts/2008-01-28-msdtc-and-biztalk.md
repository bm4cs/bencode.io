---
layout: post
title: "MSDTC and BizTalk"
date: "2008-01-28 00:43:38"
comments: false
categories:
- biztalk
---

Last week I had to rebuild a BizTalk 2006 development box, running Windows Server 2003 R2. Im not sure where or how the base image came about, but through installing BizTalk I hit a number of interesting snags, all relating to not having a functional Distributed Transaction Coordinator or MSDTC; commonly employed for managing transactions across distributed resources.

OK, so the basic "installation" procedure ran fine. That is the necessary files to facilitate a functional BizTalk Server were copied and registered without error. Running the BizTalk Configuration tool to actually get the various pieces working together were where things were halted to a stop.

**Step 1**: Setup the SSO database, so BizTalk has somewhere to file its configuration. No problems here.

**Step 2**: Setup of the "BizTalk Group" fails. This step encompasses building the management, message box and configuration databases. The eventlog shows that a System.EnterpriseServices.TransactionProxyException occurred. It seems many others have walked down this road before me—install DTC to remedy. MSDTC is an optional Windows component which I found had not been installed... so I installed it. On a 2003 server in the Add/Remove Programs > Windows Components > Application Server > DTC. It seems the configuration tool uncleanly terminated, as 1 of the 3 databases had been setup. The tool is not smart enough to re-run this step, in this situation. Pop open SQL Management Studio blast away any locks on the database/s and drop them, so the BizTalk Configuration tool can try again. Excellent it worked, a BizTalk Group has been successfully created.

**Step 3**: Setup of the "BizTalk Runtime" fails. The eventlog informs me that there has been an "Error while accessing the SSO database". Here is an except from the eventlog entry—quiet useful information.

> An error occurred while attempting to access the SSO database.<br />
> Function: ApplicationInfoCreate<br />
> File: adminserver.cpp:1765<br />
> System.Transactions : Network access for Distributed Transaction Manager (MSDTC) has been <br />disabled.  Please enable DTC for network access in the security configuration for MSDTC using the component Services Administrative tool.<br />
> SQL Error code: 0xE2E2E2E2<br />
> *Error code*: 0xC0002A21, An error occurred while attempting to access the SSO database.

Well I knew MSDTC has been installed (from the previous step), but I assume if you attempted to setup the "BizTalk Runtime" without it installed you would get the same response here. So make sure MSDTC is installed first. OK, DTC network access needs to be enabled to get BizTalk past this step. Pop open an MMC console > Component Services > Properties on My Computer > MSDTC tab > Security Configuration, ensure that Network DTC access has been checked and allows both inbound and outbound messages. OK, now retry the Configuration Tool...excellent, it worked.

![DTC Security Configuration](/images/dtc.png)
