---
layout: post
title: "Azure Service Bus WRAP Token Renewal"
date: "2012-02-26 08:00:00"
comments: false
categories: "Azure,ServiceBus,ACS"
---

Service Bus samples and documentation often cover how to request a token from Access Control Services via REST. Here we touch on caching said token, and consider its renewal upon expiry.

The .NET Azure Service Bus API, from the `Microsoft.ServiceBus` and `Microsoft.ServiceBus.Messaging` namespaces, provide a number of useful abstractions when developing a brokered messaging solution. The API is nice, because is lets you focus on the business problem at hand, while keeping the boilerplate, protocol related interaction nicely tucked away. Example: 

{% highlight csharp %}
var runtimeAddress = CreateServiceAddress("benjaminify"); 
var tokenProvider = TokenProvider.CreateSharedSecretTokenProvider("owner", "bPCE5jRsFh4jbenWzKZlOJhT58npvii08wgj+ndH2cg="); 
var messagingFactory = MessagingFactory.Create(runtimeAddress, token); 
var topicClient = messagingFactory.CreateTopicClient("FooTopic"); 
topicClient.Send(brokeredMessage); 
{% endhighlight %}

Now when it comes to using to the REST API, which (as REST intends to) opens up potential service bus consumers/publishers to literally any platform (WP7, Linux, OSX, etc) or language (ruby, C++, python, pre .NET 4.0, etc) , that supports a basic HTTP stack. However, with this, we loose the abstracted (i.e. take care of it for me) approach to dealing with the service bus. There are two fantastic resources in regards to getting started with the REST API. First the offical Azure Service Bus REST API document. Second the Silverlight samples provide fully functional peek-lock REST implementation. Third enable Fiddler2 for SSL; tracing conversations between ACS and the Service Bus has been invaluable and saved me hours of diagnostics. 

One particular area that requires some thought that I have found that samples don’t address, is around token management. The samples do a great job highlighting how to obtain a WRAP token, something similar to this does the trick: 


{% highlight csharp %}
headers = new NameValueCollection(); 
headers.Add("wrap_name", "owner"); 
headers.Add("wrap_password", "bPCE5jRsFh4jbenWzKZlOJhT58npvii08wgj+ndH2cg="); 
headers.Add("wrap_scope", "http://yournamespace.servicebus.windows.net/"); 
byte[] response = webClient.UploadValues("https://yournamespace-sb.accesscontrol.windows.net/WRAPv0.9/", headers); 
string responseString = Encoding.UTF8.GetString(response); 
var responseProperties = responseString.Split('&'); 
var tokenProperty = responseProperties[0].Split('='); 
var token = Uri.UnescapeDataString(tokenProperty[1]); 
var wrapToken = "WRAP access_token=\"" + token + "\""; 
{% endhighlight %}

There after, any communication that takes place with the Service Bus needs to present this WRAP token by stuffing it into the Authorization HTTP request header. 
For reference, here is a WRAP token response from ACS. This particular token asserts the Listen, Manage and Send claims for interacting the with "footopic" Service Bus Topic. 

    HTTP/1.1 200 OK 
    Cache-Control: private 
    Content-Type: application/x-www-form-urlencoded; charset=us-ascii 
    Server: Microsoft-IIS/7.5 
    Set-Cookie: ASP.NET_SessionId=sewfhywfjcb4gb5v54ematrj; path=/; HttpOnly 
    X-AspNetMvc-Version: 2.0 
    X-AspNet-Version: 4.0.30319 
    X-Powered-By: ASP.NET 
    X-Content-Type-Options: nosniff 
    Date: Sun, 26 Feb 2012 07:12:42 GMT 
    Content-Length: 568 
    
    wrap_access_token=net.windows.servicebus.action%3dListen%252cManage%252cSend%26http%253a%252f%252fschemas.microsoft.com%252faccesscontrolservice%252f2010%252f07%252fclaims%252fidentityprovider%3dhttps%253a%252f%252fyournamespace-sb.accesscontrol.windows.net%252f%26Audience%3dhttp%253a%252f%252fyournamespace.servicebus.windows.net%252ffootopic%252fSubscriptions%252f9999967%26ExpiresOn%3d1330241562%26Issuer%3dhttps%253a%252f%252fyournamespace-sb.accesscontrol.windows.net%252f%26HMACSHA256%3diLwSBitfc7QnA6A7afOGqfaAtJkr8q7Bv9cgilGs9jk%253d&wrap_access_token_expires_in=1199 


Now we have a token, how long is it valid for? 

`wrap_access_token_expires_in=1199`

1199 is time in seconds, which is about 20 minutes. So to prevent having to make an ACS call everytime your code exchanges messages with the service bus some sort of caching strategy is recommended. It would be difficult/inaccurate at best to implement some sort of client side timer that determines how much more of the 20 minute window remains. A more robust way that we have used successfully, is to continue optimistically re-using the token, until the service bus yells at you (i.e. an HTTP Unauthorized or a 401) stating the token is no longer valid. 

Here's a sample topic send operation, when the token is still valid (this same token will work for about 20 minutes). 

### HTTP Request: 

    POST https://yournamespace.servicebus.windows.net/customerfeedbacktopic/messages?timeout=60 HTTP/1.1 
    Authorization: WRAP access_token="net.windows.servicebus.action=Listen%2cManage%2cSend&http%3a%2f%2fschemas.microsoft.com%2faccesscontrolservice%2f2010%2f07%2fclaims%2fidentityprovider=https%3a%2f%2fyournamespace-sb.accesscontrol.windows.net%2f&Audience=http%3a%2f%2fyournamespace.servicebus.windows.net%2fcustomerfeedbacktopic&ExpiresOn=1330241633&Issuer=https%3a%2f%2fyournamespace-sb.accesscontrol.windows.net%2f&HMACSHA256=v7qXHakeLV6Jsz3mNyE2aZxu3k4TD70Rpa9pm3MmcII%3d" 
    Host: yournamespace.servicebus.windows.net 
    Content-Length: 54 
    Expect: 100-continue 
    Connection: Keep-Alive 
    
    <foo targetNamespace="http://dummy/test/1.0/"></foo> 

### HTTP Response: 

    HTTP/1.1 201 Created 
    Transfer-Encoding: chunked 
    Content-Type: application/xml; charset=utf-8 
    Server: Microsoft-HTTPAPI/2.0 
    Date: Sun, 26 Feb 2012 07:33:24 GMT 
    
    0 

However, if the ACS WRAP token has expired, the Service Bus will bork with an HTTP 401. 

### HTTP Request: 

    POST https://yournamespace.servicebus.windows.net/customerfeedbacktopic/messages?timeout=60 HTTP/1.1 
    Authorization: WRAP access_token="net.windows.servicebus.action=Listen%2cManage%2cSend&http%3a%2f%2fschemas.microsoft.com%2faccesscontrolservice%2f2010%2f07%2fclaims%2fidentityprovider=https%3a%2f%2fyournamespace-sb.accesscontrol.windows.net%2f&Audience=http%3a%2f%2fyournamespace.servicebus.windows.net%2fcustomerfeedbacktopic&ExpiresOn=1330241633&Issuer=https%3a%2f%2fyournamespace-sb.accesscontrol.windows.net%2f&HMACSHA256=v7qXHakeLV6Jsz3mNyE2aZxu3k4TD70Rpa9pm3MmcII%3d" 
    Host: yournamespace.servicebus.windows.net 
    Content-Length: 54 
    Expect: 100-continue 
    Connection: Keep-Alive 
    
    <foo targetNamespace="http://dummy/test/1.0/"></foo> 

### HTTP Response: 

    HTTP/1.1 401 Unauthorized 
    Transfer-Encoding: chunked 
    Content-Type: application/xml; charset=utf-8 
    Server: Microsoft-HTTPAPI/2.0 
    Date: Sun, 26 Feb 2012 07:41:03 GMT 
    
    A5 
    <Error><Code>401</Code><Detail>ExpiredToken: The token is expired..TrackingId:16ed6fad-77ab-4c16-b4c3-9d92e021e037_15,TimeStamp:2/26/2012 7:41:03 AM</Detail></Error> 
    0 

In the event of this particular HTTP 401 when dealing with the Azure Service Bus using REST, your code should be prepared to reach out to ACS again to ask for a freshly baked token. 

