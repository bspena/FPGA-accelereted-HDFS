#!/bin/bash
# Description: Installer script for ActiveMQ
# Arguments:
#   None

echo "[INSTALL ACTIVEMQ] Installing ActiveMQ"
wget -P ${DOCKER_VOLUMES} https://archive.apache.org/dist/activemq/5.16.6/apache-activemq-5.16.6-bin.tar.gz
tar xf ${DOCKER_VOLUMES}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz -C ${DOCKER_VOLUMES}

# Copy ActiveMQ jar in Hadoop classpath
cp ${ACTIVEMQ_VOLUME}/activemq-all-${ACTIVEMQ_VERSION}.jar ${HADOOP_VOLUME}/share/hadoop/hdfs/

# Patch conflict for logging classes between Hadoop installation and ActiveMQ jar
mv ${HADOOP_VOLUME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
    ${HADOOP_VOLUME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old

# echo "[INSTALL ACTIVEMQ] Installing ActiveMQ on master"
# # Extract
# tar xf ${ACTIVEMQ_TARGZ} -C ${CONTAINER_VOLUME}

# # Copy ActiveMQ jar in Hadoop classpath
# cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/

# # Patch conflict for logging classes between Hadoop installation and ActiveMQ jar
# mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
#     ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old


# for ip in "${slaves_ip_list[@]}"; do
#     echo "[INSTALL ACTIVEMQ] Installing ActiveMQ on on $ip"
#     ${SSH_CMD} ${HADOOP_USER}@$ip "sudo tar xf ${ACTIVEMQ_TARGZ} -C ${CONTAINER_VOLUME} && \
#                             cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/ && \
#                             mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
#                                  ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old && \
#                             sudo chmod -R 777 ${ACTIVEMQ_INSTALL}/data"
# done