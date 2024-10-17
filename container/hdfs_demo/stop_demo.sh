#!/bin/bash
# Description: Stop running demo sub-modules (VFP, ActiveMQ and Hadoop) and any other java process.
# Arguments:
#   None


# Hadoop
echo "[DEMO STOP] Stopping Hadoop deamons (if any)"
# ${SSH_HADOOP_MASTER} stop-yarn.sh
# ${SSH_HADOOP_MASTER} stop-dfs.sh
${HADOOP_HOME}/sbin/stop-dfs.sh
${HADOOP_HOME}/sbin/stop-yarn.sh
${HADOOP_HOME}/bin/mapred --daemon stop historyserver

# ActiveMQ
for ip in "${slaves_ip_list[@]}"; do
    # SSH command
    SSH_HADOOP_CMD="${SSH_CMD} ${HADOOP_USER}@$ip"
    # Stop ActiveMQ
    # NOTE: this will also cause all attached VFPs to terminate
    echo "[DEMO STOP] Stopping ActiveMQ on $ip"
    ${SSH_HADOOP_CMD} source ${ACTIVEMQ_ROOT}/scripts/stop_activemq.sh > /dev/null
done

# Kill all residual Java processes
# NOTE: this might be overkill, but works for a demo

echo "[DEMO INIT] Killing all java processes on master"
killall java

for ip in "${slaves_ip_list[@]}"; do
    echo "[DEMO STOP] Killing all Java processes on $ip"
    SSH_HADOOP_CMD="${SSH_CMD} ${HADOOP_USER}@$ip"
    ${SSH_HADOOP_CMD} killall java
done