---
layout: post
title: "ReSharper killer shortcuts"
date: "2013-07-30 21:05:20"
comments: false
categories:
- dev
tags:
- csharp
- resharper
---

[ReSharper](http://www.jetbrains.com/resharper/) (R#) is a tool that I use, love and recommend for anyone who uses Visual Studio. The immediate benefits that it brings and the sheer productivity boost that you gain from using it makes Visual Studio a pleasure to use. I have been using R# for about 2 years now, and keep discovering new gems every now and then, from other R# fans. It compliments Visual Studio so well, sometimes you don't notice that you are actually using R#.

Here's my top 10 list of favorite ReSharper shortcuts.

## Alt + Enter
This will pop up R#'s intelligent context actions menu. If you're still learning C#, R# will teach you some of the more advanced ways of leveraging the language to its fullest, and its mind blowing how clever it really is. It will quickly help you trim down inefficient and ugly code into tighter, more elegant and more efficient C# that you can be proud of. At first it felt like I was taking credit for someones else work for lots of the awesome improvements it has made for me since using it. It will quickly highlight smelly code when working in a team too. Some examples include breaking down unnecessary conditional constructs, converting verbose constructs and statements into nimble/tight LINQ expressions, the removal of generic type arguments that can be inferred, preferred use of implicit typing using `var`, and so many more.

## Ctrl + T
Go to type. R#'s `Ctrl + T` will popup a sweet little text dialog that support wildcards and smart pattern detections, that will take you directly to the source definition of a CLR type (e.g. class, enum, struct). I find this really useful to browse/scan code bases too, e.g. `*repository` will show me all the repository types defined across the solution. Also supports clever pattern detection based on [Camel Humps](http://en.wikipedia.org/wiki/CamelCase), for example the type `MyInsanelyCleverRepository` can be picked up by simply searching for `micr`. This may seem a trivial feature, but the `T` family of R#'s explore shortcuts are profound, and helped me break my addiction to Solution Explorer. Gone are the days when I used to browse a code base using the Solution Explorer pane, expanding and collapsing folders everywhere. You will soon find Solution Explorer slow, cumbersome and unnecessary. In fact I no longer track active items in Solution Explorer, and have now completely unpinned it. 

## Ctrl + Shift + T
Go to file. Similar to go to type (above), but will also include "dumb" (i.e. not typed) files within your solution. For example, where `Ctrl + T` is not useful for locating razor views files (`*.cshtml`), or config files (`*.config`), and so on, because these files do not define actual CLR types, `Ctrl + Shift + T` will index and work with all files in your solution. Same deal as `Ctrl + T`, the dialog supports all kinds of wildcards, and pattern matching.

## Shift + Alt + T
Go to symbol. My last favorite `T` family shortcut. This will provide the same searching functionality across every symbol (i.e. properties, methods, public fields) within the entire solution. Great for 

## Ctrl + R, R
Refactor rename. Smart renaming, that will also take care of references made to the names within comments.

## Shift + Alt + F12
Go to usage. I use this all the time. ReSharper builds a graph of the all dependencies within the solution and how they relate to each other. This will pop a slick little context menu up that shows all usages of a particular type. Hover over each item to get context of how its being used.

## Ctrl + E, U
Surround with template. Quickly wrap existing code, in other code. For example, see a code block that needs to be wrapped with an condition, or a try/catch/finally? Highlight the existing code block, `Ctrl+E, U` then hit the number of the template you want (e.g. 2 for condition, 8 for try/catch, 9 for try/catch/finally). Great feature, for just getting your thoughts out quickly.

## Ctrl + E, C
Code cleanup. Great for new projects, and normalising source code (e.g. common commenting convention, unused namespaces, poorly written statements, code folding). Will auto correct code smells, restructure, and normalise a complete source file. I've found this can offend other developers in your team, so I use this more carefully. For a great, best practiced based template get [StyleCop](http://stylecop.codeplex.com/) which integrate tightly with ReSharper's code cleanup feature.

## Ctrl + E, T
Explore stack trace. This is really cool. Copy and paste stack traces (e.g. from a defect report, or email, etc). Jump back to your solution and hit `Ctrl + E, T`. R# will parse the stack trace and hyperlink each line with the corresponding source code file and line number. Nice!

## Shift + Alt + L
Locate in Solution Explorer. Solution Explorer is still important and sometimes you want to track the item you are currently working with.

## Alt + Up/Down
Go to next/previous member/tag. When browsing within a source file, it will skip the cursor to the top of the next/previous member definition, really nice if you're skimming and don't need to actually get into the details of method/property definitions.


In addition to the main grunt work shortcuts, there are so many other general tiny and clever improvements, you'll be delighted when you stumble across them. Here's a few that come to mind:

- Collapse all - solution explorer still doesn't provide this. Don't collapse folders up individually any more. Collapse ALL of them.
- Syntax highlighting (e.g. things like unused namespaces, unused variables)
- Format strings - tired of matching substitution tokens (`{n}`) with the corresponding variable. R# with smart highlight the matching token with its variable.
- Smart snippets (e.g. type out `nguid` and hit tab to inline insert a new guid)
- Unit test runner
- Razor (MVC) support


This is just the tip of the iceberg, here's some more thorough walkthroughs of features:

- [Navigation and Search](http://www.jetbrains.com/resharper/features/navigation_search.html)
- [Coding Assistance](http://www.jetbrains.com/resharper/features/coding_assistance.html)
- [Code Analysis](http://www.jetbrains.com/resharper/features/code_analysis.html)

