---
layout: post
title: "Octopress workflow"
date: 2013-06-17 20:36
comments: true
categories:
- geek
---

Recently I migrated my hosted FunnelWeb ASP.NET MVC blog, over to [Octopress](http://octopress.org) (a Jekyll based blogging framework) running on Amazon S3. This is a little personal reminder of how sweet it is to spawn a new post.

1. `rake new_post["title"]`
2. Edit newly created `YYYY-MM-DD-post-title.markdown` in octopress's `source/_posts` directory
3. `rake generate`
4. `cd public`
5. `ponyhost push www.bencode.net`

Thanking [Moncef Belyamani](http://www.moncefbelyamani.com/about/) for his uber useful post [How to Install & Configure Octopress on a Mac](http://www.moncefbelyamani.com/how-to-install-and-configure-octopress-on-a-mac/).
