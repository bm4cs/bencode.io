---
layout: post
draft: false
title: "Installing Arch Linux on the Pinebook Pro"
slug: "pinebook"
date: "2020-07-27 20:27:23"
lastmod: "2020-08-01 22:27:17"
comments: false
categories:
    - linux
tags:
    - linux
    - arch
---

_Updated 2022-04-11: Installed a minimal version of Manjaro, a SLICK flavour of Arch_

The [pinebook pro](https://www.pine64.org/pinebook-pro/) is a beautiful 64-bit ARM based laptop, that reminds me of the form factor of a modern macbook air, shipping with a premium magnesium alloy shell, 64GB eMMC and a 10,000 mAH battery. All this for $200.

As a NIX machine, I've found Manjaro to be delightful. I have dreams of one day installing OpenBSD.

1. On another Linux box download and prep a microSD card with an ARM Linux distro. Tne [PINE64 NOOB wiki](https://wiki.pine64.org/wiki/NOOB#Setting_Up_Your_Single_Board_Computer_-_What_do_You_Need_to_Get_Started) spell everything out nicely. 
1. Pick you distro, for simplicity I'm sticking with the [Manjaro ARM with no desktop](https://wiki.pine64.org/wiki/Pinebook_Pro_Software_Release#Manjaro_ARM_with_no_desktop) pre-baked image that is known to work well with the pinebook pro hardware.
1. Flash the microSD card `sudo dd if=Manjaro-ARM-minimal-pbpro-22.02.img of=/dev/sdb bs=1M status=progress conv=fsync`. [balenaEtcher](https://www.balena.io/etcher/) is another great option.
1. Jack the SD into the PBP and boot it. If you're in luck the majaro installed will bootstrap itself. Leave the microSD jacked in. Reboot. Winnning!
1. At this point, you should be are fully operational running off the microSD card. Live your life and be happy. But since I purchased the version that comes with an internal 64GB eMMC storage I wanted to plant the O/S on it.
1. Thinking aloud...given the pinebook was actively booted off the microSD, I basically needed to rince and repeat the exact same process I used to etch the image to the microSD card, but this time to the eMMC card. The raw `img` file was not on the filesystem of the microSD as it was mounted and running the actual running O/S. Hmmm. I needed to get `Manjaro-ARM-minimal-pbpro-22.02.img` onto the running pinebook, which was booted off the microSD and had no network currently setup. I could setup networking and `curl` it. From another Linux box I could just write the `img` to another USB drive and in-turn mount that on the pinebook. I tried the later option.
1. Jack a USB thumb drive into your other stable Linux box. Prepare, partition, `mkfs.ext4` if needed. Mount the drive to `/mnt` and write `Manjaro-ARM-minimal-pbpro-22.02.img` to it. Unmount it and unjack the USB thumbdrive.
1. Jack the thumbdrive into the pinebook which is currently running happily bootstrapped off the microSD card. Mount the thumbdrive like normal e.g. `sudo mount /dev/sda1 /mnt`
1. Now its just a matter of etching the manjaro image file to the internal eMMC card. You have all the ingredients to make this happen, that is `sudo dd if=/mnt/Manjaro-ARM-minimal-pbpro-22.02.img of=/dev/mmcblk2`
1. Partition the internal eMMC card `fdisk /dev/mmcblk2`, leaving the first 16MB free for the _u-boot_ boot loader. Enter `g` to create a new GPT partition table. Then `n` to create a new partition, with `65536` as the first sector. Then `w` to write the changes.
1. Format the newly partitioned eMMC with `mkfs.ext4 /dev/mmcblk2p1`
1. Mount it with `mount /dev/mmcblk2p1 /mnt`
1. `pacstrap` the fleshly minted volume as per a normal Arch installation, such as `pacstrap /mnt base base-devel`. After pacstrap, chroot to `/mnt`. Setup everything as per normal, such as networking, accounts, and so on. Checkout the offical [arch install wiki](https://wiki.archlinux.org/index.php/installation_guide) or [my arch guide]({{< ref "2019-04-19-arch.md" >}}).
1. Install a customised kernel, that includes support for the pinebook pro, by running `pacman -Sy linux-pbp`.
1. Create u-boot configuration file `/boot/extlinux/extlinux.conf`, with the configuration template below, replacing `<UUID>` with the id of the eMMC partition which can be identified with the `blkid` command
1. Add firmware for bluetooth, wifi and keyboard brightness `pacman -Sy ap256-firmware pbp-keyboard-hwdb`.
1. Install u-boot bootloader with `pacman -Sy uboot-pbp`, this will vomit out the `idbloader.img` and `u-boot.itb` files into `/boot`. The first must be written at sector 64, the second at sector 16384.
1. `reboot` and profit!

# Write u-boot bootloader

    dd if=/boot/idbloader.img of=/dev/mmcblk2 seek=64
    dd if=/boot/u-boot.itb of=/dev/mmcblk2 seek=16384

# extlinux.conf

    LABEL Arch Linux ARM
    KERNEL ../Image
    FDT ../dtbs/rockchip/rk3399-pinebook-pro.dtb
    APPEND initrd=../initramfs-linux.img console=tty1 rootwait root=UUID=<UUID> rw







