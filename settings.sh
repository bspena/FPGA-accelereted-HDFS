# Repo directory
export REPO_ROOT=$(pwd)

# Installation directory
export INSTALL_ROOT=${REPO_ROOT}/install

# Container directory
export CONTAINER_ROOT=${REPO_ROOT}/container
export HDFS_DEMO_ROOT=${CONTAINER_ROOT}/hdfs_demo
export MODULES_ROOT=${HDFS_DEMO_ROOT}/modules
export HADOOP_ROOT=${MODULES_ROOT}/hadoop
export ACTIVEMQ_ROOT=${MODULES_ROOT}/jms_provider/activemq


export CONTAINER_USER=hadoop