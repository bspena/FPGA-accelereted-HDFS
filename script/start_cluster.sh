#!/bin/bash

# Stop HDFS deamons,YARN deamons and JobHistoryServer
$HADOOP_HOME/sbin/stop-dfs.sh                      
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/bin/mapred --daemon stop historyserver

# Clear the data directory
rm -rf /tmp/hadoop-$(whoami)/dfs/data/*

# Format the filesystem
echo Y | $HADOOP_HOME/bin/hdfs namenode -format          

# Start HDFS deamons,YARN deamons and JobHistoryServer
$HADOOP_HOME/sbin/start-dfs.sh                     
$HADOOP_HOME/sbin/start-yarn.sh
$HADOOP_HOME/bin/mapred --daemon start historyserver

# Make the HDFS directories required to execute MapReduce jobs
$HADOOP_HOME/bin/hdfs dfs -mkdir /user             
$HADOOP_HOME/bin/hdfs dfs -mkdir /user/$(whoami)

# Copy the input files into the distributed filesystem
$HADOOP_HOME/bin/hdfs dfs -mkdir input
$HADOOP_HOME/bin/hdfs dfs -put $HADOOP_HOME/etc/hadoop/*.xml input