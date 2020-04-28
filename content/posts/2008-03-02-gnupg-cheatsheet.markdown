---
layout: post
title: "GnuPG"
slug: "gpg"
date: "2008-03-02 17:16:07"
lastmod: "2020-04-11 13:19:50"
comments: false
categories:
- nix
- security
---

This semester I have enrolled in a [security unit](http://www.canberra.edu.au/courses/index.cfm?action=detail&subjectid=6697&year=2008) at my local University. Before we get into the mechanics of modern security techniques (mathematical theory, ciphers, protocols, hashing, Kerberos), the first lecture kicked off with a gentle overview of PKI and the basics of using the [GNU Privacy Guard](http://gnupg.org/), aka GnuPG or GPG for short. In short it is a complete and free implementation of the OpenPGP standard.

Generate a key pair:

    gpg --gen-key

List public keys in long format, for a particular recipient:

    $ gpg --keyid-format long --list-keys ben@bencode.net
    pub   rsa4096/B89B4DED12CAC26E 2019-05-17 [SC]
          Key fingerprint = C8E1 7FE7 C3B4 96C8 B6E1  A47E B89B 4DED 12CA C26E

Encrypt file:

    gpg --armor --output Example.txt.gpg --recipient "Charlie Brown" --encrypt Example.txt
    gpg -a -r "Charlie Brown" -e Example.txt

Decrypt file:

    gpg --output ExampleDecrypted.txt --decrypt Example.txt.gpg
    gpg -d Example.txt.gpg

To export a public key:

    gpg --export --armor "Charlie Brown" > CharliePublic.key

Import public key:

    gpg --import Alice.key

Delete a public key:

    gpg --delete-key "Charlie Brown"

To export a private key:

    gpg --export-secret-key --armor "Charlie Brown" > CharliePrivate.key

To import a private key:

    gpg --allow-secret-key-import --import CharliePrivate.key

Delete a private key:

    gpg --delete-secret-key "Ben Simmonds"

Sign a message:

    gpg --output ExampleSigned.txt --clearsign Example.txt

Verify the message:

    gpg --verify ExampleSigned.txt

Encrypt and sign a message simultaneously:

    gpg --armor --output ExampleSignedEncrypted.txt --recipient "Charlie Brown" --encrypt --sign Example.txt

Decrypt and verify the encrypted and signed message:

    gpg --output ExampleDecryptedVerified.txt --decrypt ExampleSignedEncrypted.txt

Create a detached signature:

    gpg --armor --output ExampleDetachedSignature.txt --detach-sig Example.txt

Verify the detached signature for a given file:

    gpg --verify ExampleDetachedSignature.txt Example.txt

Generate a list of numbers that can be used to verify public keys:

    gpg --fingerprint > Fingerprints.txt




## Publishing keys


It possible to register your key with a public PGP key server, so that others can retrieve your key without having to contact you directly.

To share a public key, you'll need the longid for it:

    gpg --list-keys --keyid-format=LONG ben@bencode.net
    pub   rsa4096/B89B4DED12CAC26E 2019-05-17

Now to publish it:

    gpg --send-keys B89B4DED12CAC26E

To query the key server:

    gpg --search-keys ben@bencode.net

To import a key from the key server:

    gpg --recv-keys B89B4DED12CAC26E


### Web Key Directory (WKD)

The Web Key Service (WKS) protocol is a new standard for key distribution, where the email domain provides its own key server called Web Key Directory (WKD). When encrypting to an email address (e.g. user@example.com), GnuPG (>=2.1.16) will query the domain (example.com) via HTTPS for the public OpenPGP key if it’s not already in the local keyring. Note that the option `auto-key-locate` must contain wkd.

GnuPG comes with the `gpg-wks-client` program, which can given a list of public keys from a kering, can generate a local file structure that conforms to this standard.

    gpg --list-options show-only-fpr-mbox -k "@bencode.net" | gpg-wks-client -v --install-key

Running this in the `static` directory of my hugo site:

    openpgpkey
    └── bencode.net
        ├── hu
        │   └── qpui546ptjbsz3rqaetbdz8wj9op6nur
        └── policy


Get gpg to use wkd as a means of obtaining a public key, like so:

    gpg --recipient ben@bencode.net --auto-key-locate local,wkd --encrypt wifi



