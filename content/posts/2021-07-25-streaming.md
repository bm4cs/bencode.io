---
layout: post
title: "Linux Minimal Streaming"
draft: true
slug: "streaming"
date: "2021-07-26 21:17:48"
lastmod: "2021-07-26 21:17:46"
comments: false
categories:
    - linux
tags:
    - debian
---

# Blue Yeti Nano

An amazing microphone. Best feature, it *just works* on Linux.

One minor issue, if the sampling rate and number of channels is not correctly configured, the button on the front will flash yellow. In my case when this happened, the system mixer could no longer output sound through the Yeti Nano's built-in headphone jack.

Thankfully, aligning the sampling settings in PulseAudio to that of the Blue Yeti Nano (48Khz 2 channels) fixed these issues.

```
sudo vim /etc/pulse/daemon.conf
```

I dropped in the following lines:

```
default-sample-rate = 48000
default-sample-channels = 2
```

Then killed pulseaudio with `pulseaudio -k` and restarted the daemon with `pulseaudio -D`


