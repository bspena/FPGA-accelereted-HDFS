# Run the daemons for the master container
if [ "$HOSTNAME" == "master_container" ]; then
    rm -rf /tmp/hadoop-root/dfs/data/*
    echo Y | $HADOOP_HOME/bin/hdfs namenode -format     
    $HADOOP_HOME/bin/hdfs --daemon start namenode
    $HADOOP_HOME/bin/yarn --daemon start resourcemanager
    $HADOOP_HOME/bin/mapred --daemon start historyserver
    $HADOOP_HOME/bin/yarn --daemon start proxyserver
fi

# Run the daemons for the slave container
if [ "$HOSTNAME" == "slave_container" ]; then
    rm -rf /tmp/hadoop-root/dfs/data/*
    $HADOOP_HOME/bin/hdfs --daemon start datanode
    $HADOOP_HOME/bin/yarn --daemon start nodemanager
fi