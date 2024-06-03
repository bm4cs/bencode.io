---
layout: post
title: "XLANGMessage Deserialization Issues"
date: "2008-07-27 20:40:26"
comments: false
categories:
- biztalk
---

There have been a few scenarios where the complexity of using a standard BizTalk map, have far outweighed using some custom code. This approach, prescribed in [Professional BizTalk Server 2006](http://www.amazon.com/Professional-BizTalk-Server-Darren-Jefford/dp/0470046422/ref=pd_bbs_sr_1?ie=UTF8&s=books&qid=1217055324&sr=8-1) as the "Manual Mapping" technique, involves code generating types (<a href="http://msdn.microsoft.com/en-us/library/x6c1kb0s(VS.71).aspx">xsd.exe</a>) from the message schema and using some simple BizTalk object model to stream-in the message, craft a response and return it back to the BizTalk runtime. C# snippet:

    public Invoice Transform(XLANGMessage xlangMsg)
    {
      Order order = (Order)xlangMsg[0].RetrieveAs(typeof(Order));
      ..
      return invoice;
    }

While this approach has a number of pros and cons, it can definitely be a useful tactic given the situation. I am interested in how this "custom code" method differs from XSLT taking a performance perspective. My main concern, is the duplication of message definitions in multiple places, breaking the fundamental DRY (Don't Repeat Yourself) principle.

In a real-world solution, code (similar to the above snippet) was bubbling up an System.FormatException: "The string '' is not a valid AllXsd value". The consumer was on .NET 2.0, and (I assume) wsdl.exe (or Add Web Reference from VS.NET) had been used to create the proxy code for our web service exposed orchestration. Value type members (as opposed to reference type) of the message, generate two fields (and properties) in the resultant proxy code. One is for the value itself (e.g. a DateTime) and the other is a flag to indicate whether its value has been specified.

After some digging around, discovered that the consuming code had hard-coded a boolean "specified" flag value to true for a particular DateTime value. In other words it didnt matter if the actual value was specified or not, the flag always returned a true value. When it came to deserialization time on the server (in this case the custom map code) an empty (not null) value could not be assigned to the DateTime property of the object.

