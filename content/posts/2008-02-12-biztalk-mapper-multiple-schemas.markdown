---
layout: post
title: "BizTalk Mapper Multiple Schemas"
date: "2008-02-12 22:38:09"
comments: false
categories:
- biztalk
---


Today I was preparing to do some maintenance work, and while studying the relevant maps and schemas discovered a very unusual looking map—unusual to me anyway. I have included the XML source definition of the map below for reference. The source definition of the map was an aggregation of two schemas. That is, the source definition had two root elements `InputMessagePart_0` and `InputMessagePart_1` which contained XSD imports of two schemas. The thing that took me by surprise was that the source definition of this particular map was not actually explicitly defined through a "wrapping" schema definition. Instead the actual details of the aggregation was defined and stored in the map definition itself, under the target namespace of: `http://schemas.microsoft.com/BizTalk/2003/aggschema`

The only way I could work out how to get the BizTalk development tools to create an aggregated map source/destination definition, was through the orchestration designer in VS.NET. Drop in a transform shape. When configuring the transform shape ensure that the "Create New Map" option is selected, and set its source (and/or destination) to multiple (more than one) messages, click OK. BizTalk will generate the new aggregated map definition. Sweet!

    <SrcTree>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:b="http://schemas.microsoft.com/    BizTalk/2003" xmlns:ns1="http://Net.Bencode.Schema2" xmlns:ns2="http://Net.Bencode.Schema1"     xmlns:tns="http://schemas.microsoft.com/BizTalk/2003/aggschema" targetNamespace="http://schemas.    microsoft.com/BizTalk/2003/aggschema">
        <xs:import schemaLocation=".\schema1.xsd" namespace="http://Net.Bencode.Schema1" />
        <xs:import schemaLocation=".\schema2.xsd" namespace="http://Net.Bencode.Schema2" />
        <xs:element name="Root">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="InputMessagePart_0">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element ref="ns1:MyRoot" />
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
              <xs:element name="InputMessagePart_1">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element ref="ns2:MyRoot" />
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:schema>
    </SrcTree>
