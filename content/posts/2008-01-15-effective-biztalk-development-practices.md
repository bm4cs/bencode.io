---
layout: post
title: "Effective BizTalk Development Practices"
date: 2008-01-15 22:50:21
comments: false
categories:
- biztalk
---

[Alan Smith](http://geekswithblogs.net/asmith) has a fairly dated (2004), but useful post on [The Seven Habits of Highly Effective BizTalkers](http://geekswithblogs.net/asmith/articles/17333.aspx). Alan's article has inspired me to discover what else help make an "effective BizTalk developer"... a work in progress.

Update: Marty Wasznicky and Scott Zimmerman have put together a quality article published in May 2007 MSDN Magazine called [8 Tips And Tricks For Better BizTalk Programming](http://msdn.microsoft.com/msdnmag/issues/07/05/BizTalk/Default.aspx). This article offers a number of seasoned tips which I found to be very insightful, such as the "always use multi-part message types" tip. Check it out [here](http://msdn.microsoft.com/msdnmag/issues/07/05/BizTalk/Default.aspx).

1.  **Toolkit**: [Here it is](/blog/2008/01/13/tools/).
2.  **Testing**: Automated functional and performance testing provide a safety harness throughout the SDLC, ultimately assisting in the creation of better quality products. Some killer (mainstream) testing frameworks I have used in my BizTalk development: [NUnit](http://www.nunit.org), [Rhino Mocks](http://www.ayende.com/projects/rhino-mocks.aspx), [BizUnit](http://www.codeplex.com/bizunit), [LoadGen](http://www.microsoft.com/downloads/details.aspx?FamilyID=c8af583f-7044-48db-b7b9-969072df1689&displaylang=en).
3.  **Automation**: Whether its boilerplate housework activity such as building or packaging a BizTalk solution or something a bit more exotic such as cycling the host instances after a deployment. If manual activities are being done on a continual basis, consider automating it. Powerful build frameworks (NAnt, MSBuild) can assist in this endeavour, but quite ofter a simple batch (or VB) script will suffice.
4.  **Multi-Part Message Types**: This is a great tip from Marty Wasznicky and Scott Zimmerman (see above). Its inevitable, one day you'll want to change the schema (or message type) on which a message it based. When starting out in BizTalk, I fell into the mind-set where all messages were "strongly typed" (or associated with a specific schema). This approach while it appears to be sound on the surface, sews in tight dependencies throughout the design. This coupling become all to clear when you attempt to change the schema type: its currently difficult to locate the specific receive/send shape associations with a particular message-type, port associations need to be recreated, change the type of the message and all associated ports, update port-type definitions. This problem like many others can be overcome be adding in an extra layer of abstraction—multi-part message types wrap (or abstract) the underlying schema. Instead of creating messages with a "Message Type" property of schema, choose "Create New Multi-Part Message Type, and make sure the "Message Body Part" property is set to true.
5.  **Direct** Bound Ports: Because publish/subscribe is really really powerful.
6.  **Patterns** (Reusable Design): TODO
7.  **Schema Encapsulation**: TODO
8.  **XSLT**: TODO
9.  **Naming Standards**: The value of having solutions that clearly convey their intent not only makes BizTalk artefacts technically more maintainable, it opens up being able to expose your orchestrations to a non-technical audience as documentation. [Scott Colestock](http://www.traceofthought.net/) has an excellent [template](http://www.traceofthought.net/misc/BizTalk%20Naming%20Conventions.htm) for getting a set of BizTalk naming standards up and running.
