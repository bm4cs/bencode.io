---
layout: post
title: "Client certificate authentication"
draft: false
date: "2021-09-10 17:49:22"
lastmod: "2021-09-10 17:49:22"
comments: false
categories:
  - webdev
tags:
  - keycloak
  - x509
  - certificates
  - ssl
  - tls
---

> _Client Certificate Authentication_ is a mutual certificate based authentication. The client provides its certificate to the server to prove its identity, and occurs as an optional part of the TLS handshake.

My end game to is to be doing OAuth/OIDC JWT tokens with my React app, which will delegate the authentication concerns to Keycloak. Keycloak will be responible for evaluating the client certifcate when performing authentication of the client.

# Test setup

## Step 1: Cook up certificates

On Windows, with need to create a self-signed root and client certificates.

First the root:

```
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=EvilCorpRoot" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign
```

Then the client certificate:

```
New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=Benjamin S" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=benjamins@evilcorp.com") -KeyUsage DigitalSignature
```

These should now appear in the Windows Certificate Hive in `certmgr.msc`

## Step 2: Configure Create React App (CRA) toolchain to use HTTPS

Given this style of authentication completely hinges on SSL/TLS, the local node server used by CRA needs to do `https`.

This turns out to be [easy](https://create-react-app.dev/docs/using-https-in-development/).

In Powershell:

```
($env:HTTPS = "true") -and (npm start)
```

## Step 3: Configure Keycloak to use HTTPS

As per the [DockerHub docs](https://hub.docker.com/r/jboss/keycloak/), mount in `tls.crt` and `tls.key` into the `/etc/x509/https` directory.

> The keycloak image allows you to specify both a private key and a certificate for serving HTTPS over port 8443

The docker image will automatically pack them into a `jks` (Java keystore), and configure the wildfly Java EE container to use it.

An example OpenSSL configuration for TLS:

```
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=AU
CN=keycloak.evilcorp.com

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = keycloak.evilcorp.com
DNS.2 = keycloak
```

Either create self-signed (for testing only):

```
openssl req -config keycloak.csr.conf -new -x509 -sha256 -newkey rsa:2048 -nodes \
    -keyout keycloak.key -days 365 -out keycloak.crt
```

Or a certificate signing request (for production):

````
openssl req -config keycloak.csr.conf -new -sha256 -newkey rsa:2048 -nodes \
    -keyout keycloak.key -days 365 -out keycloak.csr
```

Next bind mount these into the container either kubernetes or `docker-compose`. The doc has a small note, the key needs to be world readable.

```yml
keycloak:
  image: jboss/keycloak
  container_name: keycloak
  volumes:
    - ./containers/keycloak/realm.json:/tmp/realm.json
    - ./containers/keycloak/keycloak.crt:/etc/x509/https/tls.crt
    - ./containers/keycloak/keycloak.key:/etc/x509/https/tls.key
  environment:
    KEYCLOAK_USER: admin
    KEYCLOAK_PASSWORD: password
    KEYCLOAK_IMPORT: /tmp/realm.json
    NO_PROXY: 127.0.0.1, localhost
    DB_VENDOR: h2
  ports:
    - "8443:8443"
  networks:
    - dam
```

