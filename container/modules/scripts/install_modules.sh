#!/bin/bash
# Description: This is the demo deploy script. It copies this DEMO folder to all other nodes and install the system sub-modules (VFP, ActiveMQ and Hadoop)
# Arguments:
#   None

# Check user
# if [ $(whoami) != "demo" ]; then
#     echo "[ERROR] This script must be run as demo user"
#     return -1
# fi

# For each slave node
# NOTE: this could be done with a single compressed archive in production
# for ip in "${slaves_ip_list[@]}"; do
#     echo "[DEMO DEPLOY] Copying DEMO pkg to $ip"
#     # SSH command
#     SSH_DEMO_CMD="ssh ${DEMO_USER}@$ip"

#     # Copy .bashrc to all nodes
#     scp -qr ${DEMO_ROOT}/deploy/assets/demo_bashrc ${DEMO_USER}@$ip:${DEMO_USER_HOME}/.bashrc

#     # Create root directory
#     ${SSH_DEMO_CMD} mkdir -p ${DEMO_ROOT}

#     ##################################
#     # Re-copy DEMO_ROOT to all nodes #
#     ##################################

#     # Setup script
#     scp -qr ${DEMO_ROOT}/settings.sh ${DEMO_USER}@$ip:${DEMO_ROOT} &

#     # FPGA scripts and bitstreams
#     ${SSH_DEMO_CMD} mkdir -p ${DEMO_ROOT}/modules/fpga
#     scp -qr ${DEMO_ROOT}/modules/fpga/setup         ${DEMO_USER}@$ip:${DEMO_ROOT}/modules/fpga &
#     # scp -qr ${DEMO_ROOT}/modules/fpga/FPGA_IMAGES   ${DEMO_USER}@$ip:${DEMO_ROOT} &

#     # Hadoop scripts and artifacts
#     ${SSH_DEMO_CMD} mkdir -p ${DEMO_ROOT}/modules/hadoop/install
#     scp -qr ${DEMO_ROOT}/modules/hadoop/install ${DEMO_USER}@$ip:${DEMO_ROOT}/modules/hadoop &

#     # ActiveMQ scripts and jar
#     ${SSH_DEMO_CMD} mkdir -p ${DEMO_ROOT}/modules/jms_provider/activemq
#     scp -qr ${DEMO_ROOT}/modules/jms_provider/activemq/scripts              ${DEMO_USER}@$ip:${DEMO_ROOT}/modules/jms_provider/activemq &
#     scp -qr ${DEMO_ROOT}/modules/jms_provider/activemq/activemq-*.jar       ${DEMO_USER}@$ip:${DEMO_ROOT}/modules/jms_provider/activemq &

#     # Downloads
#     ${SSH_DEMO_CMD} mkdir -p ${DEMO_ROOT}/downloads/activemq
#     scp -qr ${DEMO_ROOT}/downloads/activemq     ${DEMO_USER}@$ip:${DEMO_ROOT}/downloads/ &

#     # VFP scripts, jar and native
#     ${SSH_DEMO_CMD} mkdir -p ${DEMO_ROOT}/modules/vfproxy
#     scp -qr ${DEMO_ROOT}/modules/vfproxy ${DEMO_USER}@$ip:${DEMO_ROOT}/modules/ &

#     # Unnecessary
#     # scp -qr ${DEMO_ROOT}/tests         ${DEMO_USER}@$ip:${DEMO_ROOT} &
#     # scp -qr ${DEMO_ROOT}/deploy        ${DEMO_USER}@$ip:${DEMO_ROOT} &
#     # scp -qr ${DEMO_ROOT}/README.md     ${DEMO_USER}@$ip:${DEMO_ROOT} &
# done
# Wait for children
# sleep 0.5 & # Mock sleep
# wait


# Update permissions for other users
# for ip in "${all_nodes_ips[@]}"; do
#     SSH_DEMO_CMD="ssh ${DEMO_USER}@$ip"
#     ${SSH_DEMO_CMD} sudo chmod -R 777 ${DEMO_ROOT}
# done

# Install Hadoop
source ${HADOOP_ROOT}/scripts/install_hadoop.sh 

# Install VFProxy
#source ${VFP_ROOT}/scripts/install_vfp.sh
##############
# NOTE: install_vfp bash script copy vfp-client-site.xml to ${HADOOP_HOME}/etc/hadoop, I have a script that copy 
#       site xml files in the same directory
##############

# Install ActiveMQ
source ${ACTIVEMQ_ROOT}/scripts/install_activemq.sh
