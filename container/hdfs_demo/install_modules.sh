#!/bin/bash
# Description: Install the system sub-modules (VFP, ActiveMQ and Hadoop)
# Arguments:
#   None

# Install Hadoop
source ${HADOOP_ROOT}/scripts/install_hadoop.sh 

# Install VFProxy
source ${VFP_ROOT}/scripts/install_vfp.sh

# Install ActiveMQ
source ${ACTIVEMQ_ROOT}/scripts/install_activemq.sh
