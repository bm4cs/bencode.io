---
layout: post
draft: false
title: "Managing multiple SSH keys for GitHub accounts"
slug: "multi-ssh"
date: "2025-12-12 08:07:00+1100"
lastmod: "2025-12-12 08:07:00+1100"
comments: false
categories:
  - ssh
  - devlife
  - dev
  - nix
---

- [Set Up SSH Config](#set-up-ssh-config)
- [How to Use It](#how-to-use-it)
- [Per-Repo Git Identity](#per-repo-git-identity)

Now I'm involved in multiple businesses, I'm finding I need to frequently juggle multiple SSH key pairs (aka identities) with _choose your favourite git offering_ (e.g. GitHub). When I push and pull to origins on the same machine, I need to alternate the identities I use.

The best approach is to use an **SSH config file** to define host aliases. This lets you seamlessly use different keys without manually switching anything.

## Set Up SSH Config

Edit (or create) `~/.ssh/config`:

```
# Personal GitHub
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work GitHub
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

## How to Use It

When cloning or setting remotes, use your alias instead of `github.com`:

```bash
# Personal repo
git clone git@github-personal:myusername/repo.git

# Work repo
git clone git@github-work:mycompany/repo.git
```

For existing repos, update the remote:

```bash
git remote set-url origin git@github-personal:myusername/repo.git
```

## Per-Repo Git Identity

You'll also want different commit author info. In each repo:

```bash
git config user.name "Your Name"
git config user.email "you@example.com"
```

Or set a global default and override per-repo, or use **conditional includes** in `~/.gitconfig`:

```
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
```

Then `~/.gitconfig-work` contains your work name/email.

This approach is clean because the identity is "baked into" each repo's remote URL—no need to remember to switch anything when you push or pull.
