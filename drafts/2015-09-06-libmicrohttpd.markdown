---
layout: post
title: "sed"
date: "2015-08-01 18:45:01"
comments: false
categories: "nix"
---

[sed](http://www.gnu.org/software/sed/) has rocked my world.

> sed (stream editor) isn't an interactive text editor. Instead, it is used to filter text, i.e., it takes text input, performs some operation (or set of operations) on it, and outputs the modified text. sed is typically used for extracting part of a file using pattern matching or substituting multiple occurrences of a string within a file.

Basic syntax:

    sed ' [RANGE] COMMANDS ' [INPUTFILE]

If no `INPUTFILE` is specified, `sed` filters the contents of standard input.

Important commands:

- `#` will comment until the newline.
- `q` command, exit without processing any more commands or input.
- `d` command, delete the pattern space, and start the next cycle. Similarly `a` (append) and `i` (insert) are uber handy.
- `-n` command line switch, is auto-print is not disabled, print the pattern space, then replace the pattern space with the next line of input.
- `-i` command line switch. sed will never destructively overwrite a files contents, unless the `-i` option is used. It also supports auto-creating a backup file like so `-i.bak`.



Kudos to Andrew Mallett and his [Linux Administration with sed and awk](http://www.pluralsight.com/courses/linux-administration-sed-awk) course, which is where some of the below examples came from. I found the offical [GNU documentation](http://www.gnu.org/software/sed/manual/sed.html#sed-Programs) to be the most useful resource.


### Substitution

Sample file *ntp.conf*:

    driftfile  /var/lib/ntp/ntp.draft
    statistics loopstats peerstats clockstats
    filegen loopstats file loopstats type day enable
    server 0.fedora.pool.ntp.org
    server 1.fedora.pool.ntp.org
    server 2.fedora.pool.ntp.org
    server 3.fedora.pool.ntp.org
    server ntp.fedora.org

First cool tip, [nl](http://www.gnu.org/software/coreutils/manual/html_node/nl-invocation.html#nl-invocation) is the boss for quickly line numbering a file:

`nl ntp.conf`

     1  driftfile  /var/lib/ntp/ntp.draft
     2  statistics loopstats peerstats clockstats
     3  filegen loopstats file loopstats type day enable
     4  server 0.fedora.pool.ntp.org
     5  server 1.fedora.pool.ntp.org
     6  server 2.fedora.pool.ntp.org
     7  server 3.fedora.pool.ntp.org
     8  server ntp.fedora.org

So I want to indent all lines beginning with `server`:

    sed ' 4,8 s/^/    /g' ntp.conf

Results in:

    driftfile  /var/lib/ntp/ntp.draft
    statistics loopstats peerstats clockstats
    filegen loopstats file loopstats type day enable
        server 0.fedora.pool.ntp.org
        server 1.fedora.pool.ntp.org
        server 2.fedora.pool.ntp.org
        server 3.fedora.pool.ntp.org
        server ntp.fedora.org

If I just want to see the effected pattern space (note the -n command line switch to restrict to sout to pattern space only, and the presence of the `p` command):

    sed -n ' 4,8 s/^/    / p' ntp.conf

Results in:

        server 0.fedora.pool.ntp.org
        server 1.fedora.pool.ntp.org
        server 2.fedora.pool.ntp.org
        server 3.fedora.pool.ntp.org
        server ntp.fedora.org

Here's another nice substitution example:

    sed -n ' /^ben/ s@/bin/bash@/bin/sh@ p ' /etc/passwd

This beautiful little command, finds all entries starting with `ben` in `/etc/passwd` and replaces `/bin/bash` with `/bin/sh`, and the `p` command spits it out to `sout`.


### Append, Insert and Delete

Delete all lines that start with `server 3` (`\s` to represent an escaped space):

    sed ' /^server\s3.fedora/ d' ntp.conf

Results in:

    driftfile  /var/lib/ntp/ntp.draft
    statistics loopstats peerstats clockstats
    filegen loopstats file loopstats type day enable
    server 0.fedora.pool.ntp.org
    server 1.fedora.pool.ntp.org
    server 2.fedora.pool.ntp.org
    server ntp.fedora.org

Append `server ntp.kernel.org` to the line after any lines that start with `server 0`:

    sed ' /^server\s0/ a server ntp.kernel.org' ntp.conf

Results in:

    driftfile  /var/lib/ntp/ntp.draft
    statistics loopstats peerstats clockstats
    filegen loopstats file loopstats type day enable
    server 0.fedora.pool.ntp.org
    server ntp.kernel.org
    server 1.fedora.pool.ntp.org
    server 2.fedora.pool.ntp.org
    server 3.fedora.pool.ntp.org
    server ntp.fedora.org

And insert, basically same semantics as append, except line before, not after:

    sed ' /^server\s0/ i server ntp.kernel.org' ntp.conf

Results in:

    driftfile  /var/lib/ntp/ntp.draft
    statistics loopstats peerstats clockstats
    filegen loopstats file loopstats type day enable
    server ntp.kernel.org
    server 0.fedora.pool.ntp.org
    server 1.fedora.pool.ntp.org
    server 2.fedora.pool.ntp.org
    server 3.fedora.pool.ntp.org
    server ntp.fedora.org


### Multiple expressions

sed supports blocks:

    sed ' {
      /^server 0/ i ntp.kernel.org
      /^server\s[0-9]\.fedora/ d
    } ' ntp.conf

Or if you are dealing with a large script **sed files** for includes and reuse:

**ntp.sed**

    /^server 0/ i ntp.kernel.org
    /^server\s[0-9]\.fedora/ d

To include it use the `-f` switch like so:

    sed -f ntp.sed /etc/ntp.conf

Once you're ready to roll, plug in the `-i` switch to update the target file:

    sudo sed -i.bak -f ntp.sed /etc/ntp.conf

