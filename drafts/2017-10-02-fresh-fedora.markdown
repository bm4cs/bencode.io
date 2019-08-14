---
layout: post
title: "Clean Linux Install"
date: "2017-10-02 14:20:44"
comments: false
categories: "Linux"
---

After upgrading my Fedora Core development machine for years, from 17 through to 25, my distro underwent numerous major heart transplants (e.g. X to wayland, yum to dnf, several major kernel upgrades) a testiment to the Fedora team and a win for package management. But after a while things just got twisted. I still had a zombie X server running in the background, and when mainline kernel support for my RX480 GPU came along in Fedora 25 it was totally screwed. I've now got into the habbit of nuking and recreating my machine. I'm working on some Ansible playbooks, to completely automate this drudgery.

### Backup Steps

- tarball `/etc`
- tarball `~` (includes steam ~/.local/share/Steam)
- KVM virtual machines (`/var/lib/libvirt/images`)

### Restoration Steps

- [Chrome](https://www.google.com/chrome). Prerequisites are [LSB](https://en.wikipedia.org/wiki/Linux_Standard_Base) and libXss. `sudo dnf install redhat-lsb libXScrnSaver`, then `sudo rpm -i google-chrome-stable_current_x86_64.rpm`.
- Create local groups `hackers`, `developers`
- Register [RPM Fusion](https://rpmfusion.org/Configuration).
- Essential packages; `sudo dnf install vim git gcc make xmms weechat mutt`
- [JetBrains Toolbox](https://www.jetbrains.com/toolbox/download).
- VSCode
- Sublime Text. Install GPG key `sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg`, then register the stable repo `sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo`, then install `sudo dnf install sublime-text`.
- Steam
- Balsamiq and Wine
- SmartGit or GitKraken



**Complete Rebuild Steps**

When the original home `~` is not lifted.

- Install fonts; [Anonymous Pro](https://www.marksimonson.com/fonts/view/anonymous-pro), [Courier Prime](https://quoteunquoteapps.com/courierprime/) and [Nimbus Mono](#). `fc-cache -v`.
- Run `~/git/scripts/linux/install.sh` to symlink in `.vimrc`, `.bashrc`, `.muttrc` and others.

