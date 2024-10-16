
#!/bin/bash
# Description: Cleanse HDFS data directories across the cluster and reformat DFS
# Parameters:
#   None

# Stop running instance
echo "[HADOOP RECOVERY] Stopping Hadoop deamons (if any)"
${HADOOP_HOME}/sbin/stop-dfs.sh
${HADOOP_HOME}/sbin/stop-yarn.sh
${HADOOP_HOME}/bin/mapred --daemon stop historyserver

# Directories to remove
rm_dirs_master="/home/hadoop/hadoop_storage/disk1/* /tmp/hadoop-*"

rm_dirs_slaves="/home/hadoop/hadoop_storage/disk2/* /tmp/hadoop-*"

echo "[HADOOP RECOVERY] Removing directories ($rm_dirs_master) from master"
rm -rf $rm_dirs_master

for ip in "${slaves_ip_list[@]}"; do
    echo "[HADOOP RECOVERY] Removing directories ($rm_dirs_slaves) from $ip"
    ssh ${HADOOP_USER}@$ip "rm -rf $rm_dirs_slaves"
done

# Prepare log file info
LOG_DIR=${HADOOP_ROOT}/recovery/logs
mkdir -p ${LOG_DIR}
HDFS_FORMAT_LOG=${LOG_DIR}/hdfs_namenode_format_$(date "+%Y-%b-%d_%H:%M").log
# Reformat DFS
${HADOOP_HOME}/bin/hdfs namenode -format -nonInteractive &> ${HDFS_FORMAT_LOG}
echo "[HADOOP RECOVERY] HDFS NameNode format log available in ${HDFS_FORMAT_LOG}"