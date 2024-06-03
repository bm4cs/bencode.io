---
layout: post
title: "Binding Dependencies"
date: "2008-01-28 01:06:36"
comments: false
categories:
- biztalk
---

When ingesting (importing) BizTalk application bindings between different environments/machines it is important that its dependencies (hosts, host instances and adapters) are setup before running the import. Otherwise you run the risk of getting the following somewhat misleading error message:

> Failed to update binding information.
> The following items could not be matched up to hosts due to name and/or trust level mismatches:
> Item: 'FILE' Host: 'MyBizTalkHost' Trust level: 'Untrusted'
> You must do one of the following:
> 1) Create hosts with these names and trust levels and try again
> 2) Re-export the MSI without the binding files and have a post import script apply a suitable binding file.

The annoying thing about this error message is that the problem with my setup was not directly related to a host name and/or a trust level mismatch. My particular problem was related to host-to-adapter bindings; that is the hosts must be bound (or registered) with the adapters which it needs to employ, as per the applications port definitions. 

So before importing a binding:

1. Setup hosts with names and trust levels that match the binding.  
2. Create host instances for the hosts.  
3. Register the hosts with the adapters that it requires.
