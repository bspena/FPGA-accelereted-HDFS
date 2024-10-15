#!/bin/bash
# Description: Installer script for ActiveMQ
# Arguments:
#   None

echo "[INSTALL ACTIVEMQ] Installing ActiveMQ on master"
# Extract
tar xf ${ACTIVEMQ_TARGZ} -C ${CONTAINER_VOLUME}

# Copy ActiveMQ jar in Hadoop classpath
cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/

# Patch conflict for logging classes between Hadoop installation and ActiveMQ jar
mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
    ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old


for ip in "${slaves_ip_list[@]}"; do
    echo "[INSTALL ACTIVEMQ] Installing ActiveMQ on on $ip"
    ssh ${HADOOP_USER}@$ip "sudo tar xf ${ACTIVEMQ_TARGZ} -C ${CONTAINER_VOLUME} && \
                            cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/ && \
                            mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
                                 ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old && \
                            sudo chmod -R 777 ${ACTIVEMQ_INSTALL}/data"
done