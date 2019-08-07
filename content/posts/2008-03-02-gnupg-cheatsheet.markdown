---
layout: post
title: "GnuPG Cheatsheet"
date: "2008-03-02 17:16:07"
comments: false
categories:
- biztalk
---

This semester I have enrolled in a [security unit](http://www.canberra.edu.au/courses/index.cfm?action=detail&subjectid=6697&year=2008) at my local University. Before we get into the mechanics of modern security techniques (mathematical theory, ciphers, protocols, hashing, Kerberos), the first lecture kicked off with a gentle overview of PKI and the basics of using the [GNU Privacy Guard](http://gnupg.org/), aka GnuPG or GPG for short. In short it is a complete and free implementation of the OpenPGP standard. I havent used GPG on the Windows platform before, there are win32 binaries available for download straight from the official site. Like most *NIX born software it is very portable. The binaries are happy running off a mass storage device (eg. a USB flashdrive) assuming the drive is mounted on a suitable Windows host. I hope to make PGP-based security more of apart of my day-to-day routine...im not aware of many people that use PGP compatible systems; I wonder why this is? My public key is also now available on the about page of my blog.

Generate a key pair:

    gpg --gen-key

Encrypt file:

    gpg --armor --output Example.txt.gpg --recipient "Charlie Brown" --encrypt Example.txt<br>gpg -a -r "Charlie Brown" -e Example.txt

Decrypt file:

    gpg --output ExampleDecrypted.txt --decrypt Example.txt.gpg<br>gpg -d Example.txt.gpg

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

    gpg --armor --output Exa mpleDetachedSignature.txt --detach-sig Example.txt

Verify the detached signature for a given file:

    gpg --verify ExampleDetachedSignature.txt Example.txt

Generate a list of numbers that can be used to verify public keys:

    gpg --fingerprint > Fingerprints.txt

