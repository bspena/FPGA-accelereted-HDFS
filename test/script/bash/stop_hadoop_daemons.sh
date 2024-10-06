echo "[INFO] Stop the daemons"
$HADOOP_HOME/sbin/stop-dfs.sh
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/bin/mapred --daemon stop historyserver

echo "[INFO] Format the file system"
rm -rf /tmp/hadoop-$(whoami)/dfs/data/*

cat  ~/hadoop_config/workers | xargs -I {} bash -c '
    ssh $(whoami)@"{}" "rm -rf /tmp/hadoop-$(whoami)/dfs/data/*"
'

echo Y | $HADOOP_HOME/bin/hdfs namenode -format    