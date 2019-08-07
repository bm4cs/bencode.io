---
layout: post
title: "Autofac Your WCF"
date: "2012-03-22 07:00:00"
comments: false
categories: "WCF,Autofac"
---

Autofac (a .NET IoC container) makes .NET code better. Simple. Controlling the way software interacts with it's components (dependencies) is one powerful way to the increase its "bendability". Bendability meaning how well a chunk of software is able to cope with change (this is inevitable). WCF's unique object model (bindings, endpoints, behaviors, contracts, etc) can make doing IoC more of a challenge, however Autofac's native WCF integration comes to the rescue.

Autofac (a .NET IoC container) makes .NET code better. Simple. Controlling the way software interacts with it's components (dependencies) is a powerful way to the increase its "bendability". Bendability being softwares' ability to adapt with change (which is inevitable). The [Autofac](http://code.google.com/p/autofac/) project provides a native extension that supports WCF, called [WcfIntegration](http://code.google.com/p/autofac/wiki/WcfIntegration). WCF's unique object model (bindings, endpoints, behaviors, contracts, etc) can make doing IoC more of a challenge, however Autofac's native WCF integration comes to the rescue. Using this integration, Autofac can host services in a WCF server, and can improve the reliability of WCF clients.

> There's no problem in Computer Science that can't be solved by adding another level of indirection to it

`Autofac.Integration.Wcf.dll` is included in the Autofac binary downloads. To use the integration you need to reference it, in addition to the core `Autofac.dll`.

As per most IoC containers, when Autofac instantiates a component, it satisfies the component's dependencies by finding and instantiating other components. Components express their dependencies to Autofac as constructor parameters.

Using Autofac in the context of an IIS HTTP activated WCF service is pretty straight forward:

1.  In global.asax application startup, build a Container where your service type is registered.
2.  Set `AutofacHostFactory.Container` with this built container.
3.  Update your `.svc` files to use the `AutofacServiceHostFactory` (for BasicHttpBinding or WSHttpBinding services) or the `AutofacWebServiceHostFacotry` (for WebHttpBinding services).

Below are some tiny code snippets that highlight how to configure a "contract type registration" with Autofac. Contract type binding is one of 3 methods that Autofac supports, which are: implementation type registration (e.g. `Service="TestService.Service1, TestService"`), contract type registration (e.g. `Service="TestService.IService1, TestService"`) and named service registration (e.g. `Service="my-service"`).


### IUserNameGenerator.cs

{% highlight csharp %}
public interface IUserNameGenerator
{
  string Create();
}
{% endhighlight %}


### SqlUserNameGenerator.cs

{% highlight csharp %}
public class SqlUserNameGenerator : IUserNameGenerator
{
  private MySpecialDb _db;
  
  public string Create()
  {
    string username = null;
    _db.uspUserNameGeneration(ref username);
    return username;
  }
}
{% endhighlight %}


### IFooService.cs

{% highlight csharp %}
[ServiceContract]
public interface IFooService
{
  [OperationContract]
  void DoSomethingFancy(SomethingFancyRequest request);
}
{% endhighlight %}


### FooService.cs

{% highlight csharp %}
public class FooService : IFooService
{
  private IDecryptor _decryptor;
  private IUserNameGenerator _userNameGenerator;
  
  public FooService(IDecryptor decryptor, IUserNameGenerator userNameGenerator)
  {
    _decryptor = decryptor;
    _userNameGenerator = userNameGenerator;
  }
  
  public void DoSomethingFancy(SomethingFancyRequest request)
  {
    // implementation goes here
  }
}
{% endhighlight %}


### Foo.svc

{% highlight xml %}
<%@ ServiceHost
  Service="Net.Bencode.IFooService, Net.Bencode.FooService"  
  Factory="Autofac.Integration.Wcf.AutofacServiceHostFactory, Autofac.Integration.Wcf" %>
{% endhighlight %}


### Global.asax

{% highlight csharp %}
public class Global : System.Web.HttpApplication
{
  protected void Application_Start(object sender, EventArgs e)
  {
    var builder = new ContainerBuilder();
    builder.Register(c => new SqlUserNameGenerator()).As<IUserNameGenerator>();
    builder.Register(c => new AesDecryptor()).As<IDecryptor>();
    builder.Register(c => new FooService(c.Resolve<IUserNameGenerator>(), c.Resolve<IDecryptor>())).As<IFooService>();
    AutofacHostFactory.Container = builder.Build();    
  }
}
{% endhighlight %}

Your done, that's it! In addition to the WCF integration, Autofac has fantastic support for ASP.NET MVC and MEF.

For bonus points, having the IoC container configure itself from XML configuration may be desirable given your situation. For example, you may want to stub out objects loaded by the container in a development environment, for testing purposes. Most IoC containers provide this support, and [Autofac is no exception](http://code.google.com/p/autofac/wiki/XmlConfiguration).


### Global.asax

You need to declare a section handler somewhere near the top of your config file.

{% highlight csharp %}
public class Global : System.Web.HttpApplication
{
  protected void Application_Start(object sender, EventArgs e)
  {
    var builder = new ContainerBuilder();
    builder.RegisterModule(new ConfigurationSettingsReader("autofac"));
    AutofacHostFactory.Container = builder.Build();    
  }
}
{% endhighlight %}


### web.config

Then, provide a section describing your components:

{% highlight xml %}
<?xml version="1.0"?>
<configuration>
  <configSections>
    <section name="autofac" type="Autofac.Configuration.SectionHandler, Autofac.Configuration"/>
  </configSections>

  <autofac defaultAssembly="Cer.ClientPortal.Services.ActiveDirectory">
    <components>
      <component type="Net.Bencode.FooService, Net.Bencode.FooService"
                 service="Net.Bencode.IFooService" />
    </components>
  </autofac>
</configuration>
{% endhighlight %}
