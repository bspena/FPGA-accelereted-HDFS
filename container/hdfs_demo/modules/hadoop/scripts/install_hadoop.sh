#!/bin/bash
# Description: Install Hadoop on master and slaves
# Arguments:
#   None


echo "[INSTALL HADOOP] Installing hadoop on master"
tar xf ${HADOOP_ROOT}/hadoop-${HADOOP_VERSION}.tar.gz -C /home/hadoop
mkdir -p ${HADOOP_USER_HOME}/hadoop_storage/disk1

for ip in "${slaves_ip_list[@]}"; do
    echo "[INSTALL HADOOP] Installing hadoop on $ip"
    ssh ${HADOOP_USER}@$ip "tar xf ${HADOOP_ROOT}/hadoop-${HADOOP_VERSION}.tar.gz -C /home/hadoop && \
                            mkdir -p ${HADOOP_USER_HOME}/hadoop_storage/disk2"
done

#source ${HADOOP_ROOT}/scripts/copy_hadoop_config.sh

echo "[COPY CONFIG] Copy hadoop configuration into master"
cp ${HADOOP_ROOT}/assets/sites/* $HADOOP_HOME/etc/hadoop/
cp ${HADOOP_ROOT}/assets/hadoop-env.sh  $HADOOP_HOME/etc/hadoop/hadoop-env.sh 
cp ${HADOOP_ROOT}/assets/workers $HADOOP_HOME/etc/hadoop/workers

for ip in "${slaves_ip_list[@]}"; do
    echo "[COPY CONFIG] Copy Hadoop configuration in $ip"
    ssh ${HADOOP_USER}@$ip "cp  ${HADOOP_ROOT}/assets/sites/* $HADOOP_HOME/etc/hadoop/ && \
                            cp ${HADOOP_ROOT}/assets/hadoop-env.sh  $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
                            cp ${HADOOP_ROOT}/assets/workers $HADOOP_HOME/etc/hadoop/workers"
done