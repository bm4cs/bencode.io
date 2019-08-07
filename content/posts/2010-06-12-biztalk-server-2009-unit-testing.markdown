---
layout: post
title: "BizTalk Server 2009 Unit Testing"
date: "2010-06-12 14:00:00"
comments: false
categories: "BizTalk"
---

I feel like i've missed the boat with this, but the "first class" unit testing support that has been added to BizTalk Server 2009 is terrific. Unit testing with BizTalk Server up to this point, has always been very painful and custom.

How was this ground breaking feat made possible?

A project level build switch has been added to all Visual Studio BizTalk project types. Check it out, bring project properties up for any BizTalk 2009 project in your solution, and there will be an "Enable Unit Testing" true/false flag sitting there.

Setting this to true, instructs the BizTalk MSBuild tasks that take our precious BizTalk artefacts like orchestrations, maps, pipelines and so on and parses and compiles them into MSIL, to add an extra layer of inheritance between for example, our pipeline and the real BizTalk pipeline base class. A whole family of these new "intermediate" testable classes live in the `Microsoft.BizTalk.TestTools.dll` assembly (available under `c:\Program Files(x86)\Microsoft BizTalk Server 2009\Developer Tools\`) such as `Microsoft.BizTalk.TestTools.Pipeline.TestableReceivePipeline` and `Microsoft.BizTalk.TestTools.Map.TestableMap`.

Now the level resistance to getting effective unit tests up an running is so low, there really is no excuse not to have good repeatable unit tests across all your BizTalk artefacts.

Here’s a small snippet (intended for use as an MSTest unit test) that invokes a BizTalk map, and verifies the resulting output using some LINQ to XML.

{% highlight csharp %}
[TestClass]
public class MapTests
{
  public MapTests() { } 
  public TestContext TestContext { get; set; }

  [TestMethod]
  public void Foo_To_Bar()
  {
    TestableMapBase map = new Foo_To_Bar();
    map.ValidateInput = false;
    map.ValidateOutput = false;
    
    map.TestMap(
      "input.xml",
      InputInstanceType.Xml,
      "output.xml",
      OutputInstanceType.XML);
    
    var document = XDocument.Load("output.xml");
    string interchangeId = 
      (from header in document.Descendants("Header")
       select (string)header.Element("InterchangeId")).Single(); 
    
    Assert.IsTrue(interchangeId.Length > 0);
  }
}
{% endhighlight %}
