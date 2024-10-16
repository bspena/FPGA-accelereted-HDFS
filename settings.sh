#####################################
# Directories outside the container #
#####################################

# Repo directory
export REPO_ROOT=$(pwd)

# Installation directory
export INSTALL_ROOT=${REPO_ROOT}/install

# Container directories
export CONTAINER_ROOT=${REPO_ROOT}/container
export DOCKER_VOLUMES=${CONTAINER_ROOT}/docker_volumes

# HDFS Demo directories
export HDFS_DEMO_ROOT=${CONTAINER_ROOT}/hdfs_demo
export MODULES_ROOT=${HDFS_DEMO_ROOT}/modules
export HADOOP_ROOT=${MODULES_ROOT}/hadoop
export ACTIVEMQ_ROOT=${MODULES_ROOT}/jms_provider/activemq


####################################
# Directories inside the container #
####################################
export CONTAINER_USER=hadoop
export HADOOP_CONTAINER_HOME=/home/${CONTAINER_USER}