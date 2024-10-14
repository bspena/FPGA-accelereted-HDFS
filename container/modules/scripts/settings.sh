#!/bin/bash

################################
# Target users and directories #
################################

export MODULES_ROOT=/home/hadoop/modules
export HADOOP_USER=hadoop
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Demo user --> host user ???
#DEMO_USER=demo
#DEMO_USER_HOME=/home/${DEMO_USER}
# Hadoop user --> create on the dockerfile
#HADOOP_USER=hadoop
#HADOOP_USER_HOME=/home/${HADOOP_USER}
# Demo directory
#export DEMO_ROOT=$( dirname $( realpath ${BASH_SOURCE[0]} ) )
# Sub-modules installation directory
#export DEMO_SUBMODULES_ROOT=${DEMO_ROOT}/modules

# Cluster nodes
#export HADOOP_MASTER=master # Master


# readarray to read from workers file
# slaves_ip_list=( 
#             rh8-51                          # Single slave
#             rh8-52 rh8-53 rh8-54 rh8-55     # Minimum for RS_3_2
#             # rh8-56 rh8-57 rh8-58 rh8-59     # Minimum for RS_6_3 
#         )
# Array of all nodes, including master
#all_nodes_ips=($HADOOP_MASTER "${slaves_ip_list[@]}")

#############
# Utilities #
#############

# SSH utility command
#SSH_HADOOP_MASTER="ssh ${HADOOP_USER}@${HADOOP_MASTER}"

# PAC address --> not necessary ????
#export PAC_PCIE_SBD=$(lspci -D -d 8086:bcce | head -n1 | awk '{print $1}' | sed "s/\.0//g")

#export HOSTNAME=$(hostname)

#######################
# RS/EC configuration #
#######################

export RS_SCHEMA=${RS_SCHEMA=RS_3_2}
export CELL_LENGTH=$((1024*1024))
export HDFS_EC_POLICIES=(
        RS-3-2-1024k
        RS-OPAE-3-2-1024k
        # RS-6-3-1024k
        # RS-OPAE-6-3-1024k
    )

#######################
# Tools installations #
#######################

export HADOOP_VERSION=3.4.0
export HADOOP_ROOT=${MODULES_ROOT}/hadoop
export HADOOP_HOME=/home/hadoop/hadoop-${HADOOP_VERSION}
export HADOOP_COMMON_HOME=${HADOOP_HOME}
export HADOOP_HDFS_HOME=${HADOOP_HOME}
export HADOOP_MAPRED_HOME=${HADOOP_HOME}
export HADOOP_YARN_HOME=${HADOOP_HOME}
#export HADOOP_TARGZ=${HADOOP_ROOT}/${HADOOP_VERSION}.tar.gz
# export HADOOP_DEBUG=1
# Hadoop (installed)
export HADOOP_LOGS=${HADOOP_HOME}/logs

readarray -t slaves_ip_list < ${HADOOP_ROOT}/config/workers

# ActiveMQ
export ACTIVEMQ_VERSION=5.16.6
export ACTIVEMQ_ROOT=${MODULES_ROOT}/jms_provider/activemq
export ACTIVEMQ_INSTALL=${ACTIVEMQ_ROOT}/apache-activemq-${ACTIVEMQ_VERSION}
export ACTIVEMQ_JAR=${ACTIVEMQ_INSTALL}/activemq-all-${ACTIVEMQ_VERSION}.jar
export ACTIVEMQ_TARGZ=${ACTIVEMQ_ROOT}/apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz

# VFProxy
export VFP_INSTALL=${MODULES_ROOT}/vfproxy
export VFP_ROOT=${VFP_INSTALL}
export VFP_JAR=${VFP_INSTALL}/vfproxy.jar
export VFP_NATIVE_DIR=${VFP_INSTALL}/native
export VFP_LOG_DIR=${MODULES_ROOT}/logs/vfp

# FPGA
#export FPGA_ROOT=${DEMO_SUBMODULES_ROOT}/fpga

# Dump info
# echo "[DEMO INFO] Root directory of demo                    : ${DEMO_ROOT}"
# echo "[DEMO INFO] Unprivileged user for hadoop operations   : ${HADOOP_USER}"
# echo "[DEMO INFO] Privileged user for FPGA interactions     : ${DEMO_USER}"
# echo "[DEMO INFO] PAC address                               : ${PAC_PCIE_SBD}"
# echo "[DEMO INFO] Cluster master                            : ${HADOOP_MASTER}"
# echo "[DEMO INFO] Cluster slaves                            : ${slaves_ip_list[*]}"
# echo "[DEBUG] RS_SCHEMA                                     : ${RS_SCHEMA}"
# echo "[DEBUG] CELL_LENGTH                                   : ${CELL_LENGTH}"
# echo "[DEBUG] HADOOP_ROOT                                   : ${HADOOP_ROOT}"
# echo "[DEBUG] ACTIVEMQ_INSTALL                              : ${ACTIVEMQ_INSTALL}"
# echo "[DEBUG] VFP_INSTALL                                   : ${VFP_INSTALL}"
#echo "[DEBUG] FPGA_ROOT                                     : ${FPGA_ROOT}"