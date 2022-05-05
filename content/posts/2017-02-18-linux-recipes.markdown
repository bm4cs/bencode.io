---
layout: post
title: "Linux cheatsheet"
slug: "linuxcheat"
date: "2017-02-18 21:06:01+11:00"
lastmod: "2021-09-26 14:36:34+11:00"
comments: false
categories:
    - linux
---

A survey of the standard and high quality programs that feature in most Unix based distributions, with the GNU variants being my favourite. The `bash` shell is a great way of interfacing and orchestrating these beautifully crafted programs. As a starting point, I've listed each program offered by the [GNU Core Utilities](https://www.gnu.org/software/coreutils/coreutils.html) and [util-linux](https://en.wikipedia.org/wiki/Util-linux) umbrella projects; considered the de facto standard on most distributions.

-   [Quick Reference](#quick-reference)
    -   [General](#general)
    -   [System Information](#system-information)
    -   [Directory Navigation](#directory-navigation)
    -   [File Searching](#file-searching)
    -   [Archiving and Compression](#archiving-and-compression)
    -   [Networking](#networking)
    -   [Text Manipulation](#text-manipulation)
    -   [Set Operations](#set-operations)
    -   [Windows Networking](#windows-networking)
    -   [Monitoring and Debugging](#monitoring-and-debugging)
    -   [Disk Space](#disk-space)
    -   [CD/DVD](#cddvd)
    -   [Locales](#locales)
    -   [Dates and Times](#dates-and-times)
    -   [Images](#images)
-   [Finding Documentation](#finding-documentation)
    -   [Manual Pages](#manual-pages)
    -   [Appropriate Commands](#appropriate-commands)
    -   [whatis](#whatis)
    -   [GNU Info Entry](#gnu-info-entry)
    -   [/usr/share/doc Documentation](#usrsharedoc-documentation)
    -   [RPM bundled documentation](#rpm-bundled-documentation)
-   [Examples](#examples)
    -   [grep](#grep)
    -   [cut](#cut)
    -   [sort](#sort)
    -   [tr](#tr)
    -   [wc](#wc)
    -   [tar](#tar)
    -   [rsync](#rsync)
    -   [sed](#sed)
    -   [awk](#awk)
    -   [ssh (Secure Shell)](#ssh-secure-shell)
    -   [wget](#wget)
-   [BFL of Common Programs](#bfl-of-common-programs)
-   [Resources](#resources)

# Quick Reference

## General

| Command                                        | What is does                                                                   |
| ---------------------------------------------- | ------------------------------------------------------------------------------ |
| `apropos compress`                             | Show commands that relate to a keyword                                         |
| `man -t ascii \| ps2pdf - > ascii.pdf`         | Make a PDF of a man page                                                       |
| `which command`                                | Full path of command                                                           |
| `time command`                                 | Show execution time of a given command                                         |
| `time cat`                                     | Start stopwatch, ^d to stop                                                    |
| `cat file.txt \| xclip -selection clipboard`   | Copy to clipboard                                                              |
| `nohup ./script.sh &`                          | Keep program running after leaving SSH session (see bash post if input needed) |
| `timeout 20s ./script.sh`                      | Run script.sh for 20 seconds only                                              |
| `while true; do timeout 30m ./script.sh; done` | Restart a program every 30 minutes                                             |

## System Information

| Command                                          | What is does                                              |
| ------------------------------------------------ | --------------------------------------------------------- |
| `uname -a`                                       | Show kernel version and system architecture               |
| `head -n1 /etc/issue`                            | Show name and version of distribution                     |
| `cat /proc/partitions`                           | Show all partitions registered on the system              |
| `grep MemTotal /proc/meminfo`                    | Show RAM total seen by the system                         |
| `grep "model name" /proc/cpuinfo`                | Show CPU(s) info                                          |
| `lspci -tv`                                      | Show PCI info                                             |
| `lsusb -tv`                                      | Show USB info                                             |
| `mount \| column -t`                             | List mounted filesystems on the system (and align output) |
| `grep -F capacity: /proc/acpi/battery/BAT0/info` | Show state of cells in laptop battery                     |
| `dmidecode -q \| less`                           | Display SMBIOS/DMI information                            |
| `smartctl -A /dev/sda \| grep Power_On_Hours`    | How long has this disk (system) been powered on in total  |
| `hdparm -i /dev/sda`                             | Show info about disk sda                                  |
| `hdparm -tT /dev/sda`                            | Do a read speed test on disk sda                          |
| `badblocks -s /dev/sda`                          | Test for unreadable blocks on disk sda                    |

## Directory Navigation

| Command              | What is does                                                     |
| -------------------- | ---------------------------------------------------------------- |
| `cd -`               | Go previous directory                                            |
| `cd`                 | Go home                                                          |
| `(cd dir123 && pwd)` | Jump into a directory, run a command there, and return to origin |
| `pushd .`            | Put cwd on stack, so you can `popd` back to it                   |

## File Searching

| Command                                                                        | What is does                                                                  |
| ------------------------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| `alias l='ls -l --color=auto'`                                                 | Quick listing                                                                 |
| `ls -lrt`                                                                      | List long by date                                                             |
| `ls -lS`                                                                       | List long by size                                                             |
| `ls /usr/bin \| pr -T9 -W$COLUMNS`                                             | Print in 9 columns to width of terminal                                       |
| `find -name '*.[ch] \| xargs grep -E 'foo'`                                    | Search for 'foo' in all `.c` and `.h` files in cwd and below                  |
| `find -type f -print0 \| xargs -r0 grep -F 'example'`                          | Search all regular files for 'example'                                        |
| `find -maxdepth 1 -type f \| xargs grep -F 'example'`                          | As above, but don't recurse                                                   |
| `find -maxdepth 1 -type d \| while read dir; do echo $dir; echo somecmd; done` | Wash each result over multiple commands                                       |
| `find -type f ! -perm -444`                                                    | Find files not readable by all                                                |
| `find -type d ! -perm -111`                                                    | Find dirs not accessable by all                                               |
| `find . -size 30c`                                                             | By file size (30 bytes)                                                       |
| `find . -name "*.gz" -delete`                                                  | Delete all gz files                                                           |
| `locate -r 'file[^/]*\.txt`                                                    | Search cached index for names                                                 |
| `look <keyword>`                                                               | Search English dictionary with a given prefix keyword                         |
| `grep --color reference /usr/share/dict/words`                                 | Highlight occurances of regex against English dictionary                      |
| `readlink -f file.txt`                                                         | Full path of file                                                             |
| `namei -l /bin/bash`                                                           | Drills through directories and links showing permission mask all the way down |

## Archiving and Compression

| Command                                                                       | What is does                                                |
| ----------------------------------------------------------------------------- | ----------------------------------------------------------- |
| gpg -c file                                                                   | Encrypt file                                                |
| gpg file.gpg                                                                  | Decrypt file                                                |
| tar -c dir/ \| bzip2 > dir.tar.bz2                                            | Make compressed archive of dir                              |
| bzip2 -dc dir.tar.bz2 \| tar -x                                               | Extract archive                                             |
| tar -c dir/ \| gzip \| gpg -c \| ssh user@remote 'dd of=dir.tar.gz.gpg'       | Make encrypted archive of `dir` on remote machine           |
| find dir/ -name '\*.txt' \| tar -c --files-from=- \| bzip2 > dir_txt.tar.bz2  | Make archive of subset of `dir` and below                   |
| find dir/ -name '\*.txt' \| xargs cp -a --target-directory=dir_txt/ --parents | Make copy of subset of `dir` and below                      |
| ( tar -c /dir/to/copy ) \| ( cd /where/to/ && tar -x -p )                     | Copy (with permissions) copy/ dir to /where/to/ dir         |
| ( cd /dir/to/copy && tar -c . ) \| ( cd /where/to/ && tar -x -p )             | Copy (with permissions) contents of copy/ dir to /where/to/ |
| ( tar -c /dir/to/copy ) \| ssh -C user@remote 'cd /where/to/ && tar -x -p'    | Copy (with permissions) copy/ dir to remote:/where/to/ dir  |
| dd bs=1M if=/dev/sda \| gzip \| ssh user@remote 'dd of=sda.gz'                | Backup harddisk to remote machine                           |

## Networking

| Command                                                   | What is does                                            |
| --------------------------------------------------------- | ------------------------------------------------------- |
| `ethtool eth0`                                            | Show status of ethernet interface eth0                  |
| `ethtool --change eth0 autoneg off speed 100 duplex full` | Manually set ethernet interface speed                   |
| `iw dev wlan0 link`                                       | Show link status of wireless interface wlan0            |
| `iw dev wlan0 set bitrates legacy-2.4 1`                  | Manually set wireless interface speed                   |
| `iw dev wlan0 scan`                                       | List wireless networks in range                         |
| `ip link show`                                            | List network interfaces                                 |
| `ip link set dev eth0 name wan`                           | Rename interface eth0 to wan                            |
| `ip link set dev eth0 up`                                 | Bring interface eth0 up (or down)                       |
| `ip addr show`                                            | List addresses for interfaces                           |
| `ip addr add 1.2.3.4/24 brd + dev eth0`                   | Add (or del) ip and mask (255.255.255.0)                |
| `ip route show`                                           | List routing table                                      |
| `ip route add default via 1.2.3.254`                      | Set default gateway to 1.2.3.254                        |
| `ss -tupl`                                                | List internet services on a system                      |
| `ss -tup`                                                 | List active connections to/from system                  |
| `host bencode.net`                                        | Lookup DNS ip address for name or vice versa            |
| `hostname -i`                                             | Lookup local ip address (equivalent to host `hostname`) |
| `whois bencode.net`                                       | Lookup whois info for hostname or ip address            |
| `mtr google.com`                                          | Nice trace route                                        |

## Text Manipulation

| Command                                              | What is does                                         |
| ---------------------------------------------------- | ---------------------------------------------------- |
| `sed 's/string1/string2/g'`                          | Replace string1 with string2                         |
| `sed 's/\(.*\)1/\12/g'`                              | Modify anystring1 to anystring2                      |
| `sed '/^ *#/d; /^ *$/d'`                             | Remove comments and blank lines                      |
| `sed ':a; /\\$/N; s/\\\n//; ta'`                     | Concatenate lines with trailing \                    |
| `sed 's/[ \t]*$//'`                                  | Remove trailing spaces from lines                    |
| `seq 10 \| sed "s/^/ /; s/ *\(.\{7,\}\)/\1/"`        | Right align numbers                                  |
| `seq 10 \| sed p \| paste - -`                       | Duplicate a column                                   |
| `sed -n '1000{p;q}'`                                 | Print 1000th line                                    |
| `sed -n '10,20p;20q'`                                | Print lines 10 to 20                                 |
| `sed -n 's/.*<title>\(.*\)<\/title>.*/\1/ip;T;q'`    | Extract title from HTML web page                     |
| `sed -i 42d ~/.ssh/known_hosts`                      | Delete a particular line                             |
| `sort -t. -k1,1n -k2,2n -k3,3n -k4,4n`               | Sort IPV4 ip addresses                               |
| `echo 'Test' \| tr '[:lower:]' '[:upper:]'`          | Case conversion                                      |
| `tr -dc '[:print:]' < /dev/urandom`                  | Filter non printable characters                      |
| `tr -s '[:blank:]' '\t' </proc/diskstats \| cut -f4` | cut fields separated by blanks                       |
| `history \| wc -l`                                   | Count lines                                          |
| `seq 10 \| paste -s -d ' '`                          | Concatenate and separate line items to a single line |
| `sort -u file1 file2`                                | Union of unsorted files                              |
| `sort file1 file2 \| uniq -d`                        | Intersection of unsorted files                       |
| `sort file1 file1 file2 \| uniq -u`                  | Difference of unsorted files                         |
| `sort file1 file2 \| uniq -u`                        | Symmetric Difference of unsorted files               |
| `join -t'\0' -a1 -a2 file1 file2`                    | Union of sorted files                                |
| `join -t'\0' file1 file2`                            | Intersection of sorted files                         |
| `join -t'\0' -v2 file1 file2`                        | Difference of sorted files                           |
| `join -t'\0' -v1 -v2 file1 file2`                    | Symmetric Difference of sorted files                 |
| `shuf file1`                                         | Randomise lines in a file                            |
| `comm file1 file2`                                   | Combine lines from two sorted files                  |

## Set Operations

| Command                             | What is does                           |
| ----------------------------------- | -------------------------------------- |
| `sort -u file1 file2`               | Union of unsorted files                |
| `sort file1 file2 \| uniq -d`       | Intersection of unsorted files         |
| `sort file1 file1 file2 \| uniq -u` | Difference of unsorted files           |
| `sort file1 file2 \| uniq -u`       | Symmetric Difference of unsorted files |
| `join -t'\0' -a1 -a2 file1 file2`   | Union of sorted files                  |
| `join -t'\0' file1 file2`           | Intersection of sorted files           |
| `join -t'\0' -v2 file1 file2`       | Difference of sorted files             |
| `join -t'\0' -v1 -v2 file1 file2`   | Symmetric Difference of sorted files   |

## Windows Networking

| Command                                                            | What is does                                               |
| ------------------------------------------------------------------ | ---------------------------------------------------------- |
| `smbtree`                                                          | Find windows machines. See also findsmb                    |
| `nmblookup -A 1.2.3.4`                                             | Find the windows (netbios) name associated with ip address |
| `smbclient -L windows_box`                                         | List shares on windows machine or samba server             |
| `mount -t smbfs -o fmask=666,guest //windows_box/share /mnt/share` | Mount a windows share                                      |
| `echo 'message' \| smbclient -M windows_box`                       | Send popup to windows machine                              |

## Monitoring and Debugging

| Command                                                                    | What is does                                                 |
| -------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `tail -f /var/log/messages`                                                | Monitor messages in a log file                               |
| `strace -c ls >/dev/null`                                                  | Summarise/profile system calls made by command               |
| `strace -f -e open ls >/dev/null`                                          | List system calls made by command                            |
| `strace -f -e trace=write -e write=1,2 ls >/dev/null`                      | Monitor what's written to stdout and stderr                  |
| `ltrace -f -e getenv ls >/dev/null`                                        | List library calls made by command                           |
| `lsof -p $$`                                                               | List paths that process id has open                          |
| `lsof ~`                                                                   | List processes that have specified path open                 |
| `tcpdump not port 22`                                                      | Show network traffic except ssh. See also tcpdump_not_me     |
| `ps -e -o pid,args --forest`                                               | List processes in a hierarchy                                |
| `ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu \| sed '/^ 0.0 /d'` | List processes by % cpu usage                                |
| `ps -e -orss=,args= \| sort -b -k1,1n \| pr -TW$COLUMNS`                   | List processes by mem (KB) usage. See also ps_mem.py         |
| `ps -C firefox-bin -L -o pid,tid,pcpu,state`                               | List all threads for a particular process                    |
| `ps -p 1,$$ -o etime=`                                                     | List elapsed wall time for particular process IDs            |
| `watch -n.1 pstree -Uacp $$`                                               | Display a changing process subtree                           |
| `last reboot`                                                              | Show system reboot history                                   |
| `free -m`                                                                  | Show amount of (remaining) RAM (-m displays in MB)           |
| `watch -n.1 'cat /proc/interrupts'`                                        | Watch changeable data continuously                           |
| `udevadm monitor`                                                          | Monitor udev events to help configure rules                  |
| `ulimit -Sv 1000`                                                          | Limit memory usage for following commands to 1MiB            |
| `fuser -k 8000/tcp`                                                        | Kill the program using port 8000                             |
| `lsof -p 123,789 -u 1234,abe`                                              | All files used by PID 123 or 789, or by user abe or UID 1234 |
| `kill -HUP $(lsof -t /home/foo/file)`                                      | SIGHUP the processes using /home/foo/file                    |
| `cat /dev/urandom \| base64 \| pv -lbri2 > /dev/null`                      | Monitor progress of output                                   |

## Disk Space

| Command                                                                | What is does                                                |
| ---------------------------------------------------------------------- | ----------------------------------------------------------- |
| `ls -lSr`                                                              | Show files by size, biggest last                            |
| `du -s * \| sort -k1,1rn \| head`                                      | Show top disk uses in current dir                           |
| `du -hs /home/* \| sort -k1,1h`                                        | Sort paths by easy to interpret disk usage                  |
| `df -h`                                                                | Show free space on mounted filesystems                      |
| `df -i`                                                                | Show free inodes on mounted filesystems                     |
| `fdisk -l`                                                             | Show disks partitions sizes and types (run as root)         |
| `rpm -q -a --qf '%10{SIZE}\t%{NAME}\n' \| sort -k1,1n`                 | List all packages by installed size (Bytes) on rpm distros  |
| `dpkg-query -W -f='${Installed-Size;10}\t${Package}\n' \| sort -k1,1n` | List all packages by installed size (KBytes) on deb distros |
| `dd bs=1 seek=2TB if=/dev/null of=ext3.test`                           | Create a large test file (taking no space)                  |
| `> file`                                                               | truncate data of file or create an empty file               |

## CD/DVD

| Command                                                                                                        | What is does                                           |
| -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `gzip < /dev/cdrom > cdrom.iso.gz`                                                                             | Save copy of data cdrom                                |
| `mkisofs -V LABEL -r dir \| gzip > cdrom.iso.gz`                                                               | Create cdrom image from contents of dir                |
| `mount -o loop cdrom.iso /mnt/dir`                                                                             | Mount the cdrom image at /mnt/dir (read only)          |
| `wodim dev=/dev/cdrom blank=fast`                                                                              | Clear a CDRW                                           |
| `gzip -dc cdrom.iso.gz \| wodim -tao dev=/dev/cdrom -v -data -`                                                | Burn cdrom image                                       |
| `cdparanoia -B`                                                                                                | Rip audio tracks from CD to wav files in current dir   |
| `wodim -v dev=/dev/sr0 -audio -pad *.wav`                                                                      | Make audio CD from all wavs in current dir             |
| `oggenc --tracknum=$track track.cdda.wav -o track.ogg`                                                         | Make ogg file from wav file                            |
| `for i in *.mp3; do mpg123 --rate 44100 --stereo --buffer 3072 --resync -w "$(basename $i .mp3).wav" $i; done` | Decode mp3 files to 16-bit, stereo, 44.1 kHz waves     |
| ` for i in *.mp3; do lame --decode $i ``basename $i .mp3``.wav; done `                                         | Decode mp3 files to 16-bit, stereo, 44.1 kHz waves     |
| `normalize -m *.wav`                                                                                           | Normalise levels in wavs, mix mode is loud as possible |

## Locales

| Command                                                             | What is does                                               |
| ------------------------------------------------------------------- | ---------------------------------------------------------- |
| `printf "%'d\n" 1234`                                               | Print number with thousands grouping appropriate to locale |
| `BLOCK_SIZE=\'1 ls -l`                                              | Use locale thousands grouping in ls. See also l            |
| `echo "I live in$(locale territory)"`                               | Extract info from locale database                          |
| `LANG=en_IE.utf8 locale int_prefix`                                 | Lookup locale info for specific country. See also ccodes   |
| `locale -kc $(locale \| sed -n 's/\(LC_.\{4,\}\)=.*/\1/p') \| less` | List fields available in locale database                   |

## Dates and Times

| Command                                                    | What is does                                                  |
| ---------------------------------------------------------- | ------------------------------------------------------------- |
| `cal -3`                                                   | Display a calendar                                            |
| `cal 9 1752`                                               | Display a calendar for a particular month year                |
| `date -d fri`                                              | What date is it this friday                                   |
| `[ $(date -d '12:00 today +1 day' +%d) = '01' ] \|\| exit` | exit a script unless it's the last day of the month           |
| `date --date='25 Dec' +%A`                                 | What day does xmas fall on, this year                         |
| `date --date='@2147483647'`                                | Convert seconds since the epoch (1970-01-01 UTC) to date      |
| `TZ='America/Los_Angeles' date`                            | What time is it on west coast of US (use tzselect to find TZ) |
| `date --date='TZ="America/Los_Angeles" 09:00 next Fri'`    | What's the local time for 9AM next Friday on west coast US    |

## Images

Most of these rely on the imagemagick cli programs.

`identify foo.jpg` | Show meta including resolution

# Finding Documentation

## Manual Pages

The infamous manual (man) page documentation system. Man pages are organised by the following sections:

| Section | Name                                     | Description                                                                                              |
| ------- | ---------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| 1       | User commands (Programs)                 | Commands that can be executed by the user from within a shell.                                           |
| 2       | System calls                             | Functions which wrap operations performed by the kernel.                                                 |
| 3       | Library calls                            | Library functions excluding the system call wrappers (Most of the libc functions).                       |
| 4       | Special files (devices)                  | Files found in `/dev` which allow to access to devices through the kernel.                               |
| 5       | File formats and configuration files     | Various human-readable file formats and configuration files.                                             |
| 6       | Games                                    | Games and funny little programs available on the system.                                                 |
| 7       | Overview, conventions, and miscellaneous | Various topics, conventions and protocols, character set standards, the standard filesystem layout, etc. |
| 8       | System management commands               | Commands like `mount(8)`, many of which only root can execute.                                           |

An explicit section can be requested. For the man page relating to the file format of `/etc/passwd`

    man 5 passwd

The `-k` switch is great for searching across `man`'s treasure chest of documentation. For example, say you want to set the system time, but have no idea what program to use to achieve this. Use the `-k` switch to scan documentation for _time_.

    $ man -k time
    ac (1)               - print statistics about users connect time
    adjtime (3)          - correct the time to synchronize the system clock
    adjtimex (2)         - tune kernel clock
    after (n)            - Execute a command after a time delay
    aio_suspend (3)      - wait for asynchronous I/O operation or timeout
    asctime (3)          - transform date and time to broken-down time or ASCII
    asctime (3p)         - convert date and time to a string

The lions share of search results seems to come from section 2 and 3 (C kernel and library calls). Focusing on the task at hand, administering the system time, lets filter results to man sections 1 (user commands) and 8 (system management commands).

    $ man -k time | grep -Pe '.*\([1,8]\).*'
    ac (1)               - print statistics about users connect time
    booleans (8)         - Policy booleans enable runtime customization of SELinux policy
    ccrewrite (1)        - Rewrite CLR assemblies for runtime code contract verification.
    chrt (1)             - manipulate the real-time attributes of a process
    date (1)             - print or set the system date and time
    dnssec-settime (8)   - Set the key timing metadata for a DNSSEC key
    jack_showtime (1)    - The JACK Audio Connection Kit example client

The `date` program looks perfect.

## Appropriate Commands

Basically an equivalent to the `man -k` switch for searching.

    $ apropos clock
    adjtime (3)          - correct the time to synchronize the system clock
    adjtimex (2)         - tune kernel clock
    alarm (2)            - set an alarm clock for delivery of a signal
    clock (3)            - determine processor time

## whatis

For a very brief overview of a man page matching a keyword.

    $ whatis vim
    vim (1)              - Vi IMproved, a programmers text editor

## GNU Info Entry

A purpose built documentation system from GNU, `info` features hyperlinks (prefixed with `*`), aimed at dealing with larger documentation sets than `man`.

`info` goes against the grain in terms of keyboard navigation. Its odd. Page up, page down, `enter` to follow a link, and `l` to go back,

Some keys for driving info:

-   `n` next node
-   `p` previous node
-   `u` parent node
-   `t` top node
-   `home` `end` `pgup` `pgdn` scroll content
-   `l` go back
-   `q` quit
-   `H` keyboard shortcuts cheatsheet

Searching info:

    $ info --apropos=tee
    "(coreutils)tee invocation" -- tee
    "(libc)Control Functions" -- feupdateenv
    "(gawk)Tee Program" -- 'tee' utility

And then `info gawk tee` for example to pull up the third result.

## /usr/share/doc Documentation

A gold mine of documents and sample configuration files. Usually for distributions that are not considered core, and don't offer man or info pages.

## RPM bundled documentation

    $ rpm -qd tmux
    /usr/share/doc/tmux/CHANGES
    /usr/share/doc/tmux/FAQ
    /usr/share/doc/tmux/TODO
    /usr/share/man/man1/tmux.1.gz

# Examples

## grep

[grep](http://www.gnu.org/software/grep/manual/grep.html) prints lines that contain a match for a pattern.

Useful modes:

-   `-r` or `-R` for recursive
-   `-n` show line number
-   `-w` match the whole word
-   `-v` invert match (i.e. blacklist)
-   `-l` just give the file name of matching files
-   `-i` case insensative
-   `-P` Perl style regular expressions

Recursively search all files from the current directory, containing _Romero_, including the line number where they are found:

{% highlight bash %}
\$ grep -rnw . -e 'Romero'
Binary file ./datatsudio/.metadata/.plugins/seg0/c530.dat matches
./files/diff/heros_new:4:Romero,John,671028
./files/heros:7:Romero,John,671028
{% endhighlight %}

The `--include` and `--exclude` are very useful for filtering target files, and the amount of work grep needs to do. Exclude `*.dat` binary files from the above example:

{% highlight bash %}
\$ grep -rnw . -e 'Romero' --exclude '\*.dat'
./grep/diff/heros_new:4:Romero,John,671028
./grep/heros:7:Romero,John,671028
{% endhighlight %}

Perl patterns:

{% highlight bash %}
\$ echo "2016-10-13" | grep -Pe '\d{4}-\d{2}-\d{2}'
2016-10-13
{% endhighlight %}

Color highlight numeric 0 to 5:

{% highlight bash %}
\$ echo "2016-10-13" | grep --color '[0-5]'
2016-10-13
{% endhighlight %}

Overall total of how many times an expression matches:

{% highlight bash %}
\$ grep -rnwo . --include \*.bash --include \*.sh -e 'BASH_REMATCH' | wc -l
12
{% endhighlight %}

## cut

Removes portions from each line of input. By default will use standard input, when no `FILE` specified, or when FILE is `-`.

Select the first field for the colon delimitered file `/etc/passwd`.

    $ cut -d : -f 1 /etc/passwd
    LocalService
    NetworkService
    Guest
    SYSTEM

Hack just the date portion (chars 1-10) off the front of logs, and show the unique dates:

    $ cut -c1-10 dircdds.log | grep -Pe '\d{4}-\d{2}-\d{2}' | sort -h | uniq
    2016-03-21
    2016-03-22
    2016-03-24
    2016-03-29
    2016-04-21

## sort

By default will sort in dictionary order.

    $ cut -d : -f 3 /etc/passwd | sort
    0
    1
    1000
    1001
    107
    11
    113
    12

Useful sort modes:

-   `-h` human numeric (e.g. 2K 3G)
-   `-n` numeric
-   `-r` reverse
-   `-R` random
-   `-u` unique

## tr

For translating (e.g. uppercasing, stripping, truncating, etc) text.

Convert lower case characters to upper.

    $ echo "Linus Torvalds" | tr [:lower:] [:upper:]
    LINUS TORVALDS

Make all lower case characters `o`:

    $ echo "Linus Torvalds" | tr [:lower:] o
    Loooo Tooooooo

Replace the range of characters `a` to `o`, with `@`:

    $ echo "Linus Torvalds" | tr a-o @
    L@@us T@rv@@@s

## wc

Count aggregates of the contents of a file.

By default will show counts of lines, words and bytes.

    $ wc pthreads.make
    7  29 252 pthreads.make

Useful counts:

-   `-l`, `--lines` newlines
-   `-w`, `--words` words
-   `-c`, `--bytes` bytes
-   `-m`, `--chars` characters

Just show the number of lines:

    $ wc -l pthreads.make
    7  pthreads.make

Pipe support just works:

    $ cat 2016-05-01-bash.markdown | wc -l
    1100

## tar

The rock solid archiving tool that you can always lean on.

Create an archive of all of the `/etc` directory:

    tar -cvf etcy.tar /etc 2> /dev/null

-   `-c` create mode
-   `-v` verbose list each file that gets processed
-   `-f` the tar file being delt with

Same, with compression:

    tar -czf etcy.tar.gz /etc 2> /dev/null

-   `-z` (gzip) or `-j` (bzip2) compression

Example compression sizes:

     28M etcy.tar
    4.4M etcy.tar.bz2
    5.6M etcy.tar.gz

Whats in this tarball? `-t` or `--list` has answers:

    tar -tf etcy.tar
    etc/
    etc/idmapd.conf
    etc/openldap/
    etc/openldap/ldap.conf
    ...

Unpack the entire tar:

    tar -xf etcy.tar

Unpack specific things:

    tar -xf etcy.tar etc/openldap/ldap.conf

Results in:

    .
    ├── etc
    │   └── openldap
    │       └── ldap.conf
    ├── etcy.tar
    ├── etcy.tar.bz2
    └── etcy.tar.gz

## rsync

The smart file copier; only transfers blocks that are needed, on the fly compression.

In its simplist form, copy a file locally:

    rsync etcy.tar /mnt/sdd5/backups/

Some optional switches:

-   `-v` verbose
-   `-h` human friendly (`29,242,419 bytes` becomes `29.24M`)
-   `--progress` show progress during transfer
-   `-z` compression

Put a file onto a remote server:

    rsync etcy.tar iris.local:/home/ben/

-   `-a` archive mode for presevation of symlinks, devices, attributes, permissions.
-   `-u` update mode, skips files that are newer on the target
-   `-b` backup
-   `-e` remote shell to use (e.g. `-e ssh`)
-   `--delete` remove files/dirs in the destination, that arent in the source

Complete example:

    rsync --progress -avhe ssh Fedora* schnerg@192.168.1.111:/raid1/sdd1/Software/Big/Linux/Fedora

Only get diffs, do multiple times for dodgy downloads:

    rsync -P rsync://rsync.server.com/path/to/file file

Restrict flow rate:

    rsync --bwlimit=1m fromfile tofile

Mirror web site (with compression and encryption):

    rsync -az -e ssh --delete ~/public_html/ remote.com:'~/public_html'

Synchronise current dir with remote dir:

    rsync -auz -e ssh remote:/dir/ . && rsync -auz -e ssh . remote:/dir/

## sed

For more, see my post on [sed]({% post_url 2015-09-15-sed %}).

## awk

Given a longform (`-l`) list of files and directories, filter only those starting with "pki" and ending with ".jar", outputting only the shortname.

    $ ls -l | awk 'match($10, /^pki.*\.jar$/) { print $10 }'
    pki_jcsi_2.1.2.jar
    pki_jcsi_base_2.1.2.jar
    pki_jcsi_provider_2.1.2.jar
    pki_jcsi_smime_2.1.6.jar

For a deeper survey of awk see my [post]({% post_url 2016-01-17-awk %}).

## ssh (Secure Shell)

`ssh $USER@$HOST command` | Run command on $HOST as $USER
`ssh -f -Y $USER@$HOSTNAME xeyes`| Run GUI command on $HOSTNAME as $USER`scp -p -r $USER@$HOST: file dir/`| Copy with permissions to $USER's home directory on $HOST`scp -c arcfour $USER@$LANHOST: bigfile`| Use faster crypto for local LAN`ssh -g -L 8080:localhost:80 root@$HOST` | Forward connections to $HOSTNAME:8080 out to $HOST:80
`ssh -R 1434:imap:143 root@$HOST`| Forward connections from \$HOST:1434 in to imap:143`ssh-copy-id $USER@$HOST` | Install public key for $USER@$HOST for password-less log in

## wget

Download local browsable verison of a webpage:

    (cd dir/ && wget -nd -pHEKk http://www.bencode.net)

Continue downloading a partial download:

    wget -c http://www.site.org/large.iso

Download specific types (e.g. png) of files:

    wget -r -nd -np -l1 -A '*.png' http://www.slashgot.org

Pipe and process output:

    wget -q -O- http://www.slashdot.org | grep 'a href' | head

Update a local copy of a site:

    wget --mirror http://www.slashdot.org

Schedule a download in the future:

    echo 'wget http://www.lobste.rs' | at 21:00

# BFL of Common Programs

An overview of common programs that generally exist on _nix_ based systems.

| Command      | Description                                                                       |
| ------------ | --------------------------------------------------------------------------------- |
| addpart      | tell the kernel about the existence of a partition                                |
| agetty       | alternative Linux getty                                                           |
| arch         | print machine hardware name                                                       |
| awk          | pattern scanning and processing language                                          |
| base32       | base32 encode/decode data and print to standard output                            |
| base64       | base64 encode/decode data and print to standard output                            |
| basename     | strip directory and suffix from filenames                                         |
| blkdiscard   | discard sectors on a device                                                       |
| blkid        | locate/print block device attributes                                              |
| blockdev     | call block device ioctls from the command line                                    |
| cal          | display a calendar                                                                |
| cat          | concatenate files and print on the standard output                                |
| cfdisk       | display or manipulate a disk partition table                                      |
| chcon        | change file SELinux security context                                              |
| chcpu        | configure CPUs                                                                    |
| chfn         | change your finger information                                                    |
| chgrp        | change group ownership                                                            |
| chmod        | change file mode bits                                                             |
| chown        | change file owner and group                                                       |
| chroot       | run command or interactive shell with special root directory                      |
| chrt         | manipulate the real-time attributes of a process                                  |
| chsh         | change your login shell                                                           |
| cksum        | checksum and count the bytes in a file                                            |
| col          | filter reverse line feeds from input                                              |
| colcrt       | filter nroff output for CRT previewing                                            |
| colrm        | remove columns from a file                                                        |
| column       | columnate lists                                                                   |
| comm         | compare two sorted files line by line                                             |
| cp           | copy files and directories                                                        |
| csplit       | split a file into sections determined by context lines                            |
| ctrlaltdel   | set the function of the Ctrl-Alt-Del combination                                  |
| cut          | remove sections from each line of files                                           |
| date         | print or set the system date and time                                             |
| dd           | convert and copy a file                                                           |
| delpart      | tell the kernel to forget about a partition                                       |
| df           | report file system disk space usage                                               |
| dir          | list directory contents                                                           |
| dircolors    | color setup for ls                                                                |
| dirname      | strip last component from file name                                               |
| dmesg        | print or control the kernel ring buffer                                           |
| du           | estimate file space usage                                                         |
| echo         | display a line of text                                                            |
| eject        | eject removable media                                                             |
| env          | run a program in a modified environment                                           |
| expand       | convert tabs to spaces                                                            |
| expr         | evaluate expressions                                                              |
| factor       | factor numbers                                                                    |
| fallocate    | preallocate or deallocate space to a file                                         |
| false        | do nothing, unsuccessfully                                                        |
| fdformat     | low-level format a floppy disk                                                    |
| fdisk        | manipulate disk partition table                                                   |
| findfs       | find a filesystem by label or UUID                                                |
| findmnt      | find a filesystem                                                                 |
| flock        | manage locks from shell scripts                                                   |
| fmt          | simple optimal text formatter                                                     |
| fold         | wrap each input line to fit in specified width                                    |
| fsck         | check and repair a Linux filesystem                                               |
| fsck.cramfs  | fsck compressed ROM file system                                                   |
| fsck.minix   | check consistency of Minix filesystem                                             |
| fsfreeze     | suspend access to a filesystem (Ext3/4, ReiserFS, JFS, XFS)                       |
| fstrim       | discard unused blocks on a mounted filesystem                                     |
| fuser        | identify processes using files or sockets                                         |
| getopt       | parse command options (enhanced)                                                  |
| grep         | print lines matching a pattern                                                    |
| groups       | print the groups a user is in                                                     |
| head         | output the first part of files                                                    |
| hexdump      | display file contents in hexadecimal, decimal, octal, or ascii                    |
| hostid       | print the numeric identifier for the current host                                 |
| hostname     | show or set the system's host name                                                |
| hwclock      | read or set the hardware clock (RTC)                                              |
| id           | print real and effective user and group IDs                                       |
| install      | copy files and set attributes                                                     |
| ionice       | set or get process I/O scheduling class and priority                              |
| ipcmk        | make various IPC resources                                                        |
| ipcrm        | remove certain IPC resources                                                      |
| ipcs         | show information on IPC facilities                                                |
| isosize      | output the length of an iso9660 filesystem                                        |
| join         | join lines of two files on a common field                                         |
| kill         | terminate a process                                                               |
| kill         | terminate a process                                                               |
| last         | show a listing of last logged in users                                            |
| ldattach     | attach a line discipline to a serial line                                         |
| line         | TODO                                                                              |
| link         | call the link function to create a link to a file                                 |
| ln           | make links between files                                                          |
| logger       | enter messages into the system log                                                |
| login        | begin session on the system                                                       |
| logname      | print user's login name                                                           |
| look         | display lines beginning with a given string                                       |
| losetup      | set up and control loop devices                                                   |
| ls           | list directory contents                                                           |
| lsblk        | list block devices                                                                |
| lscpu        | display information about the CPU architecture                                    |
| lslocks      | list local system locks                                                           |
| lslogins     | display information about known users in the system                               |
| lsof         | list open files                                                                   |
| mcookie      | generate magic cookies for xauth                                                  |
| md5sum       | compute and check MD5 message digest                                              |
| mesg         | display (or do not display) messages from other users                             |
| mkdir        | make directories                                                                  |
| mkfifo       | make FIFOs (named pipes)                                                          |
| mkfs         | build a Linux filesystem                                                          |
| mkfs.bfs     | make an SCO bfs filesystem                                                        |
| mkfs.cramfs  | make compressed ROM file system                                                   |
| mkfs.minix   | make a Minix filesystem                                                           |
| mknod        | make block or character special files                                             |
| mkswap       | set up a Linux swap area                                                          |
| mktemp       | create a temporary file or directory                                              |
| more         | file perusal filter for crt viewing                                               |
| mount        | mount a filesystem                                                                |
| mountpoint   | see if a directory or file is a mountpoint                                        |
| mv           | move (rename) files                                                               |
| namei        | follow a pathname until a terminal point is found                                 |
| newgrp       | log in to a new group                                                             |
| nice         | run a program with modified scheduling priority                                   |
| nl           | number lines of files                                                             |
| nohup        | run a command immune to hangups, with output to a non-tty                         |
| nologin      | politely refuse a login                                                           |
| nproc        | print the number of processing units available                                    |
| nsenter      | run program with namespaces of other processes                                    |
| numfmt       | Convert numbers from/to human-readable strings                                    |
| od           | dump files in octal and other formats                                             |
| partx        | tell the kernel about the presence and numbering of on-disk partitions            |
| paste        | merge lines of files                                                              |
| pathchk      | check whether file names are valid or portable                                    |
| pg           | is a pager, allows viewing one page at a time                                     |
| pivot_root   | change the root filesystem                                                        |
| pr           | convert text files for printing                                                   |
| printenv     | print all or part of environment                                                  |
| printf       | format and print data                                                             |
| prlimit      | get and set process resource limits                                               |
| ps           | report a snapshot of the current processes                                        |
| ptx          | produce a permuted index of file contents                                         |
| pwd          | print name of current/working directory                                           |
| raw          | bind a Linux raw character device                                                 |
| readlink     | print resolved symbolic links or canonical file names                             |
| readprofile  | read kernel profiling information                                                 |
| realpath     | print the resolved path                                                           |
| rename       | rename files                                                                      |
| renice       | alter priority of running processes                                               |
| reset        | terminal initialization                                                           |
| resizepart   | tell the kernel about the new size of a partition                                 |
| rev          | reverse lines characterwise                                                       |
| rm           | remove files or directories                                                       |
| rmdir        | remove empty directories                                                          |
| runcon       | run command with specified SELinux security context                               |
| runuser      | run a command with substitute user and group ID                                   |
| script       | make typescript of terminal session                                               |
| scriptreplay | play back typescripts, using timing information                                   |
| sed          | stream editor for filtering and transforming text                                 |
| seq          | print a sequence of numbers                                                       |
| setarch      | change reported architecture in new program environment and set personality flags |
| setpriv      | run a program with different Linux privilege settings                             |
| setsid       | run a program in a new session                                                    |
| setterm      | set terminal attributes                                                           |
| sfdisk       | display or manipulate a disk partition table                                      |
| sha1sum      | compute and check SHA1 message digest                                             |
| sha2         | message digests                                                                   |
| shred        | overwrite a file to hide its contents, and optionally delete it                   |
| shuf         | generate random permutations                                                      |
| sleep        | delay for a specified amount of time                                              |
| sort         | sort lines of text files                                                          |
| split        | split a file into pieces                                                          |
| stat         | display file or file system status                                                |
| stdbuf       | Run COMMAND, with modified buffering operations for its standard streams.         |
| stty         | change and print terminal line settings                                           |
| su           | run a command with substitute user and group ID                                   |
| sulogin      | single-user login                                                                 |
| sum          | checksum and count the blocks in a file                                           |
| swaplabel    | print or change the label or UUID of a swap area                                  |
| swapoff      | enable/disable devices and files for paging and swapping                          |
| swapon       | enable/disable devices and files for paging and swapping                          |
| switch_root  | switch to another filesystem as the root of the mount tree                        |
| sync         | Synchronize cached writes to persistent storage                                   |
| tac          | concatenate and print files in reverse                                            |
| tail         | output the last part of files                                                     |
| tailf        | follow the growth of a log file                                                   |
| taskset      | set or retrieve a process's CPU affinity                                          |
| tcpdump      | dump traffic on a network                                                         |
| tee          | read from standard input and write to standard output and files                   |
| test         | check file types and compare values                                               |
| timeout      | run a command with a time limit                                                   |
| touch        | change file timestamps                                                            |
| tr           | translate or delete characters                                                    |
| true         | do nothing, successfully                                                          |
| truncate     | shrink or extend the size of a file to the specified size                         |
| tsort        | perform topological sort                                                          |
| tty          | print the file name of the terminal connected to standard input                   |
| tunelp       | set various parameters for the lp (printer) device                                |
| ul           | do underlining                                                                    |
| umount       | unmount file systems                                                              |
| uname        | print system information                                                          |
| unexpand     | convert spaces to tabs                                                            |
| uniq         | report or omit repeated lines                                                     |
| unlink       | call the unlink function to remove the specified file                             |
| unshare      | run program with some namespaces unshared from parent                             |
| uptime       | Tell how long the system has been running.                                        |
| users        | print the user names of users currently logged in to the current host             |
| utmpdump     | dump UTMP and WTMP files in raw format                                            |
| uuidgen      | create a new UUID value                                                           |
| vdir         | list directory contents                                                           |
| vipw         | edit the password, group, shadow-password or shadow-group file                    |
| w            | Show who is logged on and what they are doing.                                    |
| wall         | write a message to all users                                                      |
| wc           | print newline, word, and byte counts for each file                                |
| wdctl        | show hardware watchdog status                                                     |
| whereis      | locate the binary, source, and manual page files for a command                    |
| who          | show who is logged on                                                             |
| whoami       | print effective userid                                                            |
| wipefs       | wipe a signature from a device                                                    |
| write        | write to another user                                                             |
| yes          | output a string repeatedly until killed                                           |

# Resources

-   [The Linux Command Line](https://nostarch.com/tlcl)
-   [Pádraig Brady's Reference Guide](http://www.pixelbeat.org/cmdline.html)
