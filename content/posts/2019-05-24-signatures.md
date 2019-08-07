---
layout: post
title: "Digital Signatures"
date: "2019-05-24 21:17:01"
comments: false
categories:
- linux
---

The sequence of tasks undertaken that make digital signatures possible. This does have a slight XML flavour to it.

> A digital signature is a mathematical scheme for verifying the authenticity of digital messages.

The concept of digital signature completely hinges on assymetric cryptography (such as DSA or RSA).


## To validate a signature

1. First the message can be normalised, and in the case of XML will use something like the "Exclusive XML Canonicalization" (XML-C14N), so we're comparing apples with apples. This will disgard things like usage of white space.
1. Using the normalised representation, compute a hash (e.g. SHA1) of the timestamp (contained WS-Security header) and entire message payload (the SOAP body).
1. Using the public key from the partner organisation certificate, RSA decrypt the hash computed by partner organisation.
1. If the two hashes are identical, we know the message has not been tampered with.
1. (optional) Validate the timestamp (TTL) defined by partner organisation (typically 7 minutes from the original transmission time by the sender). To mitigate possible damage caused by replay attacks.

## To create a signature

1. Wraps the response message in a SOAP envelope, which includes some WS-Security related headers including a timestamp.
1. The timestamp is set to a configurable number of minutes (e.g. 10 minutes) in the future.
1. Normalises the message using the "Exclusive XML Canonicalization" (XML-C14N)
1. Using the normalised message form, compute a (e.g. SHA1) hash of the timestamp (WS-Security header) and entire response message payload (e.g. the SOAP body).
1. Uses the private key of signing certificate, RSA signs the computed hash, and stores the result in the relevant security header (the SignatureValue header).
1. The message is then delivered to partner organisation.


For the above to work, there needs to be some established agreement as to the specific cipher suites and canonicalisation method used. This is all 

Sample SOAP message with a signature header entry. Source: [w3.org](https://www.w3.org/TR/2001/NOTE-SOAP-dsig-20010206/):

    <SOAP-ENV:Envelope
      xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
      <SOAP-ENV:Header>
        <SOAP-SEC:Signature
          xmlns:SOAP-SEC="http://schemas.xmlsoap.org/soap/security/2000-12"
          SOAP-ENV:actor="some-URI"
          SOAP-ENV:mustUnderstand="1">
          <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <ds:SignedInfo>
              <ds:CanonicalizationMethod   
                Algorithm="http://www.w3.org/TR/2000/CR-xml-c14n-20001026">
              </ds:CanonicalizationMethod>
              <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#dsa-sha1"/>
              <ds:Reference URI="#Body">
                <ds:Transforms>
                  <ds:Transform Algorithm="http://www.w3.org/TR/2000/CR-xml-c14n-20001026"/>
                </ds:Transforms>
                <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
                <ds:DigestValue>j6lwx3rvEPO0vKtMup4NbeVu8nk=</ds:DigestValue>
              </ds:Reference>
            </ds:SignedInfo>
            <ds:SignatureValue>MC0CFFrVLtRlk=...</ds:SignatureValue>
          </ds:Signature>
        </SOAP-SEC:Signature>
      </SOAP-ENV:Header>
      <SOAP-ENV:Body 
        xmlns:SOAP-SEC="http://schemas.xmlsoap.org/soap/security/2000-12"
        SOAP-SEC:id="Body">
        <m:GetLastTradePrice xmlns:m="some-URI">
          <m:symbol>IBM</m:symbol>
        </m:GetLastTradePrice>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>


