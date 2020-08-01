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


The [pinebook pro](https://www.pine64.org/pinebook-pro/) is a beautiful 64-bit ARM based laptop, that reminds me of the form factor of a modern macbook air, shipping with a premium magnesium alloy shell, 128GB eMMC and a 10,000 mAH battery. All this for $200.

As a NIX machine, I decided to stick with Arch Linux, but have plans to one day install OpenBSD on it.

A big thanks to the team (Nadia Holmquist Pedersen) who has put together a [pre-built flashable Arch Linux image](https://github.com/nadiaholmquist/archiso-pbp/releases), tailored for ARM and specially some of the hardware in the Pinebook Pro. Without this, it would have been a matter of manually grafting bits and pieces of the supported Manjaro build into an ARM based Arch install.


1. Boot up the Pinebook Pro, which has manjaro and KDE pre-installed. Login with rock/rock. Pop the SD card into the reader on RHS of the pinebook. The SD card is `/dev/mmcblk1`, while the eMMC is `/dev/mmcblk2`.
2. [Download](https://github.com/nadiaholmquist/archiso-pbp/releases) the pre-built flashable Arch linux image, tailored for ARM and specially the Pinebook Pro.
3. Flash the micro SD card with Nadia's image `sudo dd if=archlinux-2020.07.02-pbp.img of=/dev/mmcblk0`
4. Reboot into Arch running off the SD card.
5. Partition the internal eMMC card `fdisk /dev/mmcblk2`, leaving the first 16MB free for the *u-boot* boot loader. Enter `g` to create a new GPT partition table. Then `n` to create a new partition, with `65536` as the first sector. Then `w` to write the changes.
6. Format the newly partitioned eMMC with `mkfs.ext4 /dev/mmcblk2p1`
7. Mount it with `mount /dev/mmcblk2p1 /mnt`
8. `pacstrap` the fleshly minted volume as per a normal Arch installation, such as `pacstrap /mnt base base-devel`. After pacstrap, chroot to `/mnt`. Setup everything as per normal, such as networking, accounts, and so on. Checkout the offical [arch install wiki](https://wiki.archlinux.org/index.php/installation_guide) or [my arch guide]({{< ref "2019-04-19-arch.md" >}}).
9. Install a customised kernel, that includes support for the pinebook pro, by running `pacman -Sy linux-pbp`.
10. Create u-boot configuration file `/boot/extlinux/extlinux.conf`, with the configuration template below, replacing `<UUID>` with the id of the eMMC partition which can be identified with the `blkid` command
11. Add firmware for bluetooth, wifi and keyboard brightness `pacman -Sy ap256-firmware pbp-keyboard-hwdb`.
12. Install u-boot bootloader with `pacman -Sy uboot-pbp`, this will vomit out the `idbloader.img` and `u-boot.itb` files into `/boot`. The first must be written at sector 64, the second at sector 16384.
13. `reboot` and profit!


# Write u-boot bootloader

    dd if=/boot/idbloader.img of=/dev/mmcblk2 seek=64
    dd if=/boot/u-boot.itb of=/dev/mmcblk2 seek=16384


# extlinux.conf

    LABEL Arch Linux ARM
    KERNEL ../Image
    FDT ../dtbs/rockchip/rk3399-pinebook-pro.dtb
    APPEND initrd=../initramfs-linux.img console=tty1 rootwait root=UUID=<UUID> rw


