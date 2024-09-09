echo "[INFO] Stop the daemons"
$HADOOP_HOME/sbin/stop-dfs.sh
$HADOOP_HOME/sbin/stop-yarn.sh

echo "[INFO] Format the file system"
rm -rf /tmp/hadoop-spena/dfs/data/*
echo Y | $HADOOP_HOME/bin/hdfs namenode -format    