---
layout: post
title: "Installing Hadoop on OSX"
date: "2015-02-22 20:28:01"
comments: false
categories: "Java,Hadoop"
---

## Step 1: Download

Download the latest distribution from the [Apache Hadoop website](http://hadoop.apache.org/). Example:

    cd ~/Downloads
    wget http://apache.mirror.serversaustralia.com.au/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
    cd /usr/local
    tar zxvf ~/Downloads/hadoop-2.6.0.tar.gz


## Step 2: Setup JAVA_HOME and HADOOP_HOME

Depending on your OS and shell. For example on OSX:

    vim ~/.bash_profile

Ensure the `JAVA_HOME` and `HADOOP_HOME` variables are defined. For ease of use, tack them onto the `PATH` variable:

    export JAVA_HOME=$(/usr/libexec/java_home)
    export HADOOP_HOME=/usr/local/Cellar/hadoop/2.6.0
    export PATH=$PATH:$HADOOP_HOME/bin

Make sure you refresh your shell, to pickup the new configuration.


## Step 3: Create users and groups

    groupadd hadoop
    useradd -g hadoop yarn
    useradd -g hadoop hdfs
    useradd -g hadoop mapred

YARN is responsible for scheduling and resource allocation.
HDFS  

## Step 4: Create data and log directories

    sudo mkdir -p /var/data/hadoop/hdfs/nn
    sudo mkdir -p /var/data/hadoop/hdfs/snn
    sudo mkdir -p /var/data/hadoop/hdfs/dn
    sudo chown -R root:staff /var/data/hadoop/hdfs

Okay, now somewhere to put the logs.

    sudo mkdir $HADOOP_HOME/logs
    sudo chmod g+w logs
    sudo chown root:staff logs

