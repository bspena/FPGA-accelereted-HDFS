#!/bin/bash

# SSH command
HDFS_EC_CMD="hdfs ec"

# Enable policies
echo "[ENABLE EC POLICY] Enabling EC policies"
for policy in ${HDFS_EC_POLICIES[*]}; do
    ${HADOOP_HOME}/bin/${HDFS_EC_CMD} -enablePolicy -policy $policy
done

# TODO: select over $1
# POLICY=RS-3-2-1024k
# TODO: set over $2
# POLICY_PATH=/
# echo "[SET EC POLICY] Setting EC policy $POLICY on path $POLICY_PATH"
# ${HDFS_EC_CMD} -disablePolicy -policy $POLICY_DISABLE
# Set policy
# ${HDFS_EC_CMD} -setPolicy -path $POLICY_PATH -policy $POLICY
# Verify
# ${HDFS_EC_CMD} -getPolicy -path $POLICY_PATH


# Unset
# ${HDFS_EC_CMD} -unsetPolicy -path $POLICY_PATH


${HADOOP_HOME}/bin/hdfs ec -enablePolicy -policy $policy