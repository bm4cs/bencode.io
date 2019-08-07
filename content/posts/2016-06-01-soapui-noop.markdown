---
layout: post
title: "soapUI mock bug"
date: "2016-06-01 20:57:10"
comments: false
categories: "Geek"
---

Today I stumbled onto interesting soapUI quirk, involving a combination of mock services, SOAP 1.2 and multipart message definitions.

In essence, the soapUI mock service will always return an HTTP 500, with the following response:

{% highlight xml %}
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <soap:Fault>
      <soap:Code>
        <soap:Value>Server</soap:Value>
      </soap:Code>
      <soap:Reason>
        <!--1 or more repetitions:-->
        <soap:Text xml:lang="en">Missing operation for soapAction [http://services.net.bencode/wsdl/2016/06/01/retrievecoolnesslevelrequest] and body element [{http://services.net.bencode/wsdl/2016/06/01}retrieveCoolnessLevelRequest] with SOAP Version [SOAP 1.2]</soap:Text>
      </soap:Reason>
    </soap:Fault>
  </soap:Body>
</soap:Envelope>
{% endhighlight %}

Sigh.

Thankfully some legend known as fyerf posted a solution on the [smartbear community forums](https://community.smartbear.com/t5/SoapUI-Open-Source/R-Missing-operation-for-soapAction-and-body-element-moc/td-p/38006).

It turns out the soapUI isn't so clever when it comes to parsing multipart message definitions, such as:

{% highlight xml %}
<wsdl:input name="retrieveCoolnessLevelRequest">
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="securityHeader" use="literal" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaActionHeader" use="literal" wsdl:required="true" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaMessageIDHeader" use="literal" wsdl:required="true" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaToHeader" use="literal" wsdl:required="true" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="auditHeader" use="literal" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="subjectIdHeader" use="literal" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="metaHeader" use="literal" />
  <s:body parts="request" use="literal" />
</wsdl:input>
{% endhighlight %}

Take note of the placement of the `<s:body>` in the `<wsdl:input>`...its sitting at the bottom, beneath the other part definitions. So what? Well it turns out soapUI's mock generator goes insane with this.

It expects the `body` part to be declared and bound first, in order for it to construct the mock correctly. To help it out, move it to the top, like this:

{% highlight xml %}
<wsdl:input name="retrieveCoolnessLevelRequest">
  <s:body parts="request" use="literal" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="securityHeader" use="literal" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaActionHeader" use="literal" wsdl:required="true" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaMessageIDHeader" use="literal" wsdl:required="true" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaToHeader" use="literal" wsdl:required="true" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="auditHeader" use="literal" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="subjectIdHeader" use="literal" />
  <s:header message="tns:retrieveCoolnessLevelRequestInMsg" part="metaHeader" use="literal" />
</wsdl:input>
{% endhighlight %}

And the mock should start behaving as expected.


Here's my complete WSDL definition that triggered this behaviour (exluding schema includes).

### coolservice.v20160601.binding.wsdl ###

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<!--
/**
  *============================================================================
  * Service Description  
  * @name:      coolservice.v20160601.binding.wsdl
  * @security:  WS-Security signatures
  * @wsdlsoap:  SOAP1.2
  * @artifact:  COOLSVCv20160601
  * @target:    2016R2
  *****************************************************************************
  * @author:    Ben Simmonds
  * @version:   v20160601
  * @since:     2001/01/11
  *============================================================================
  */
-->
<wsdl:definitions xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
  xmlns:wsdlsoap="http://schemas.xmlsoap.org/wsdl/soap12/"
  xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy"
  xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
  xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl"
  xmlns:sp="http://docs.oasis-open.org/ws-sx/ws-securitypolicy/200702"
  xmlns:tns="http://services.net.bencode/wsdl/2016/06/01"
  targetNamespace="http://services.net.bencode/wsdl/2016/06/01"
  name="COOLSVCv20160601">

  <wsdl:import namespace="http://services.net.bencode/wsdl/2016/06/01" location="coolservice.v20160601.interfaces.wsdl" />
  <wsdl:binding name="COOLSVCv20160601SOAP12Binding" type="tns:COOLSVCv20160601PortType">
    <wsdlsoap:binding style="document" transport="http://schemas.xmlsoap.org/soap/http" />
    <wsp:Policy wsdl:required="true">
      <wsp:ExactlyOne>
        <wsp:All>
          <wsaw:UsingAddressing />
        </wsp:All>
      </wsp:ExactlyOne>
    </wsp:Policy>
    <wsdl:operation name="retrieveCoolnessLevel">
      <wsdlsoap:operation soapAction="" style="document" />
      <wsp:Policy wsdl:required="true">
        <wsp:ExactlyOne>
          <wsp:All>
            <wsp:Policy>
              <sp:SupportingTokens>
                <wsp:All>
                  <sp:UsernameToken sp:IncludeToken="http://docs.oasis-open.org/ws-sx/ws-securitypolicy/200702/IncludeToken/AlwaysToRecipient">
                    <wsp:Policy>
                      <sp:HashPassword />
                    </wsp:Policy>
                  </sp:UsernameToken>
                  <sp:IncludeTimestamp />
                </wsp:All>
              </sp:SupportingTokens>
            </wsp:Policy>
          </wsp:All>
        </wsp:ExactlyOne>
      </wsp:Policy>
      <wsdl:input name="retrieveCoolnessLevelRequest">
        <wsdlsoap:header message="tns:retrieveCoolnessLevelRequestInMsg" part="securityHeader" use="literal" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaActionHeader" use="literal" wsdl:required="true" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaMessageIDHeader" use="literal" wsdl:required="true" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelRequestInMsg" part="wsaToHeader" use="literal" wsdl:required="true" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelRequestInMsg" part="auditHeader" use="literal" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelRequestInMsg" part="subjectIdHeader" use="literal" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelRequestInMsg" part="metaHeader" use="literal" />
        <wsdlsoap:body parts="request" use="literal" />
      </wsdl:input>
      <wsdl:output name="retrieveCoolnessLevelResponse">
        <wsdlsoap:header message="tns:retrieveCoolnessLevelResponseOutMsg" part="wsaActionHeader" use="literal" wsdl:required="true" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelResponseOutMsg" part="wsaMessageIDHeader" use="literal" wsdl:required="true" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelResponseOutMsg" part="wsaToHeader" use="literal" wsdl:required="true" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelResponseOutMsg" part="wsaRelatesToHeader" use="literal" />
        <wsdlsoap:header message="tns:retrieveCoolnessLevelResponseOutMsg" part="metaHeader" use="literal" />
        <wsdlsoap:body parts="response" use="literal" />
      </wsdl:output>
      <wsdl:fault name="standardError">
        <wsdlsoap:fault use="literal" name="standardError" />
      </wsdl:fault>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="COOLSVCv20160601Service">
    <wsdl:port name="COOLSVCv20160601Port" binding="tns:COOLSVCv20160601SOAP12Binding">
      <wsdlsoap:address location="http://services.net.bencode/endpoint/2016/06/01" />
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
{% endhighlight %}




### coolservice.v20160601.interfaces.wsdl ###

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<!--
/**
  *============================================================================
  * Service Description  
  * @name:      coolservice.v20160601.interfaces.wsdl
  * @security:  WS-Security signatures
  * @wsdlsoap:  SOAP1.2
  * @artifact:  COOLSVCv20160601
  * @target:    2016R2
  *****************************************************************************
  * @author:    Ben Simmonds
  * @version:   v20160601
  * @since:     2001/01/11
  *============================================================================
  */
-->
<wsdl:definitions xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:wsam="http://www.w3.org/2007/05/addressing/metadata"
  xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
  xmlns:wsa="http://www.w3.org/2005/08/addressing"
  xmlns:cmn="http://schema.bencode.net/common/schema/2014/03/15/elements"
  xmlns:msg="http://schema.bencode.net/cool/messages/schema/2016/06/01"
  xmlns:tns="http://schema.bencode.net/cool/wsdl/2016/06/01"
  targetNamespace="http://schema.bencode.net/cool/wsdl/2016/06/01"
  name="COOLSVCv20160601">
  <wsdl:types>
    <xsd:schema
      targetNamespace="http://schema.bencode.net/cool/wsdl/2016/06/01"
      elementFormDefault="qualified">
      <xsd:import namespace="http://www.w3.org/2005/08/addressing"
        schemaLocation="../../schema/w3c/ws-addr-1.0.xsd" />
      <xsd:import
        namespace="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
        schemaLocation="../../schema/oasis/oasis-200401-wss-wssecurity-secext-1.0.xsd" />
      <xsd:import
        namespace="http://schema.bencode.net/common/schema/1983/03/03/elements"
        schemaLocation="../../schema/common/v19830303/Common.v19830303.xsd" />
      <xsd:import
        namespace="http://schema.bencode.net/cool/messages/schema/2016/06/01"
        schemaLocation="../../schema/cool.messages.v20160601.xsd" />
    </xsd:schema>
  </wsdl:types>
  <wsdl:message name="retrieveCoolnessLevelRequestInMsg">
    <wsdl:part name="wsaActionHeader" element="wsa:Action" />
    <wsdl:part name="wsaToHeader" element="wsa:To" />
    <wsdl:part name="wsaMessageIDHeader" element="wsa:MessageID" />
    <wsdl:part name="securityHeader" element="wsse:Security" />
    <wsdl:part name="auditHeader" element="cmn:audit" />
    <wsdl:part name="subjectIdHeader" element="cmn:subjectId" />
    <wsdl:part name="metaHeader" element="cmn:metaHeader" />
    <wsdl:part name="request" element="msg:retrieveCoolnessLevelRequest" />
  </wsdl:message>
  <wsdl:message name="retrieveCoolnessLevelResponseOutMsg">
    <wsdl:part name="wsaActionHeader" element="wsa:Action" />
    <wsdl:part name="wsaToHeader" element="wsa:To" />
    <wsdl:part name="wsaMessageIDHeader" element="wsa:MessageID" />
    <wsdl:part name="wsaRelatesToHeader" element="wsa:RelatesTo" />
    <wsdl:part name="metaHeader" element="cmn:metaHeader" />
    <wsdl:part name="response" element="msg:retrieveCoolnessLevelResponse" />
  </wsdl:message>

  <wsdl:message name="standardErrorMsg">
    <wsdl:part name="standardError" element="cmn:serviceMessages" />
  </wsdl:message>
  <wsdl:portType name="COOLSVCv20160601PortType">
    <wsdl:operation name="retrieveCoolnessLevel">
      <wsdl:input name="retrieveCoolnessLevelRequest"
        message="tns:retrieveCoolnessLevelRequestInMsg"
        wsam:Action="http://schema.bencode.net/cool/2016/06/01/retrievecoolnesslevelrequest" />
      <wsdl:output name="retrieveCoolnessLevelResponse"
        message="tns:retrieveCoolnessLevelResponseOutMsg"
        wsam:Action="http://schema.bencode.net/cool/2016/06/01/retrievecoolnesslevelresponse" />
      <wsdl:fault name="standardError" message="tns:standardErrorMsg"
        wsam:Action="http://schema.bencode.net/common/2008/05/05/standardfault" />
    </wsdl:operation>
  </wsdl:portType>
</wsdl:definitions>
{% endhighlight %}
