# Repo directory
export REPO_ROOT=$(pwd)

# Installation directory
export INSTALL_ROOT=${REPO_ROOT}/install

# Container directory
export CONTAINER_ROOT=${REPO_ROOT}/container
export CONTAINER_MODULES_ROOT=${CONTAINER_ROOT}/modules
export HADOOP_ROOT=${CONTAINER_MODULES_ROOT}/hadoop
export ACTIVEMQ_ROOT=${CONTAINER_MODULES_ROOT}/jms_provider/activemq


export CONTAINER_USER=hadoop