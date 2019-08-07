---
layout: post
title: "Managing Database Evolution"
date: "2010-06-05 22:47:03"
comments: false
categories: "Software"
---



On a new clients site the other day, observed that over time the more companies I work for the deeper my knowledge for applying effective work practices becomes. In other words, over time you see things that work well, and things that don’t. I’m talking about simple practices that when applied to teams result more quality and/or efficient software.

Databases and their associated artefacts (functions, triggers, message broker queues and so on) should be managed, and versioned. Again a simple problem with a simple solution, but in the real world tends to be practiced poorly.

In the source repository that the team uses, create a directory hierarchy that implies some sort of sequence (e.g. prefix with a numeral). Start off with scripting the database and its requirements, such as filegroup options and collation types etc. Remove any code generated guff, to keep the scripts as clean and as readable as possible. Then move on to tables, and then objects that work with the tables such as foreign keys, triggers, procedures, functions. An example structure could look like this:


- 01 Database
- 02 Schema
- 03 Tables
- 04 Foreign Keys
- 05 Triggers
- 06 Stored Procedures
- 07 Functions
- 08 Queues
- ...
- 10 Data


Over the lifecycle of the project this structure should be completely populated with the necessary artifacts to build the target database from scratch. No restoration of backups needed.

Because the number of scripts contained in a single directory could become overwhelming with time, a copy of the below batch script “all.bat” could be placed in each directory that enumerates and concatenates every “.sql” file in the containing directory to produce one large sql script “all.sql”. Running in 150 stored procedure scripts then become a simple matter as running in “all.sql” contained in the stored procedure hive.


    @echo off
    
    @rem type NUL>"_all.sql"
    del /F /Q "_all.sql"
    
    for /f %%a in ('dir /b *.sql') do (
    type %%a >> _all.sql
    )


When it comes to scripting the data (lookup data and sample data should be versioned), I find it hard to pass up the simplicity of the [sp_generate_inserts](http://vyaskn.tripod.com/code.htm) gem I found a few years ago. Its basically a stored procedure that get created in your master database (therefore resolvable in any db's on the same instance), that provides a rich set of options for scripting your data (e.g. `EXECUTE sp_generate_inserts footable, @ommit_identity=1`).


