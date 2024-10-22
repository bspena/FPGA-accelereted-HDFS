#!/bin/bash
# Description: Installer script for VFProxy
# Arguments:
#   None



echo "[INSTALL VFP] Installing VFProxy"
cp ${VFP_ROOT}/assets/vfp-client-site.xml ${HADOOP_VOLUME}/etc/hadoop

# echo "[INSTALL VFP] Installing VFProxy on master"
# cp ${VFP_ROOT}/assets/vfp-client-site.xml ${HADOOP_HOME}/etc/hadoop

# # For each node
# for ip in "${slaves_ip_list[@]}"; do
#     echo "[INSTALL VFP] Installing VFP on $ip"
#     ${SSH_CMD} ${HADOOP_USER}@$ip cp ${VFP_ROOT}/assets/vfp-client-site.xml ${HADOOP_HOME}/etc/hadoop
# done
