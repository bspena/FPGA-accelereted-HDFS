# Build hadoop docker image
echo "[INFO] Build docker image with hadoop"
docker build \
    --build-arg USER_NAME="${USER}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t hadoop-build \
    /home/$(whoami)/thesis/install/container/docker/

# Copy config/site.xml file into hadoop directory
cp ../hadoop_config/* $HADOOP_HOME/etc/hadoop/

# Create a hadoop network to connect master and slave containers
#echo "[INFO] Create docker network"
#docker network create hadoop-network