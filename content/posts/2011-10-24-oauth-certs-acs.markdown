---
layout: post
title: "OAuth Certificate Authentication with ACS"
date: "2011-10-24 07:00:00"
comments: false
categories: "Azure,AppFabric,ACS"
---

My experience authenticating clients with the Windows Azure AppFabric Access Control Service (ACS) using X.509 certificates.

Here's the scenario. A consumer (Alice) wants to publish a message to the Azure AppFabric Service Bus, however before doing so, somehow needs to prove that she is in fact Alice. Taking a certificate based approach, requires Alice to craft a SAML token which amoung other things states "i'm Alice" (relying party scope), and signing this token with Alice's (private key) certifcate. If Alice were to deliver this token to ACS (https://yournamespace.accesscontrol.windows.net/v2/OAuth2-13), and a relying party, rule group and service identity with Alice's public key had been configured, ACS in return would give Alice another token (a SWT token by default) signed with a specified signing key, which Alice could use from that point to prove identity.

In short, we are providing a token, with the intent of receiving another token in return. The token returned by ACS is potentially very powerful, and can be used to authorise access to resources in many downstream systems.

To establish this relationship between ACS and consumers, consumers need to have an X.509 certificate that uniquely represents them as the consumer. A self signed (makecert.exe) certificate in this instance is perfectly fine. Next the public key for this certificate needs to be exported (.cer) and provided to the ACS administrator. It's important to note here that the private key (.pfx exports contain both the private and public keys) portion of the certificate should always be kept confidential. ACS only requires a consumers' public key in order to verify their digital signature.

The OAuth sample in the OAuth2 folder for the [Access Control Service Samples and Documentation](http://go.microsoft.com/fwlink/?LinkId=213167) contains many gems for doing this. Such as crafting SAML2 tokens, and populating the necessary OAuth HTTP headers, and so on.

> This sample illustrates how to authenticate to Windows Azure AppFabric Access Control Service (ACS) using the OAuth 2.0 protocol by presenting a SAML token signed by an X.509 certificate. This certificate corresponds to a ServiceIdentity configured on ACS, and ACS issues a SWT with a nameidentifier claim of the ServiceIdentity. This SWT is used to authenticate to an OAuth 2.0 protected resource. This sample conforms to draft 13 of the OAuth 2.0 protocol.

When doing this for the first time, or when things dont work out, its awesome to be able to inspect the HTTP conversations that take place with ACS. As you would expect, ACS enforces the use of SSL. SSL tunnels present a huge problem in terms of tracing. Fiddler fortunately comes to the rescue. Fiddler works by placing itself as a man-in-the-middle proxy between the client and server, as a result it also needs to provide a certificate for SSL requests. As this is not recognized as valid certificate, .NET throws an `WebException` at `System.Net.HttpWebRequest.GetResponse()` and no traffic shows up in Fiddler. To still be able to check accuracy of the programmatic requests with Fiddler, it is possible to directly add a new delegate, which always returns true, basically disabling certificate validation from deep within the framework libraries.

To get up and running with Fiddler and SSL tracing:

*   Tools > Fiddler Options > HTTPS > Decrypt HTTPS Traffic
*   Add this line of code to the .NET code responsible for transmitting the SAML token to ACS : `ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };`

First attempt to run the code, I got a simple HTTP 400 back. Fiddler showed the following.

    HTTP/1.1 400 Bad Request
    Cache-Control: private
    Content-Type: application/json; charset=utf-8
    Server: Microsoft-IIS/7.0
    Set-Cookie: ASP.NET_SessionId=mxla1kuojr1udh0u2sho21i0; path=/; HttpOnly
    X-AspNetMvc-Version: 2.0
    x-ms-request-id: 8718c3e7-a3ee-4cf0-af1f-951a09dfd9fe
    X-AspNet-Version: 4.0.30319
    X-Powered-By: ASP.NET
    X-Content-Type-Options: nosniff
    Date: Mon, 24 Oct 2011 05:27:12 GMT
    Content-Length: 1113
    
    {"error":"invalid_grant","error_description":"ACS50008: SAML token is invalid. ACS50006: Unable to verify token signature. The following signing key identifier does not match any valid registered keys: SecurityKeyIdentifier\r\n    (\r\n    IsReadOnly = False,\r\n    Count = 1,\r\n    Clause[0] = X509RawDataKeyIdentifierClause(RawData = RAW_DATA_GOES_HERE)\r\n    )\r\n. \r\nTrace ID: 8718c3e7-a3ee-4cf0-af1f-951a09dfd9fe\r\nTimestamp: 2011-10-24 05:27:13Z"}

ACS50006: Unable to verify token signature. The following signing key identifier does not match *any valid* registered keys. The error message spells it out. ACS could not find ANY valid certificates. Using the ACS Management Portal, go to Service identities, and drill into the identity of concern. If the status of the certificate is anything but valid (e.g. because its expired, etc) you will get this error. The certificates provided for the OAuth2 sample in the Access Control Service Samples (16 May 2011 update) all expired as of  16 Sep 2011, and will result in this exact error.

![ACS will not tolerate expired certificates](http://bencode.net/get/img/expired.cert.PNG)

To get the samples working, I created my own self signed certificates.

    makecert -r -pe -n "CN=benjaminify" -b 01/01/2000 -e 01/01/2099 -eku 1.3.6.1.5.5.7.3.3 -ss My

I then exported the public key portion (`.cer`) of the certificate, using the certificate manager MMC snap-in (`certmgr.msc`).

![Export the public key portion of certificate using certmgr.msc](http://bencode.net/get/img/export.public.key.PNG)

Using the ACS Management Portal, upload the exported ".cer" against the service identity.

If everything lined up, you should get a HTTP 200 containing a SWT token in return from ACS.

    HTTP/1.1 200 OK
    Cache-Control: public, no-store, max-age=0
    Content-Type: application/json; charset=utf-8
    Expires: Mon, 24 Oct 2011 06:03:44 GMT
    Last-Modified: Mon, 24 Oct 2011 06:03:44 GMT
    Vary: *
    Server: Microsoft-IIS/7.0
    Set-Cookie: ASP.NET_SessionId=qz0cuqmk1nxt01wxehbqvq25; path=/; HttpOnly
    X-AspNetMvc-Version: 2.0
    X-AspNet-Version: 4.0.30319
    X-Powered-By: ASP.NET
    X-Content-Type-Options: nosniff
    Date: Mon, 24 Oct 2011 06:03:45 GMT
    Content-Length: 606
    
    {"access_token":"http%3a%2f%2fschemas.xmlsoap.org%2fws%2f2005%2f05%2fidentity%2fclaims%2fnameidentifier=OAuth2SampleX509Identity&http%3a%2f%2fschemas.microsoft.com%2faccesscontrolservice%2f2010%2f07%2fclaims%2fidentityprovider=https%3a%2f%2fbensimmonds.accesscontrol.windows.net%2f&Audience=https%3a%2f%2foauth2RelyingParty%2f&ExpiresOn=1319439825&Issuer=https%3a%2f%2fbensimmonds.accesscontrol.windows.net%2f&HMACSHA256=uaSF%2fojN%2f4SBQd5p1IYurRu0B5hc6Pdz4uC9ChvqFE4%3d","token_type":"http://schemas.xmlsoap.org/ws/2009/11/swt-token-profile-1.0","expires_in":"3600","scope":"https://oauth2RelyingParty/"}


As an aside, I got the following error response from ACS when I created a certificate with makecert as follows. Unlike the above working example, this will create a self-signed certificate associated with a issuer called "Root Agency". ACS will bomb out if the root issuer cannot be verified.

    makecert -n "CN=benjaminify" -pe -ss my -sr LocalMachine -sky exchange -m 96 -a sha1 -len 2048

    HTTP/1.1 400 Bad Request
    Cache-Control: private
    Content-Type: application/json; charset=utf-8
    Server: Microsoft-IIS/7.0
    Set-Cookie: ASP.NET_SessionId=hxi2tbkn404lihcndxnuka35; path=/; HttpOnly
    X-AspNetMvc-Version: 2.0
    x-ms-request-id: 00dc92c8-9a72-4f0f-8b38-c5581a5cfcc5
    X-AspNet-Version: 4.0.30319
    X-Powered-By: ASP.NET
    X-Content-Type-Options: nosniff
    Date: Mon, 24 Oct 2011 05:56:55 GMT
    Content-Length: 286
    
    {"error":"invalid_grant","error_description":"ACS50008: SAML token is invalid. ACS50017: The certificate with subject \u0027CN=benjaminify\u0027 and issuer \u0027CN=Root Agency\u0027 failed validation. \r\nTrace ID: 00dc92c8-9a72-4f0f-8b38-c5581a5cfcc5\r\nTimestamp: 2011-10-24 05:56:55Z"}

