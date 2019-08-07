---
layout: post
title: "WCF Error Handling using IErrorHandler and log4net"
date: "2012-04-11 07:00:00"
comments: false
categories:
- dev
tags:
- wcf
---

When its comes to managing and supporting WCF services, like any software, having insight into erroronous situtions is essential. There are several ways to go about this that are specific to WCF, such as enabling a trace listener for example. A more customisable option involves fleshing out an [IErrorHandler](http://msdn.microsoft.com/en-us/library/system.servicemodel.dispatcher.ierrorhandler.aspx). As put by MSDN, provides the necessary hooks to run custom error processing logic.

> Allows an implementer to control the fault message returned to the caller and optionally perform custom error processing such as logging.

To the code. Couple of quick notes and assumptions about it. The `IErrorHandler` concrete implementation uses Apache's log4net logging library. I am dealing with only IIS hosted WCF services so can rely on ASP.NET pipeline events to fire, such as the ApplicationStart event in `global.asax` to do initalisation work such as setting up a log4net logger.

### ErrorHandlerBehavior.cs ###
The extension element definition, so consumers can bind against the behavior in their respective system.servicemodel configuration section.

{% highlight csharp %}
using System;
using System.ServiceModel.Configuration;

namespace Net.Bencode.WCF.ErrorHandlerBehavior
{
  public class ErrorHandlerBehavior : BehaviorExtensionElement
  {
    protected override object CreateBehavior()
    {
      return new ErrorServiceBehavior();
    }

    public override Type BehaviorType
    {
      get { return typeof(ErrorServiceBehavior); }
    }
  }
}
{% endhighlight %}



### ErrorServiceBehavior.cs ###

The behavior itself. Note how the `Log4NetErrorHandler` is added to teh ErrorHandlers collection for every channel dispatcher that exists.

{% highlight csharp %}
using System.Collections.ObjectModel;
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;

namespace Net.Bencode.WCF.ErrorHandlerBehavior
{
  public class ErrorServiceBehavior : IServiceBehavior
  {
    public void Validate(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)
    {}

    public void AddBindingParameters(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase, Collection<ServiceEndpoint> endpoints, BindingParameterCollection bindingParameters)
    {}

    public void ApplyDispatchBehavior(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)
    {
      var handler = new Log4NetErrorHandler();
      foreach (var dispatcher in serviceHostBase.ChannelDispatchers)
      {
        dispatcher.ErrorHandlers.Add(handler);
      }
    }
  }
}
{% endhighlight %}


### Log4NetErrorHandler.cs ###

The `IErrorHandler` log4net logger.

{% highlight csharp %}
using System;
using System.Reflection;
using System.ServiceModel.Channels;
using System.ServiceModel.Dispatcher;
using log4net;

namespace Net.Bencode.WCF.ErrorHandlerBehavior
{
  public class Log4NetErrorHandler : IErrorHandler
  {
    private static ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);

    public void ProvideFault(Exception error, MessageVersion version, ref Message fault)
    {}

    public bool HandleError(Exception exception)
    {
      Log.Error("Unhandled WCF exception", exception);
      return false;
   }
  }
}
{% endhighlight %}


### AssemblyInfo.cs ###

Instructs log4net where/how to pickup its XML configuration.

    [assembly: log4net.Config.XmlConfigurator(Watch = true)]



### Global.asax.cs ###

{% highlight csharp %}
 namespace Net.Bencode.WCF.SampleService
 {
   public class Global : System.Web.HttpApplication
   {
     protected void Application_Start(object sender, EventArgs e)
     {
       log4net.Config.XmlConfigurator.Configure();
     }
     //...
   }
 }
{% endhighlight %}


### web.config ###
Specific to each WCF service. Two key sections to highlight are the log4net configuration (which uses an AdoNetAppender to log into a SQL Server database), and the WCF (System.ServiceModel) chunk that binds the custom IErrorHandler against the service. Configuring log4net specifically to each service provides the flexibility of controlling the IErrorHandler and its underlying logging configuration, such as specific log4net appenders (e.g. Windows eventlog, rolling file, SQL server, whatever), as a side effect "bleeds" its implementation out to its consumers (breaking the DRY principle). A preferred option could have the log4net IErrorHandler reach out to a single, server-wide configuration file (e.g. `log4net.config`) that defined a unifed logging configuration that would apply to all services.


{% highlight xml %}
<?xml version="1.0"?>
<configuration>
  <configSections>
    <section name="log4net" type="log4net.Config.Log4NetConfigurationSectionHandler, log4net" />
  </configSections>

  <system.serviceModel>
    <extensions>
      <behaviorExtensions>
        <add name="errorHandler" type="Net.Bencode.WCF.ErrorServiceBehavior.ErrorHandlerBehavior, ErrorHandlerBehavior, Version=1.0.0.0, Culture=neutral, PublicKeyToken=129fadf0a03f506f" />
      </behaviorExtensions>
    </extensions>
    <behaviors>
      <serviceBehaviors>
        <behavior name="">
          <serviceMetadata httpGetEnabled="true" />
          <serviceDebug includeExceptionDetailInFaults="true" />
          <errorHandler />
        </behavior>
      </serviceBehaviors>
   </behaviors>
    <serviceHostingEnvironment multipleSiteBindingsEnabled="true" />
  </system.serviceModel>

  <log4net>
    <appender name="AdoNetAppender" type="log4net.Appender.AdoNetAppender">
      <bufferSize value="100" />
      <connectionType value="System.Data.SqlClient.SqlConnection, System.Data, Version=1.0.3300.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" />
      <connectionString value="data source=.;initial catalog=LogDb;integrated security=true;persist security info=True;" />
      <commandText value="INSERT INTO Log ([Date],[Thread],[Level],[Logger],[Message],[Exception]) VALUES (@log_date, @thread, @log_level, @logger, @message, @exception)" />
      <parameter>
      <parameterName value="@log_date" />
      <dbType value="DateTime" />
      <layout type="log4net.Layout.RawTimeStampLayout" />
      </parameter>
      <parameter>
      <parameterName value="@thread" />
      <dbType value="String" />
      <size value="255" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%thread" />
      </layout>
      </parameter>
      <parameter>
      <parameterName value="@log_level" />
      <dbType value="String" />
      <size value="50" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%level" />
      </layout>
      </parameter>
      <parameter>
      <parameterName value="@logger" />
      <dbType value="String" />
      <size value="255" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%logger" />
      </layout>
      </parameter>
      <parameter>
      <parameterName value="@message" />
      <dbType value="String" />
      <size value="4000" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%message" />
      </layout>
      </parameter>
      <parameter>
      <parameterName value="@exception" />
      <dbType value="String" />
      <size value="2000" />
      <layout type="log4net.Layout.ExceptionLayout" />
      </parameter>
    </appender>
    <root>
      <!-- OFF, FATAL, ERROR, WARN, DEBUG, INFO, ALL -->
      <level value="ALL" />
      <appender-ref ref="AdoNetAppender" />
    </root>
  </log4net>
</configuration>
{% endhighlight %}
