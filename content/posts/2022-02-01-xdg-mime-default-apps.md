---
layout: post
title: "Default programs based on MIME type with XDG"
slug: "xdgmime"
date: "2022-02-01 18:12:29+11:00"
lastmod: "2022-02-01 18:12:38+11:00"
comments: false
categories:
    - linux
tags:
    - arch
    - linux
---

From an ancient post I previously did...I need to refresh my mind on this topic often enough thought it worthy of breaking it out.

## How Linux systems figure out what program should open a file

Programs that handle arbitrary files (e.g. web browsers, irc clients, file managers) delegate to a general purpose resource handler. _XDG MIME Applications_ is the ubiquitous option here, and is not only an implementation, but a full blown specification.

## Querying the defaults you have

To check a default program to be used based on MIME type:

```shell
xdg-mime query default text/plain
```

Or, if unsure of the MIME type, to check a default program based on a sample input file:

```shell
xdg-mime query filetype 2016-01-12-jdbc-overflow.markdown
```

## Setting new defaults

To set a default handler, the program needs a, the program needs a `.desktop` launcher. First make sure one exists:

```shell
$ locate -i nvim.desktop
/usr/share/applications/nvim.desktop
```

Then bind it as the default for a given file (MIME) type:

```shell
xdg-mime default nvim.desktop text/plain
```

Test it out:

```shell
xdg-open 2018-01-08-pki.markdown
```

## Managing explicit mappings with mimeapps.list

Custom handler MIME mappings are stored in `~/.local/mimeapps.list` (Arch) or `~/.local/share/applications/mimeapps.list` (Debian).

Its worth mentioning `/usr/share/applications/mimeinfo.cache`, which is a raw reverse cache for the `.desktop` information. If `xdg-mime` fails lookup an explicit MIME type entry in a `mimeapps.list`, it will fallback to this cache. There is no way to define priorities in it, so get in the habbit of maintaining a neat little `mimeapps.list` as part of your dotfiles repo.

## Working example

I discovered a neat pattern looking at the HexDSl's awesome [dots](https://git.hexdsl.co.uk/HexDSL/dots) repo. He creates agnostic desktop file based on type, such as `pdf.desktop`. As time moves on and you may want to change your default PDF viewer, there is one clean place to do it in. Similarly create `images.desktop`, `text.desktop`, `torrent.desktop` and so on.

See my dots repo [.local/share/applications](https://github.com/bm4cs/dots/tree/master/.local/share/applications) for a working example.
