# Arguments:
#   Number of slave containers

echo "[BUILD DOCKER IMAGE] Build docker image with hadoop"
# docker build \
#     --build-arg USER_ID="$(id -u)" \
#     --build-arg GROUP_ID="$(id -g)" \
#     -t hadoop-image \
#     ${CONTAINER_ROOT}/docker/

# cp  ~/hadoop-OPAE/hadoop-dist/target/hadoop-*.tar.gz  ${HADOOP_ROOT}

wget -P ${ACTIVEMQ_ROOT} https://archive.apache.org/dist/activemq/5.16.6/apache-activemq-5.16.6-bin.tar.gz

source ${CONTAINER_ROOT}/deploy_docker_container.sh $1