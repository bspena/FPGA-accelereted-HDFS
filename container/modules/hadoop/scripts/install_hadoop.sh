#!/bin/bash
# Description: Install Hadoop on master and slaves
# Arguments:
#   None
# Note:
#   Alternatively, this script could even install the prebuilt Hadoop image

# USE_HADOOP_STOCK=$1 # Not yet implemented

# Target directory
# HADOOP_INSTALL=${HADOOP_USER_HOME}/hadoop_installations
# HADOOP_VERSION=3.4.0
# # Select image
# HADOOP_IMAGE=hadoop-OPAE
# if [ ! -z $USE_HADOOP_STOCK ]; then
#     HADOOP_IMAGE=hadoop
# fi

# Append version -> hadoop-[OPAE-]3.4.0
# HADOOP_IMAGE=${HADOOP_IMAGE}-${HADOOP_VERSION}
# # Source directory for images
# HADOOP_IMAGE_DIR=${HADOOP_ROOT}/install/assets/images

# if [ ! -z $HADOOP_DEBUG ]; then
    # For each node, deploy new image
    # for ip in "${all_nodes_ips[@]}"; do
    #     echo "[INSTALL HADOOP] Installing Hadoop on $ip"
    #     SSH_HADOOP_CMD="ssh ${HADOOP_USER}@$ip"

    #     # Clean up, re-copy tar-ball and extract on all nodes
    #     ${SSH_HADOOP_CMD} mkdir -p $HADOOP_INSTALL
    #     ${SSH_HADOOP_CMD} rm -rf $HADOOP_INSTALL/$HADOOP_IMAGE.tar.gz
    #     ${SSH_HADOOP_CMD} rm -rf $HADOOP_INSTALL/$HADOOP_IMAGE
    #     # Speed-up by sending each one of these in background
    #     ${SSH_HADOOP_CMD} tar xf $HADOOP_TARGZ -C $HADOOP_INSTALL/ &
    # done

    # Wait for all
    # sleep 0.5 & # Mock sleep
    # wait
# fi

# Update configs on slaves
# HADOOP_HOME=${HADOOP_INSTALL}/hadoop-${HADOOP_VERSION}
# for ip in "${all_nodes_ips[@]}"; do
#     echo "[INSTALL HADOOP] Configuring Hadoop for $ip"
#     SSH_HADOOP_CMD="ssh ${HADOOP_USER}@$ip"

#     ## .bashrc
#     # Copy from backup .bashrc
#     ${SSH_HADOOP_CMD} cp ${HADOOP_ROOT}/install/assets/bashrc/hadoop_bashrc \
#         ${HADOOP_USER_HOME}/.bashrc

#     # Copy hadoop-env.sh
#     # - Used to enable user logging
#     ${SSH_HADOOP_CMD} cp ${HADOOP_ROOT}/install/assets/hadoop-env.sh \
#         ${HADOOP_HOME}/etc/hadoop/

#     ## Copy *-site.xml
#     # - core-site.xml
#     # - hdfs-site.xml
#     # - mapred-sched.xml
#     # - yarn-site.xml
#     ${SSH_HADOOP_CMD} cp ${HADOOP_ROOT}/install/assets/sites/* \
#         ${HADOOP_HOME}/etc/hadoop/

#     ## Copy workers file
#     ${SSH_HADOOP_CMD} cp ${HADOOP_ROOT}/install/assets/workers/workers_${RS_SCHEMA} \
#         ${HADOOP_HOME}/etc/hadoop/workers
# done

# Only for master, add SSH identity
# echo "[INSTALL HADOOP] Configuring SSH id for master"
# HADOOP_MASTER_BASHRC=${HADOOP_USER_HOME}/.bashrc
# echo ""                                           >> $HADOOP_MASTER_BASHRC
# echo "# Hadoop master ssh key"                    >> $HADOOP_MASTER_BASHRC
# echo "eval \$(ssh-agent) > /dev/null"             >> $HADOOP_MASTER_BASHRC
# echo "ssh-add -q /home/hadoop/.ssh/master_id_rsa" >> $HADOOP_MASTER_BASHRC


echo "[INSTALL HADOOP] Installing hadoop on master"
tar xf ${HADOOP_ROOT}/hadoop-${HADOOP_VERSION}.tar.gz -C /home/hadoop


for ip in "${slaves_ip_list[@]}"; do
    echo "[INSTALL HADOOP] Installing hadoop on $ip"
    ssh ${HADOOP_USER}@$ip "tar xf ${HADOOP_ROOT}/hadoop-${HADOOP_VERSION}.tar.gz -C /home/hadoop"
done

source ${HADOOP_ROOT}/scripts/copy_hadoop_config.sh