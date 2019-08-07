---
layout: post
title: "ESB Guidance - Dynamic Resolution"
date: "2008-09-10 21:48:23"
comments: false
categories: BizTalk
---


The goal of dynamic resolution is to avoid defining end-points anywhere statically. The responsibility of carrying and managing this knowledge, which is specific to the interaction, is frequently given to the consumer. That is, the consumer statically binds to the service endpoint/s that is consumes. If the responsibility be lifted from the consumer (or providers) itself, and given to an intermediate layer, such as the ESB, the byproduct are mechanisms for coping with change and dealing with infrastructural complexity. While the concept may appear to be trivial, its contribution toward providing a more managed distributed environment (many interacting end-points and data exchanges, etc) is significant.

The key challenge to a real world dynamic resolution implementation, is achieving the dynamic (i.e. must not static) characteristic. The ESB guidance provides this capability by providing an extensible resolver framework. The framework can be exposed or extended in anyway that is seen fit. The resolution functionality can easily be consumed in-band directly (i.e. without going out of process) or remotely through a WCF service. The point is, the framework is very extensible and flexible.

Out of the box, five resolver implementations are provided. An overview of these can be found by reviewing the ESBProcessor/Resolver section of the `machine.config`.


    <ESBProcessor>
      <Resolver>
        <add key="UDDI"  value="Microsoft.Practices.ESB.Resolver.UDDI" />
        <add key="WSMEX" value="Microsoft.Practices.ESB.Resolver.WSMEX" />
        <add key="XPATH" value="Microsoft.Practices.ESB.Resolver.XPATH" />
        <add key="STATIC" value="Microsoft.Practices.ESB.Resolver.STATIC" />
        <add key="BRE"  value="Microsoft.Practices.ESB.Resolver.BRE" />
      </Resolver>
     ...


The bridging between the resolver framework and BizTalk Server is achieved through the ESBReceiveXML pipeline. The ESBReceiveXML pipeline is what makes doing transformation, endpoint resolution and validation truly dynamic. The pipeline offers a set of runtime configurable properties (see below figure of the ESBReceiveXML Pipeline Properties).

- EndPoint: a directive for the resolution framework.  
- MapName: the transform to be applied to the message.  
- Validate

*Note* the `ESBReceiveXML` functionality is also provided by the more powerful `ItineraryReceiveXML` pipeline. Further discussion of the `ItineraryReceiveXML` pipeline will be covered in a future post on Itinerary Processing.

![ESBReceiveXML Pipeline Properties](/images/esb_receive_xml.png)


The following snippet is a sample endpoint property configuration, for doing outbound file delivery using the STATIC resolver.

    STATIC:\\TransportType=;
    TransportLocation=FILE://C:\Projects\Microsoft.Practices.ESB\Source\Samples\DynamicResolution\Test\Filedrop\OUt\%MessageID%.xml;
    Action=;
    EndpointConfig=;
    JaxRpcResponse=false;
    MessageExchangePattern=;
    TargetNamespace=;
    TransformType=;


Note from the above EndPoint configuration, that the following context properties are resolved and associated with the message as a result.


    <MessageInfo>
      <ContextInfo PropertiesCount="26">
        <Property Name="PortName" Value="DynamicResolution" />
        <Property Name="InboundTransportLocation" Value="C:\Projects\Microsoft.Practices.ESB\Source\Samples\DynamicResolution\Test\Filedrop\in\*.xml" />
        <Property Name="ReceiveInstanceID" Value="{953F22D3-EE1A-4B67-ADC1-46FAB6F4562B}" />
        <Property Name="ReceiveLocationName" Value="DynamicResolution_FILE" />
        <Property Name="ReceivePortID" Value="{FA180F02-2C74-4CB5-AC62-D1DBF928288E}" />
        <Property Name="ReceivePortName" Value="DynamicResolution" />
        <Property Name="InboundTransportType" Value="FILE" />
        <Property Name="MessageExchangePattern" Value="1" />
        <Property Name="OutboundTransportLocation" Value="FILE://C:\Projects\Microsoft.Practices.ESB\Source\Samples\DynamicResolution\Test\Filedrop\OUt\%MessageID%.xml" />
        <Property Name="MessageType" Value="http://globalbank.esb.dynamicresolution.com/northamericanservices/#OrderDoc" />
        <Property Name="OutboundTransportType" Value="FILE" />
      </ContextInfo>
    </MessageInfo>


As shown in the above snippet, the `ESBReceiveXML` pipeline promotes the necessary properties to facilitate a dynamic send port to pickup (subscribe) and deliver the message.

Now that the necessary resolution components have been summarised, the following steps trhough the sequence of activities involved in setting up.

- Create and build off your assemblies with the necessary BizTalk artefacts—there will be message schemas and optionally maps.  
- Deploy assemblies to a (new or existing) BizTalk application.  
- Define a new receive port and receive location. Depending on the requirements of the consumer, this may be a one-way or solicit-response flavoured port.  
- Configure the receive location to use ESBReceiveXML pipeline. Define its EndPoint, MapName (optional) and Validate (optional) properties.  
- Ensure that the necessary configuration/resources have been deployed, based on the resolver configuration you have defined. For example if you have defined an EndPoint of `BRE:\\policy=GetCanadaEndPoint;version=;useMsg=;` a working version of the GetCanadaEndPoint rule policy must be deployed the Business Rules Engine.  
- Define a dynamic send port. The flavour of receive location defined in step 3 (above) will determine the type (i.e. one way or solicit response) of send port selected here. Based on the resolver you have selected, and end-point metadata that has been provided selected properties will be promoted into the messages context. Depending on the requirements of the consumer, this may be a one-way or solicit-response flavoured port.
 

### Port Relationships

The interaction between receive and send ports here is important to the concepts’ implementation. The dynamic resolution setup walked through here, as the name implies, is very dynamic in nature. Key mechanisms that make this possible include:

- Statically defined receive location,  
- The ESBReceiveXML receive pipeline,  
- The underlying resolution framework and services,  
- Runtime configurable metadata stores (e.g. UDDI, business rules engine, content based resolution, etc),  
- Dynamic send ports.

End-point interaction can be performed using the request-and-forward (i.e. one way) or the request-response (i.e. bi-directional) models. The sequencing of the interaction between an inbound request-response receive location and an outbound solicit-response send port is important to the implementation, and for completeness is considered below:

- Request-response receive adapter through some means (e.g. HTTP, SOAP, WCF) obtains a message,  
- Receive port runtime pushes the request payload through ESBReceiveXML pipeline,  
- ESBReceiveXML promotes the necessary routing properties into the messages context,  
- Dynamic send port subscription fires based on the promoted context properties, and the needed send adapter is resolved  
- Send port runtime pushes the request payload through the PassThruTransmit pipeline,  
- Send port adapter through some means invokes external resource,  
- Send port runtime receipts a response from external resource,  
- The send port solicit-response runtime pushes the response payload through XMLReceive pipeline,  
- The XMLReceive pipeline promotes the necessary routing properties into the response messages’ context,  
- The subscription for the response operation on the original request-response receive location fires,  
- The request-response receive port runtime pushes the response payload through PassThruTransmit pipeline,  
- The request-response receive adapter through some means (e.g. HTTP, SOAP, WCF) returns the response message back to the initiating consumer.

![Request-Response Solicit-Response Pipeline Interaction shown with HAT](/images/hat_esb.png)

