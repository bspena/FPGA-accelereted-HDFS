#!/bin/bash
echo "[LAUNCH ACTIVEMQ] Launching ActiveMQ on master"
ACTIVEMQ_OPTS_MEMORY="-Xms1G -Xmx16G" ${ACTIVEMQ_INSTALL}/bin/activemq start > /dev/null

#sleep 2

for ip in "${slaves_ip_list[@]}"; do
    echo "[LAUNCH ACTIVEMQ]] Launching ActiveMQ on $ip"
    ssh ${HADOOP_USER}@$ip "ACTIVEMQ_OPTS_MEMORY='-Xms1G -Xmx16G' ${ACTIVEMQ_INSTALL}/bin/activemq start > /dev/null"
    #sleep 2
done