---
layout: post
title: "DVD backups on GNU/Linux"
draft: true
slug: "dvdbaks"
date: "2022-01-21 16:44:23"
lastmod: "2022-01-21 16:44:26"
comments: false
categories:
    - life
tags:
    - nerd
    - movies
    - linux
---

This is how I like to backup my old physical DVD collection which I own legitimately. I don't condone piracy or theft.

# Backup instructions

1. Rip physical DVD media `makemkv`
1. Transcode `mkv` to `m4v` container using _Fast 1080p30_ preset in handbrake. Passthrough UTF-8 subtitles if you like those.
1. Copy to media backup server `rsync --protect-args -av --progress Season8 "shnerg@172.16.1.32:/data/TV/Penn & Teller Bullshit/"`

# Software

-   [MakeMKV](https://forum.makemkv.com/forum/viewtopic.php?f=3&t=224) transcoder that deals with proprietary (and usually encrypted) disc into a set of MKV files
-   [Handbrake](https://handbrake.fr/) general video transcoder

The C source is available as tarballs `makemkv-bin-1.16.5.tar.gz` and `makemkv-oss-1.16.5.tar.gz`. The Linux release includes full source code for MakeMKV GUI, libmakemkv multiplexer library and libdriveio MMC drive interrogation library.

You'll need the GNU compile and linker, header and library files for following libraries: `glibc`, `openssl-0.9.8`, `zlib`, `expat`, `libavcodec` and `qt5`. You may use the following command to install all prerequisites on Debian-based system:

```
sudo apt-get install build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev
```

Unpack both tarballs. Starting with `makemkv-oss` (source code):

```shell
./configure
make
sudo make install
```

For the `makemkv-bin` package:

```shell
make
sudo make install
```

The application will be installed as `/usr/bin/makemkv`

## Optional: Build with latest libavcodec

Starting with version 1.8.6 MakeMKV links directly to `libavcodec`. Please note that most distributions ship a very outdated version of `libavcodec` (either from `ffmpeg` or `libav` projects). You will have to compile a recent `ffmpeg` (at least 2.0) if you need a FLAC encoder that handles 24-bit audio. You will have to enable `libfdk-aac` support in `ffmpeg` in order to use AAC encoder. Starting from version 1.12.1 DTS-HD decoding is handled by `ffmpeg` as well, so you would need a recent one. Here are generic instructions for building `makemkv-oss` with latest ffmpeg:

1. Download ffmpeg tarball from https://ffmpeg.org/download.html
1. Configure and build ffmpeg

```shell
./configure --prefix=/tmp/ffmpeg --enable-static --disable-shared --enable-pic
```

Or with libfdk-aac support:

```shell
./configure --prefix=/tmp/ffmpeg --enable-static --disable-shared --enable-pic --enable-libfdk-aac
```

Followed by a cheeky `make install`.

Configure and build makemkv-oss:

```shell
PKG_CONFIG_PATH=/tmp/ffmpeg/lib/pkgconfig ./configure
make
sudo make install
rm -rf /tmp/ffmpeg
```
