#!/bin/bash
# Description: Install the system sub-modules (VFP, ActiveMQ and Hadoop)
# Arguments:
#   None

# Install Hadoop
echo "[DEPLOY] Installing HADOOP"
source ${HADOOP_ROOT}/scripts/install_hadoop.sh 

# Install VFProxy
echo "[DEPLOY] Installing VFProxy"
source ${VFP_ROOT}/scripts/install_vfp.sh

# Install ActiveMQ
echo "[DEPLOY] Installing ActiveMQ"
source ${ACTIVEMQ_ROOT}/scripts/install_activemq.sh
