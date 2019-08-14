---
layout: post
title: "Linux Operation"
date: "2017-05-20 21:05:20"
comments: false
categories: [nix]
---

Day to day operation of Linux systems.


# Booting

    shutdown -r +5 System going down for a reboot  #wall broadcast msg
    shutdown -c  #cancel reboot
    shutdown -r 00:00  #schedule for midnight
    shutdown -h +5  #halt system in 5 mins
    shutdown -h now

Alternatively, just use systemd:

    systemctl halt
    systemctl shutdown
    systemctl poweroff:29

Runlevels (legacy):

    init 0  #shutdown
    init 6  #reboot


## Targets

A systemd target is simply a collection of units. Several types of units are possible `systemctl -t help`:

- service
- socket
- busname
- target
- device
- mount
- automount
- swap
- timer
- path
- slice
- scope

Unit configuration files live in `/usr/lib/systemd/system` e.g `/usr/lib/systemd/system/sshd.service`, and define the service unit; pre and post execution commands, core runtime command, dependencies on other targets and/or units, targets that include this unit (e.g. `multi-user.target`) and so on. Most common targets:

- `multi-user.target` - a multi user, text based computing environment
- `graphical.target` - 
- `emergency.target` - root shell, read-only file system
- `rescue.target` - a bare bones troubleshooting environment

The `isolate` command allows switching between targets (not all targets support "isolation"):

    systemctl isolate multi-user.target

The default target can be altered with `set-default` (symlink housekeeping):

    systemctl set-default graphical.target

The target used at boot time can be specified by altering the GRUB bootloader. Interupt the boot sequence, and use `e` to modify the GRUB script, find the kernel init string (starting with `linux16`) and add, for example, `systemd.unit=rescue.target` to the end. `C X` to continue boot.


## Interrupting Boot

By appending `rd.break` to the kernel init string in the GRUB boot loader (press `esc` to present the boot menu, select the target kernel, and then `e` to modify it), will inject us into the `initramfs` emergency mode shell; a barebones mini environment. `C X` to continue boot. `/sysroot` contains the eventual root mount point, that `initramfs` has prepared. Since we have interupted the init process, `/sysroot` has been "re-rooted" yet.

    mount -oremount, rw /sysroot   #get r/w perms
    chroot /sysroot   #chroot jail
    passwd root   #yup
    touch /.autorelabel   #selinux relabelling during next boot
    exit   #exit chroot jail
    exit   #exit initramfs shell

SELinux contexts will be lost. Some options include creating `.autorelabel` in root (i.e. `touch /.autorelabel`). SELinux will relabel everything.



# Process Management

## Listing

    ps aux | gnome  #manually grep ps output
    pgrep gnome  #grep for processes
    pgrep gnome -l  #show process names
    pgrep -u ben -l vi  #processes by user
    pgrep -v -u root  #v flag inverts, so all processes not owned by root


## Killing

    pkill httpd   #kill 15 all processes that grep to httpd
    kill -l   #list signal table
    pkill -SIGTERM httpd   #explicit signal


Important signals:

- 1 SIGHUP hang up, similar to closing a terminal window
- 2 SIGINT interupt, similar to `^C`
- 3 SIGQUIT, request process to quit
- 9 SIGKILL, brutally murder the process immediately
- 15 SIGTERM, gracefully terminate
- 18 SIGCONT, continue a stopped process
- 19 SIGSTOP, suspend process
- 20 SIGTSTP, optional suspend

Kill by TTY (terminal):

    $ w
    03:03:21 up 41 min,  4 users,  load average: 0.05, 0.04, 0.05
    USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
    ben      :0       :0               02:26   ?xdm?  36.10s  0.11s gdm-session-worker [pam/gdm-password]
    ben      pts/0    :0               02:26    1.00s  0.09s  2.15s /usr/libexec/gnome-terminal-server
    john     pts/2    localhost        03:02    9.00s  0.05s  0.03s vim test
    $ pkill -t pts/2
    $ pkill -u john sshd


## Jobs and Suspending

- Work can be put to the background by adding an ampersand `&` to the end
- Job ids should always be prefixed with a percent `%`, to make it clear a job is being referred to.

    $ (while true; do echo -n "my program" >> ~/output.txt; sleep 1; done) &
    [1] 5398
    
    $ jobs
    [1]+  Running                 ( while true; do echo -n "my program" >> ~/output.txt; sleep 1; done ) &
    
    $ kill -SIGSTOP %1
    $ jobs
    [1]+  Stopped                 ( while true; do echo -n "my program" >> ~/output.txt; sleep 1; done ) &
    
    $ kill -SIGCONT %1
    $ jobs
    [1]+  Running                 ( while true; do echo -n "my program" >> ~/output.txt; sleep 1; done ) &
    
    $ kill 15 %1
    $ jobs
    [1]+  Terminated              ( while true; do echo -n "my program" >> ~/output.txt; sleep 1; done )


# Priority and Nice

Nice levels range from **-20** to **19**, **-20** representing the most favourable, and **19** the least favourable.

    $ ps aux   #BSD style, processes for all users, is user oriented format, a = BSD tsyle, x = all processes, u = user oriented format
    $ ps axo pid,comm,nice   #the PID, command and nice level
    $ ps -u root   #POSIX style all procs owned by root


Nice experiment:

    $ dd if=/dev/zero of=~/tmp/bigfile bs=1M count=1024
    $ time nice -n 19 tar -cvf bigfile.tar bigfile
    bigfile
    
    real  0m3.022s
    user  0m0.018s
    sys 0m1.185s
    
    # time nice -n -20 tar -cvf bigfile.tar bigfile
    bigfile

    real  0m2.909s
    user  0m0.018s
    sys 0m1.295s



Nice experiment two:

Start Apache with systemd:

    # systemctl start httpd
    # ps axo comm,pid,nice | grep httpd
    httpd            3874   0
    httpd            3940   0
    httpd            3941   0
    httpd            3942   0
    httpd            3943   0
    httpd            3944   0

Kill processes and restart them with nice:

    # systemctl stop httpd
    # nice -n 10 httpd
    # ps axo comm,pid,nice | grep httpd
    httpd            4344  10
    httpd            4345  10
    httpd            4346  10
    httpd            4347  10
    httpd            4348  10
    httpd            4349  10

Renice:

    # renice -n 3 $(pgrep httpd)
    4344 (process ID) old priority 10, new priority 3
    4345 (process ID) old priority 10, new priority 3
    4346 (process ID) old priority 10, new priority 3
    4347 (process ID) old priority 10, new priority 3
    4348 (process ID) old priority 10, new priority 3
    4349 (process ID) old priority 10, new priority 3
    
    # ps axo comm,pid,nice | grep httpd
    httpd            4344   3
    httpd            4345   3
    httpd            4346   3
    httpd            4347   3
    httpd            4348   3
    httpd            4349   3


# Load Averages and Activity

The `w` program, not only shows users that are currently logged into the system, but CPU load averages across 1, 5 and 15 minute time spans.

    $ w
    21:46:11 up  1:56,  1 user,  load average: 0.43, 0.53, 0.75
    USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
    ben      tty2      19:49    1:56m 51:16   1.02s /opt/google/chrome/chrome

A personal favourite when it comes to process monitoring, is `top`, a curses based CLI that dynamically refreshes based on activity taking place. Useful shortcuts:

- `m` toggle memory display modes in the HUD
- `t` toggle tasks display modes in the HUD
- `l` toggle uptime (first line) display in the HUD
- `V` forest view (parent/child)
- `H` thread view (as opposed to process view)
- `B` bold key fields
- `k` kill
- `r` renice
- `z` toggle color/mono display
- `L` locate/search

Launch options:

- `top -n 2` start, refresh twice, then terminate.
- `top -d 2` start, setting the refresh polling interval to 2 seconds



# System Logging

Traditionally was powered by the `rsyslogd` daemon (with logs typically stored in `/var/log`), however with RHEL 7, systemd's log subsystem `journald` has been included.

`journald` by default temporarily stores its state in `/run/log/journal`, which is not peristent across system reboots. To change this default behaviour, `/etc/systemd/journald.conf` and set `Storage=persistent`. Then a reload on the `systemd` daemon. Logs will now be stored in `/var/log/journal`.

`logrotate` is 


