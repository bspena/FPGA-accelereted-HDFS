# Build hadoop docker image
echo "[INFO] Build docker image with hadoop"
docker build \
    --build-arg USER_NAME="${USER}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t hadoop-build_v1 \
    /home/$(whoami)/thesis/install/container/docker/

# Copy config/site.xml file into hadoop directory
#cp ../hadoop_config/* $HADOOP_HOME/etc/hadoop/

echo "[INFO] Create docker network"
docker network create hadoop-network

echo "[INFO] Create master container"
docker create -i -t \
    -u "$(id -u)" \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    --name master \
    --hostname master \
    --network hadoop-network \
    hadoop-build_v1 \
    /bin/bash

    ### Note: add --device flag


#opae.io ls | sort | grep -v ".0]" | grep vfio | sed 0000:00:00.0

for i in {0..1}; do

    echo "[INFO] Run slave-$i container"
    docker run -i -t -d \
        -u "$(id -u)" \
        --name slave-$i \
        --hostname slave-$i \
        --network hadoop-network \
        hadoop-build_v1 \
        /bin/bash

    ### Note: add --device="${VFIO[$i]}"

done


##### Copy file with docker cp