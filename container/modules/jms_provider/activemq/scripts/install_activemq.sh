#!/bin/bash
# Description: Installer script for ActiveMQ
# Arguments:
#   None

# for ip in "${all_nodes_ips[@]}"; do
#     echo "[INSTALL ACTIVEMQ] Installing ActiveMQ on $ip"
#     SSH_DEMO_CMD="ssh ${DEMO_USER}@$ip"
#     SSH_HADOOP_CMD="ssh ${HADOOP_USER}@$ip"
    
#     # Create new directory
#     ${SSH_DEMO_CMD} mkdir -p ${ACTIVEMQ_ROOT}

#     # Extract in background
#     ${SSH_DEMO_CMD} tar xf ${ACTIVEMQ_TARGZ} -C ${ACTIVEMQ_ROOT}/
#     # Update permissions for other users
#     ${SSH_DEMO_CMD} sudo chmod -R 777 ${ACTIVEMQ_ROOT}

#     # Copy ActiveMQ jar in Hadoop classpath
#     ${SSH_HADOOP_CMD} cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/

#     # Patch conflict for logging classes between Hadoop installation and ActiveMQ jar
#     ${SSH_HADOOP_CMD} mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
#         ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old
# done

# #############################################
# # Install ActiveMQ on master in Hadoop only #
# #############################################
# echo "[INSTALL ACTIVEMQ] Installing ActiveMQ on master"
# # Copy ActiveMQ jar in Hadoop classpath
# ${SSH_HADOOP_MASTER} cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/
# # Patch conflict for logging classes between Hadoop installation and ActiveMQ jar
# ${SSH_HADOOP_MASTER} mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
#     ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old


echo "[INSTALL ACTIVEMQ] Installing ActiveMQ on master"
# Extract
tar xf ${ACTIVEMQ_TARGZ} -C ${ACTIVEMQ_ROOT}

# Copy ActiveMQ jar in Hadoop classpath
cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/

# Patch conflict for logging classes between Hadoop installation and ActiveMQ jar
mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
    ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old


for ip in "${slaves_ip_list[@]}"; do
    echo "[INSTALL HADOOP] Installing ActiveMQ on on $ip"
    ssh ${HADOOP_USER}@$ip "tar xf ${ACTIVEMQ_TARGZ} -C ${ACTIVEMQ_ROOT} && \
    cp ${ACTIVEMQ_JAR} ${HADOOP_HOME}/share/hadoop/hdfs/ && \
    mv ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar \
        ${HADOOP_HOME}/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar.old"
done