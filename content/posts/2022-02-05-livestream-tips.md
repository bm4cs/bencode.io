---
layout: post
draft: true
title: "Livestream tips"
slug: "livestream"
date: "2022-02-05 21:59:47T11:00"
lastmod: "2022-02-05 21:59:54T11:00"
comments: false
categories:
    - streaming
tags:
    - linux
    - streaming
    - rode
    - webcam
    - microphone
---

# Livestream tips

Basic rig based on [jonhoo](https://thesquareplanet.com/blog/livestream-tips/)

## Software

- OBS Studio
- restream.io
- MyPaint
- `dwm`
- `pulsemixer`

## Hardware

- Nano Shield 1080p webcam
- RØDE Podcaster microphone
- RØDE PSA1 mic boom arm
- RØDE PSM1 shock mount
- Huion H640P drawing tablet

## webcam setup

Install video4linux tools:

```shell
sudo apt-get install v4l-utils
```

List video capture devices available:

```shell
v4l2-ctl --list-devices
```

View current setting for one device:

```shell
v4l2-ctl --device=0 --list-ctrls
v4l2-ctl --device=0 --list-ctrls-menu
```

Sample output for my cheap Nano Shield 1080p webcam:

```
$ v4l2-ctl --device=0 --list-ctrls
                     brightness 0x00980900 (int)    : min=-64 max=64 step=1 default=0 value=12
                       contrast 0x00980901 (int)    : min=0 max=100 step=1 default=50 value=52
                     saturation 0x00980902 (int)    : min=0 max=128 step=1 default=64 value=68
                            hue 0x00980903 (int)    : min=-180 max=180 step=1 default=0 value=-2
 white_balance_temperature_auto 0x0098090c (bool)   : default=1 value=1
                          gamma 0x00980910 (int)    : min=100 max=500 step=1 default=200 value=218
           power_line_frequency 0x00980918 (menu)   : min=0 max=2 default=1 value=1
      white_balance_temperature 0x0098091a (int)    : min=2800 max=6500 step=10 default=4600 value=4600 flags=inactive
                      sharpness 0x0098091b (int)    : min=0 max=100 step=1 default=80 value=80
         backlight_compensation 0x0098091c (int)    : min=0 max=2 step=1 default=0 value=0
                  exposure_auto 0x009a0901 (menu)   : min=0 max=3 default=3 value=3
              exposure_absolute 0x009a0902 (int)    : min=1 max=10000 step=1 default=166 value=166 flags=inactive
         exposure_auto_priority 0x009a0903 (bool)   : default=0 value=0
                   pan_absolute 0x009a0908 (int)    : min=-57600 max=57600 step=3600 default=0 value=0
                  tilt_absolute 0x009a0909 (int)    : min=-43200 max=43200 step=3600 default=0 value=0
                 focus_absolute 0x009a090a (int)    : min=0 max=1000 step=1 default=68 value=68 flags=inactive
                     focus_auto 0x009a090c (bool)   : default=1 value=1
                  zoom_absolute 0x009a090d (int)    : min=0 max=3 step=1 default=0 value=0
```

Edit settings, for example:

```shell
v4l2-ctl --device=0 --set-ctrl=exposure_auto=1
v4l2-ctl --device=0 --set-ctrl=exposure_absolute=110
v4l2-ctl --device=0 --set-ctrl=backlight_compensation=1
v4l2-ctl --device=0 --set-ctrl=focus_auto=0
v4l2-ctl --device=0 --set-ctrl=focus_absolute=0
v4l2-ctl --device=0 --set-ctrl=saturation=160
v4l2-ctl --device=0 --set-ctrl=sharpness=160
v4l2-ctl --device=0 --set-ctrl=brightness=110
v4l2-ctl --device=0 --set-ctrl=contrast=128
v4l2-ctl --device=0 --set-ctrl=white_balance_temperature_auto=0
v4l2-ctl --device=0 --set-ctrl=white_balance_temperature=2500
```

## microphone setup

I use `pulsemixer`, which I'm very happy with:

- Go to cards (F3)
- Ensure the *RODE Podcaster v2* is listed and set to an input mode (either Multichannel Input, or Mono Input)
- Go to Input devices (F2) and mute all inputs other than the *RODE Podcaster v2 Mono* and its child OBS devices


List connected PCI devices:

```text
lspci -v
```

List audio devices:

```text
cat /proc/asound/cards
aplay -L
arecord -l
```

Set level of input for the mic ([reference](http://www.massyn.net/completed/recording-with-the-rode-podcaster-on-linux/
)):

```text
cat /proc/asound/cards # Check what cardno
amixer -c <cardno>
amixer -c <cardno> set Mic 32 # or set to max
```

Set default input/output device ([reference](https://wiki.archlinux.org/index.php/PulseAudio/Examples#Set_default_input_sources)):

```text
pacmd list-sources | grep -e device.string -e 'name:' # get input device
pacmd list-sinks | grep -e 'name:' -e 'index:'        # get output device

sudo vim /etc/pulse/default.pa
```

Example:

```
set-default-sink alsa_output.usb-RODE_Microphones_RODE_Podcaster_v2_6D6D2FCA-00.iec958-stereo
set-default-source alsa_output.pci-0000_2b_00.1.hdmi-stereo-extra2
```

Restart PulseAudio:

```
pulseaudio -k
pulseaudio --start
```

### Delay audio

Delay audio to sync with video:

```text
$ ./delay_audio.sh ~/a6.mp4 0.2
```

## OBS setup

OBS does an amazing job of bringing all these devices together.

I setup two source:

- A full screen capture of my second lower resolution 1080p monitor
- An audio output capture (PulseAudio) of my RODE Podcaster v2

## VLC

Using VLC on the second screen I like to put a small frame that shows the webcam output. Remove VLC's menu chrome with `ctrl + h`.

Using `dwm` (my tiling window manager) put the just the VLC window into a dedicated floating mode using the default `SHIFT + MODKEY + space` shortcut. Position and resize the floating VLC window using `MODKEY + left/right mouse`
