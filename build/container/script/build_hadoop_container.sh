# Build hadoop docker image
echo "######################################"
echo "[INFO] Build docker image with hadoop"
echo "######################################"
docker build \
    --build-arg USER_NAME="${USER}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t hadoop-build_v0 \
    /home/$(whoami)/thesis/build/container/docker/

# Copy config/site.xml file into hadoop directory
cp ../hadoop_config/* $HADOOP_HOME/etc/hadoop/

# Create a hadoop network to connect master and slave containers
echo "############################"
echo "[INFO] Create docker network"
echo "############################"
docker network create hadoop-networkS