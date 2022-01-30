---
layout: post
title: "Escaping Google (GoogleApps/GSuite)"
draft: false
slug: "google"
date: "2022-01-30 15:42:47+10:00"
lastmod: "2022-01-30 15:42:49+10:00"
comments: false
categories:
    - life
tags:
    - google
---

# Google

After years of frustration in the Google platform, specifically _G Suite_ (also known as _Google Apps_ or _Google Workspace_), it all recently came to a head for me after I received a couple of Google Nest cameras as gifts last Christmas.

Having been a strong Google proponent since the late 90's, when Google was a cool startup bucking the trend with their famous _do not be evil_ mission, Googles brand within the technical community rose to dizzying heights. Ever since the Google brand has always had a strong influence on me and I have happily recommended their products to people I care about.

As a proud Google supporter, in 2007 I signed up to their _Google Apps for Your Domain_ offering, so I could bind Gmail to a custom domain that I'd just purchased and still use today `bencode.net`. At the time it was a no brainer, priced reasonably and at a time before the company had realised how valuable exploiting their users was.

As computer literate people, we often have differing needs to your average Joe normies:

-   Great IMAP support for CLI programs such as `mbsync` and `mutt`
-   A level of security and privacy controls
-   One online personal identity to keep the chaos of life somewhat in check, I fear the idea of managing several personal-use email accounts
-   Being able to integrate other humans I love into my personal cloud data (e.g. sharing photos, documents) in a safe and secure manner
-   An expectation that surrogate Google related products and services _just work_
-   Reciprocal respect and loyalty as a long time (15 year) evangelist and premium user

Google has failed spectacularly in each. For me personally it has distanced me from their brand in a bad way.

Google has slowly degraded the seemingly harmless _Google Apps_ (later rebranded to _G Suite_ and most recently _Google Workspace_) that so many early adopters and Google champions supported, by shoehorning and treating them as a formal business entities, locking them into an island that could not longer integrate with the greater Google ecosystem, while each year charging more for that privilege.

## Breaking point

A one example of how messed up the situation is, is how I went to setup two new Nest cameras (worth over AUD$600) last (2021) Christmas time. Using _Google Home_ I dove into the setup process and quickly discovered the app failing with _Internal Error Occurred_.

How bad could it be? After doing some trivial research my heart soon sank.

-   Google forums [Nest camera can't be setup bc of G suite usage](https://www.googlenestcommunity.com/t5/Cameras-and-Doorbells/Nest-camera-can-t-be-setup-bc-of-G-suite-usage/td-p/46567)
-   [reddit](https://www.reddit.com/r/Nest/comments/s5fhdn/internal_error_occured_when_installing_nest_cam/)
-   And my personal favourite where Google officially attempt to respond to Josh Wein (a guy in my exact shoes) on [Twitter](https://twitter.com/googlenest/status/1263451357169610753?lang=en)

The comments erupting with screams from some of their most loyal and technical user base:

> The original free Google Apps accounts were marketed towards families and then subsequently became GSuite. All my Google data is now in that account and impossible to transition to a standard @gmail account. There a ton of people in the same situation that need a resolution ASAP

> This is so incredibly lame. Google, the most advanced software company in the world can't even get it so G Suite aka Google Workspaces can't be used to manage other Google software like Nest Devices.

> Late to this party but just as irritated. You’re making your more advanced users suffer. Bad move.

> How absolutely pathetic! I can play music, cast Netflix, change the colour of my lights, look at all my photos etc but if I want a chime for my $300 doorbell I can't because I'm a gSuite user. WT actual F google? How many people have to complain before you actually do something??

> At this point it's a race between Google coming up with a way to fix this and me finally getting around to migrating myself and my family completely away from Google products. I'm confident I'm not alone in that position.

## Migrating off Google

### The plan

I knew this was going to be tough and came up with a high level migration strategy.

TODO: put diagram here

Some of my biggest fears shutting down my Google account:

-   GMail, contacts and calendar: 15 years worth of footprint!
-   Drive: A deep investment. A complex graph of shared items with peers. Throw it all away.
-   Docs and Sheets: Possibly some of my most valuable data, many shared with my close network.
-   YouTube: What would become of my uploaded content? My subscriptions? My premium movie and TV purchases? Would it all be lost? It turns out YES, even with the likes of `youtube-dl` due to DRM...what a burn.
-   Photos: Too many memories of my special people, some that are no longer alive today.
-   Android: What apps do I even have installed. Would my premium apps be lost? It turns out YES, Google don't even allow transfer of ownership to another account. Ouch!
-   G.Pay: Transaction and purchase history?
-   Hangouts: Valuable chats and group discussions I'm a member of?
-   Nest smart home devices: All now just paper weights. HOLY S#&T!?
-   Keep: Valuable little notes
-   Maps: Would all my reviews become read-only or lost forever?

I was surprised that [Google Takeout](https://takeout.google.com/settings/takeout) actually existed. Using takeout its possible to rescue a small portion of your Google digital footprint by exporting it into tarballs. For the data you can export, its a lossy process, e.g. Google Docs get converted to `docx` files. Premium purchases such as Nest devices, YouTube, Music, Android apps are a write off. Sorry.

When you've scrapped as much (or little) of the Google data you can, nuke your account using <https://admin.google.com/>.

## The future

No question this has been traumatic and I expect I'll feel the ramifications (e.g. lost data that's of value to me) for years to come. However it has been a MASSIVE (and expensive) wake up call, mostly around the amount of trust I will give cloud providers moving forward.

A silver lining is that I'm finding alternatives such as [Fastmail](https://www.fastmail.com/) to be vastly superior with features I actually care about such as great IMAP support with `mbsync` and multiple domain support.

Some strategies for me moving forward:

-   Rule 1: Where possible avoid donating my data. Examples:
    -   If I own a legitimate DVD rip watch that using Plex
    -   Always use a VPN
    -   Setup Pi-hole to block ads at the network level
    -   Anonymise search engine queries with DuckDuckGo
    -   Use firefox private sessions and containers
    -   Block all third party cookies (trackers)
    -   When not useful, disable device features like location services on android
-   Rule 2: Don't be lazy
    -   Where feasible run services myself such as for chat (IRC or matrix), git repos, email, [Luke Smith](https://landchad.net/) has done a brilliant job documenting some possibilities
-   Rule 3: Always choose offerings or companies that value the customer and in-turn the privacy and security of their data, even if this privilege comes at a reasonable financial cost to me. Examples:
    -   [Fastmail](https://www.fastmail.com/)
    -   [odysee](https://odysee.com) over YouTube
-   Rule 4: Always use open platforms over evil ones
-   Rule 5: Minimise attack surface and possible future damages by putting too many eggs in any one basket
-   Rule 6: Diversify across as many cloud providers for different services as possible (i.e. beware drinking too much cool-aid on any single platform). That way, when one screws you its just one compartment of your digital life. Examples:
    - Replace *Mail*, *Calendar* and *Contacts* with Fastmail
    - Replace *Drive* with Dropbox
    - Replace *Docs* and *Sheets* with CryptPad
    - Replace *Photos* with ...
    - Replace *Hangouts* with ...
    - Replace *Pixel 4A* with iPhone
-   Rule 7: Have strict non-negotiable boundaries between cloud providers. Examples:
    -   Never buy a movie on YouTube always on Vimeo (if its not available on Vimeo or an open platform, I don't watch it, period)
    -   Never consume music on any platform other than Spotify
-   Rule 8: Regularly export and backup my data
-   Rule 9: Eliminate and avoid use of anything Google, even seemingly small things. This will take time and deliberate effort. Examples:
    - Chrome
    - Chromecast
    - Nest IoT devices
    - Search
    - Android
