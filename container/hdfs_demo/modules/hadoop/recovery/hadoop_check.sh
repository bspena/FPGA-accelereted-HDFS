#!/bin/bash
# Description: Check Hadoop deamons state"
# Arguments:
#   None

# Disclaimer
echo "[HADOOP CHECK] Make suke Hadoop has started correctly, since running the launch scripts is no guarantee of that"

# Check on master (Namenode)
echo "[HADOOP CHECK] Checking running java processes on master"
#${SSH_HADOOP_MASTER} jps | grep -e "(NameNode|ResourceManager|SecondaryNameNode)"
jps | grep -e "(NameNode|ResourceManager|SecondaryNameNode)"
echo "[HADOOP CHECK] Expecting:" \
    "   NameNode" \
    "   ResourceManager" \
    "   SecondaryNameNode"

# For each slaves (Datanodes)
echo "[HADOOP CHECK] Checking running java processes on slaves"
for ip in "${slaves_ip_list[@]}"; do
    SSH_HADOOP_CMD="${SSH_CMD} ${HADOOP_USER}@$ip"

    echo "[HADOOP CHECK] Checking running java processes on slave $ip"
    ${SSH_HADOOP_CMD} jps | grep -e "NodeManager|DataNode"
    echo "[HADOOP CHECK] Expecting for a worker node:" \
        "   NodeManager" \
        "   DataNode"
done