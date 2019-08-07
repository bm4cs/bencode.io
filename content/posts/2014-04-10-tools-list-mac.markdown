---
layout: post
title: "Mac Tools List"
date: 2014-04-10 16:39:53 +10:00
comments: false
description: A collection of tools and tips (with a development skew) on squeezing the most out of my Macintosh and OS X.
categories: [General]
---

A cruft free collection of life changing, awesome tools, that will help you squeeze the most out of your Mac and OS X. 


### Essentials

-   **[HomeBrew](http://brew.sh/)** - rock solid package management, think `apt-get` for your mac. Install software with ease example: `brew install wget`. There are others, but I've never needed to look further.
-   **tree** - a tiny, but super elegant command line (CLI) program that recursively dumps the contents of a given directory, visually as an ASCII art tree. So good! Demo:

    [ben@localhost gradle-hack]$ tree
    .
    ├── build.gradle
    ├── gradle-hack.iml
    ├── settings.gradle
    └── src
        └── main
            └── java
                └── hello
                    ├── Greeter.java
                    └── HelloWorld.java


-   **[Sparrow](http://sparrowmailapp.com/)** - gmail client that is lightweight and fast. Its really really fast. Even its search rocks my world. Best $10 I've ever spent.
-   **[Sublime Text](http://www.sublimetext.com/)** - amazing + light + polished text editor.
-   **[Dropbox](https://www.dropbox.com/)** - device and computers everywhere. Data is one place. Love it.
-   **[Marked](http://markedapp.com/)** - a Markdown preview will show you the final output of your document as you work. Checkout the [extras pack](http://markedapp.com/#extras) for slick integration with a bunch of text editors including Sublime Text 2.
-   **[f.lux](https://justgetflux.com/)** - really life changing, especially if you find yourself regularly using the computer late into the night/morning. [f.lux](https://justgetflux.com/) makes your computers display (temperature) adjust to the time of day, warm at night, and like sunlight in the day. Helps me sleep, and deals with my computer induced headaches.
-   **[BreakTime](http://breaktimeapp.com/)** - great for console jockeys. For $5 this guy will remind you when you need to take a break. At first I thought this was a dumb idea, but have found it rather useful.
-   **[Pixelmator](http://www.pixelmator.com/)** - everyone needs a "paint" program right? Amazing, Apple to this day still forgets to ship a basic graphic editor with OS X. Pixelmator at $30 is an insanely polished and elegant graphic editor, way more features than your typical "paint", but somehow manages to stay out of your way and lets you simply do what you need to do. Developed just for OS X.
-   **[Tweetbot](http://tapbots.com/software/tweetbot/mac/)** - Twitter client that doesn't suck.
-   **[VLC](http://www.videolan.org/vlc/index.html)** - a multimedia work horse, music, videos anything you can throw at it. Just works.
-   **[Keka](http://www.kekaosx.com/en/)** - OS X's free archive tool, supporting lots of common compression formats 7z, Zip, Tar, Gzip, Bzip2, DMG, ISO, and extraction formats RAR, 7z, Lzma, Zip, Tar, Gzip, Bzip2, ISO, EXE, CAB, PAX, ACE (PPC).

### Utilities

-   **[Cyberduck](http://cyberduck.io/)** - neat network client for FTP, SFTP, WebDAV, S3 & OpenStack Swift.
-   **[Mou](http://mouapp.com/)** - markdown editor.
-   **[Skype](http://www.skype.com/en/)** - free VOIP.
-   **[Steam](http://store.steampowered.com/)** - the worlds most amazing digital games store, now supports OS X as a first class citizen.
-   **[uTorrent](http://www.utorrent.com/)** - defacto torrent client. Power, fast, clean. Check.
-   **[VirtualBox](https://www.virtualbox.org/)** or **[Parallels Desktop](http://www.parallels.com/products/desktop/)** - virtual machines, I personally use Virtual Box and rate it. Parallels at $99 provides very tight OS X platform integration, and is well worth considering.


### Developer tools

-   **[Sublime Text](http://www.sublimetext.com/)** or **[MacVim](https://code.google.com/p/macvim/)** - OS X already wins the cool contest, shipping with command line `vim` without even trying, but comes with unsatisfactory graphical text editor. [Sublime](http://www.sublimetext.com/) is highly functional, but still feels light to use. Its default `Monokai` theme looks gorgeous on a retina display. Sublime has become my go to editor of late. [MacVim](https://code.google.com/p/macvim/) is a kick ass graphical Vim, that integrates beautifully with the OS X environment. Also in 2014, keep an eye on GitHub's new hackable text editor for the 21st Century called [Atom](https://atom.io/).
-   **[IntelliJ IDEA](http://www.jetbrains.com/idea/)** - not only are the guys at JetBrains super smart, they understand all the tiny things that developers do and care about. [IntelliJ](http://www.jetbrains.com/idea/) or IDEA is crazy smart; words cant describe. Hands down the most useful IDE I've ever used.
-   **[Groovy](http://groovy.codehaus.org/)** - cross platform JVM based dynamic language. Ultra powerful. A scriptors heaven.
-   **[Postman](http://www.getpostman.com/)** - a Chrome based HTTP test client, used by thousands of developers daily. Try it and you'll see why.
-   **[Git](http://git-scm.com/)** - Linus got bored one day, and built the worlds most excellent distributed version control system. Pretty much the defacto standard now. If you've got homebrew `brew install git`. New to git? [Try Git](https://www.codeschool.com/courses/try-git)
-   **[SourceTree](http://www.sourcetreeapp.com/)** - Atlassian make beautiful software. SourceTree is their highly functional graphical git (and hg) client.
-   **[KDiff3](http://kdiff3.sourceforge.net/)** - GPL, supports 3-way diffs, and runs on most platforms including OS X. Might not be the prettiest or most polished diff tool out there, but when it comes to function, KDiff3 ticks all the right boxes.
-   **[Dash](http://kapeli.com/dash)** - instant offline access to 150+ API documentation sets.
-   **[ExplainShell.com](http://explainshell.com/)** - breaks down how UNIX chaining, piping etc works.
-   **Subversion** - git rules, but there is still allot of svn around. If you have `xcode`, dig into Preferences > Downloads > Command Line Tools > Install, otherwise grab the [standalone installer](https://developer.apple.com/downloads/index.action). Next.
-   **Xcode** - offical Apple developer IDE. As of Mountain Lion (10.8) uses the `LLVM` compiler frontend by default (as opposed to `GCC`).
-   **Apache Web Server and PHP** - baked into OS X. `PHP` is disabled by default. Edit `/etc/apache2/httpd.conf`, uncomment `LoadModule php5_module libexec/apache2/libphp5.so`, and bounce it `sudo apachectl restart`. Take it for a test drive: `echo "<?php phpinfo(); ?>" > /Library/WebServer/Documents/foo.php`, and hit `http://localhost/foo.php`.
-   **[BrowserStack](http://www.browserstack.com/)** - developing for the web can be frustrating. These clever folk have a farm of platforms that can render your web pages on a range of platforms and browsers. Love the tunneling app that can expose your locally hosted web servers. 


### Useful Shortcuts

-   `Command + Shift + H` - [Finder] go to home directory for current user.
-   `Command + <space bar>` - [Spotlight] mouse free application launcher.
-   `Command + <comma>` - preferences of current application.
-   `Command + Tilde(~) or Command + Shift + Tilde(~)` - switch between windows within current application.
-   `Control + Eject` - display Restart/Sleep/Shutdown dialog box.
-   `Command + Option + Click` - [Dock] focused launch, will hide all other apps except the app just launched
-   `Command + Shift + 4` - select a region to screenshot.
-   `Command + Shift + 4` followed by `space` - select window to screenshot.

