---
layout: post
title: "BizTalk Custom WCF Behaviour"
date: "2011-06-26 07:00:00"
comments: false
categories: "BizTalk,WCF"
---

The ability to easily implement custom processing within the WCF stack, is one of the main reasons why WCF (Windows Communication Foundation) is such a rich programming paradigm compared to other ways of communication.

WCF, when paired with BizTalk Server, opens up numerous extensibility options that were previously not possible.

A particularly useful piece of WCF extensibility, is commonly referred to as behaviors.

> Behavior extensions are one of the components that differentiate WCF from other Web services technologies in the market. By using this feature, developers can add custom extensions that inspect and validate service configuration or modify run-time behavior in WCF client and service applications. Custom behavior extensions can exist at both the WCF service and client levels. Configuring a behavior on the call stack to a WCF service has no influence on the communication binding used to make the call. In fact, behaviors are typically invisible to the client because they are not displayed in the metadata that a service publishes. The client typically has no idea that the extensions are running during a call to a WCF operation.


Behaviors are already well documented else where, so I will try keep ramble to a minimum. What follows is the code, and steps I undertook to get a custom client side (called CookieBehavior) WCF behavior working with BizTalk Server 2010. The behaviors purpose is simple, it creates a user defined (outbound) HTTP header based on a passed in context value. It also inspects the response (inbound) for another user defined HTTP header, and if it exists, writes it into the message context for consumption by BizTalk.

Create a class that inherits from IClientMessageInspector. You have the option of building a client (i.e. the service caller) or service (i.e. the service provider) facing behaviors. Since the sample behavior here is focused around calling an existing service, have chosen to implement the IClientMessageInspector interface.

{% highlight csharp %}
public class CookieInspector : IClientMessageInspector
{
  public CookieInspector(CookieBehaviorConfiguration behaviorConfiguration)
  {
    BehaviorConfiguration = behaviorConfiguration;
  }

  public CookieBehaviorConfiguration BehaviorConfiguration { get; set; }

  public void AfterReceiveReply(ref Message reply, object correlationState)
  {
    HttpResponseMessageProperty httpReplyMessage;
    object httpReplyMessageObject;

    if (reply.Properties.TryGetValue(HttpResponseMessageProperty.Name, out httpReplyMessageObject))
    {
      httpReplyMessage = httpReplyMessageObject as HttpResponseMessageProperty;

      if (false == String.IsNullOrEmpty(httpReplyMessage.Headers[BehaviorConfiguration.InboundHttpHeader]))
      {
        reply.Headers.Add(
          MessageHeader.CreateHeader(
            BehaviorConfiguration.CustomWcfHeader,
            BehaviorConfiguration.CustomWcfHeaderNamespace,
            httpReplyMessage.Headers[BehaviorConfiguration.InboundHttpHeader]));
      }
    }
  }

  public object BeforeSendRequest(ref Message request, IClientChannel channel)
  {
    HttpRequestMessageProperty httpRequestMessage;
    object httpRequestMessageObject;

    if (request.Properties.TryGetValue(HttpRequestMessageProperty.Name, out httpRequestMessageObject))
    {
      httpRequestMessage = httpRequestMessageObject as HttpRequestMessageProperty;

      int headerPosition = request.Headers.FindHeader(
        BehaviorConfiguration.CustomWcfHeader,
        BehaviorConfiguration.CustomWcfHeaderNamespace);

      if (headerPosition > 0)
      {
        string headerValue = request.Headers.GetHeader<string>(headerPosition);
        httpRequestMessage.Headers[BehaviorConfiguration.OutboundHttpHeader] = headerValue;
      }
    }

    return null;
  }
}
{% endhighlight %}


To manage the behavior's configuration (to avoid hardcoding), I am using the following.

{% highlight csharp %}
public struct CookieBehaviorConfiguration
{
  public string OutboundHttpHeader;
  public string InboundHttpHeader;
  public string CustomWcfHeader;
  public string CustomWcfHeaderNamespace;
}
{% endhighlight %}


Next, the message inspector needs to be surfaced as an endPoint behavior, through the ApplyClientBehavior method.

{% highlight csharp %}
public class CookieBehavior : IEndpointBehavior
{
  public CookieBehavior(CookieBehaviorConfiguration configuration)
  {
    BehaviorConfiguration = configuration;
  }

  public CookieBehaviorConfiguration BehaviorConfiguration { get; set; }

  public void AddBindingParameters(ServiceEndpoint serviceEndpoint, BindingParameterCollection bindingParameters) { }

  public void ApplyClientBehavior(ServiceEndpoint serviceEndpoint, ClientRuntime behavior)
  {
    behavior.MessageInspectors.Add(new CookieInspector(BehaviorConfiguration));
  }

  public void ApplyDispatchBehavior(ServiceEndpoint serviceEndpoint, EndpointDispatcher endpointDispatcher) { }

  public void Validate(ServiceEndpoint serviceEndpoint) { }
}
{% endhighlight %}



Finally, expose the endpoint behavior as an extension element. This type gives us the opportunity to convey/reflect the runtime configurable properties of the behavior.


{% highlight csharp %}
public class CookieBehaviorExtension : BehaviorExtensionElement
{
  protected override object CreateBehavior()
  {
    return new CookieBehavior(
      new CookieBehaviorConfiguration()
      {
        InboundHttpHeader = InboundHttpHeader,
        OutboundHttpHeader = OutboundHttpHeader,
        CustomWcfHeader = CustomWcfHeader,
        CustomWcfHeaderNamespace = CustomWcfHeaderNamespace
      });
  }

  public override Type BehaviorType
  {
    get { return typeof(CookieBehavior); }
  }

  [ConfigurationProperty("OutboundHttpHeader", DefaultValue = "Cookie", IsRequired = true)]
  public string OutboundHttpHeader
  {
    get { return (string)base["OutboundHttpHeader"]; }
    set { base["OutboundHttpHeader"] = value; }
  }

  [ConfigurationProperty("InboundHttpHeader", DefaultValue = "Set-Cookie", IsRequired = true)]
  public string InboundHttpHeader
  {
    get { return (string)base["InboundHttpHeader"]; }
    set { base["InboundHttpHeader"] = value; }
  }

  [ConfigurationProperty("CustomWcfHeader", DefaultValue = "Cookies", IsRequired = true)]
  public string CustomWcfHeader
  {
    get { return (string)base["CustomWcfHeader"]; }
    set { base["CustomWcfHeader"] = value; }
  }

  [ConfigurationProperty("CustomWcfHeaderNamespace", DefaultValue = "http://net.bencode/custom/properties", IsRequired = true)]
  public string CustomWcfHeaderNamespace
  {
    get { return (string)base["CustomWcfHeaderNamespace"]; }
    set { base["CustomWcfHeaderNamespace"] = value; }
  }


  private ConfigurationPropertyCollection _properties = null;

  protected override ConfigurationPropertyCollection Properties
  {
    get
    {
      if (this._properties == null)
      {
        this._properties = new ConfigurationPropertyCollection();
        this._properties.Add(new ConfigurationProperty("OutboundHttpHeader", typeof(string), "", ConfigurationPropertyOptions.IsRequired));
        this._properties.Add(new ConfigurationProperty("InboundHttpHeader", typeof(string), "", ConfigurationPropertyOptions.IsRequired));
        this._properties.Add(new ConfigurationProperty("CustomWcfHeader", typeof(string), "", ConfigurationPropertyOptions.IsRequired));
        this._properties.Add(new ConfigurationProperty("CustomWcfHeaderNamespace", typeof(string), "", ConfigurationPropertyOptions.IsRequired));
      }
      return this._properties;
    }
  }
}
{% endhighlight %}


BizTalk's WCF-Custom adapter will translate the above, to something that looks like this.

Update the `machine.config` located here `%systemroot%\Microsoft.NET\Framework\v2.0.50727\CONFIG`. The BizTalk Server 2010 Administration Console's WCF UI is based on this version of the CLR. You will now need to restart any running instances of the BizTalk Admin Console.

{% highlight xml %}
<behaviorExtensions>
 <add name="cookieInspectorProvider" type="Net.Bencode.CookieBehaviorExtension, CookieInspector, Version=1.0.0.0, Culture=neutral, PublicKeyToken=b6a222ec85726150" />
</behaviorExtensions>
{% endhighlight %}


To communicate with the custom behavior from BizTalk, I am using the WCF header context properties, which the WCF adapter make available. For example:

{% highlight csharp %}
mymsg(WCF.OutboundCustomHeaders) = "" +
  "<headers>" +
  "<Cookies xmlns=\"http://net.bencode/custom/properties\">" +
  "SharePoint" +
  "</Cookies>" + 
  "</headers>";
{% endhighlight %}


The above snippet results in this:

![Outbound Context Properties](/images/b/wcf-behavior-context-outbound.png)


The custom behavior is configured to look for a WCF header called `Cookies`. If it exists, an HTTP header called `Cookie` will be created by the behavior, resulting in this going across the wire.

![HTTP Request](/images/b/wcf-behavior-fiddler.request.png)


The service responds, with this:

![HTTP Response](/images/b/wcf-behavior-fiddler.response.png)


The custom behavior will look for a (user configured) HTTP header, in this case `Set-Cookie`. If found the value of the HTTP header is placed into a WCF header (again this is user configurable) called `Cookies`. Resulting in the following context state for the inbound reply message.

![Inbound Context Properties](/images/b/wcf-behavior-context-inbound.PNG)

