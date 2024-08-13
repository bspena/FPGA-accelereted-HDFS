#!/bin/bash

# Run the daemons for the master container or the host machine
if [ "$HOSTNAME" == "master" ] || [ "$HOSTNAME" == "spena-VirtualBox" ]; then
    
    # Stop the daemons
    $HADOOP_HOME/bin/hdfs --daemon stop namenode
    $HADOOP_HOME/bin/hdfs --daemon stop secondarynamenode
    $HADOOP_HOME/bin/yarn --daemon stop resourcemanager
    $HADOOP_HOME/bin/mapred --daemon stop historyserver
    
    # Format the file system
    rm -rf /tmp/hadoop-spena/dfs/data/*
    echo Y | $HADOOP_HOME/bin/hdfs namenode -format     
    
    # Start daemons
    $HADOOP_HOME/bin/hdfs --daemon start namenode
    $HADOOP_HOME/bin/hdfs --daemon start secondarynamenode
    $HADOOP_HOME/bin/yarn --daemon start resourcemanager
    $HADOOP_HOME/bin/mapred --daemon start historyserver
    #$HADOOP_HOME/bin/yarn --daemon start proxyserver
# Run the daemons for the slave container
elif [ "$HOSTNAME" == "slave" ]; then
    
    # Stop the daemons
    $HADOOP_HOME/bin/hdfs --daemon stop datanode
    $HADOOP_HOME/bin/yarn --daemon stop nodemanager
    
    # Remove data
    rm -rf /tmp/hadoop-spena/dfs/data/

    # Start daemons
    $HADOOP_HOME/bin/hdfs --daemon start datanode
    $HADOOP_HOME/bin/yarn --daemon start nodemanager
fi

# To keep the container alive
#sleep infinity