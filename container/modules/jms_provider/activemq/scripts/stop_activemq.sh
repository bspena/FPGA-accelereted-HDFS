#!/bin/bash
echo "[STOP ACTIVEMQ] Stop ActiveMQ on master"
ACTIVEMQ_OPTS_MEMORY="-Xms1G -Xmx16G" ${ACTIVEMQ_INSTALL}/bin/activemq stop

for ip in "${slaves_ip_list[@]}"; do
    echo "[STOP ACTIVEMQ] Stop ActiveMQ on $ip"
    ssh ${HADOOP_USER}@$ip "ACTIVEMQ_OPTS_MEMORY='-Xms1G -Xmx16G' ${ACTIVEMQ_INSTALL}/bin/activemq stop"
done