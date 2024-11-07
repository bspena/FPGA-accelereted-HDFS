# Description: Build Docker Image and create docker containers
# Arguments:
#   Number of slave containers
# Local Variables
NUM_SLAVE_CONTAINERS=$1    

echo "[BUILD DOCKER IMAGE] Build docker image with hadoop"
docker build \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t hadoop-image \
    ${CONTAINER_ROOT}/docker/

# Creat docker containers volumes directory
mkdir -p ${CONTAINER_ROOT}/docker_volumes

# Install Hadoop, VFProxy and Apache ActiveMq for containers
source ${HDFS_DEMO_ROOT}/deploy.sh

# Create docker containers
source ${CONTAINER_ROOT}/run_docker_container.sh $NUM_SLAVE_CONTAINERS


# cp  ~/hadoop-OPAE/hadoop-dist/target/hadoop-*.tar.gz  ${HADOOP_ROOT}
#wget -P ${ACTIVEMQ_ROOT} https://archive.apache.org/dist/activemq/5.16.6/apache-activemq-5.16.6-bin.tar.gz