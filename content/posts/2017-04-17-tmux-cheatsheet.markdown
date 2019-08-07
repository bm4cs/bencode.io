---
layout: post
title: "Tmux Quick Reference"
date: "2017-04-17 20:17:10"
comments: false
categories: "linux"
---

Kudos to [afair](https://gist.github.com/afair) for putting together this neat [Tmux Cheat Sheet](https://gist.github.com/afair/3489752), which I'm addicted to at the moment.


    ==========================================          ==========================================
                 TMUX COMMAND                                        WINDOW (TAB)
    ==========================================          ==========================================
                                                                                                  
    List    tmux ls                                     List         ^b w
    New          -s <session>                           Create       ^b c
    Attach       att -t <session>                       Rename       ^b , <name>
    Rename       rename-session -t <old> <new>          Last         ^b l               (lower-L)
    Kill         kill-session -t <session>              Close        ^b &
                                                                                                  
    ==========================================          Goto #       ^b <0-9>
                 CONTROLS                               Next         ^b n
    ==========================================          Previous     ^b p
                                                        Choose       ^b w <name>
    Detach       ^b d
    List         ^b =                                   ==========================================
    Buffer       ^b <PgUpDn>                                         PANE (SPLIT WINDOW)
    Command      ^b : <command>                         ==========================================
                                                                                                  
    Copy         ^b [ ... <space> ... <enter>           Show #       ^b q
     Moving         vim/emacs key bindings              Split Horiz  ^b "                --------
     Start          <space>                             Split Vert   ^b %                   |
     Copy           <enter>                             Pane->Window ^b !
    Paste        ^b ]                                   Kill         ^b x
                                                                                                  
    ==========================================          Reorganize   ^b <space>
                 SESSION (Set of Windows)               Expand       ^b <alt><arrow>
    ==========================================          Resize       ^b ^<arrow>
                                                        Resize x n   ^b <n> <arrow>
    New          ^b :new     ^b :new -s <name>
    Rename       ^b $                                   Select       ^b <arrow>
    List         ^b s                                   Previous     ^b {
    Next         ^b (                                   Next         ^b }
    Previous     ^b )                                   Switch       ^b o                  other
                                                        Swap         ^b ^o
                                                        Last         ^b ;

