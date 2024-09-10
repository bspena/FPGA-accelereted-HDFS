echo "[INFO] Create docker network"
docker network create hadoop-network

echo "[INFO] Create master container"
docker run -i -t -d \
    -u "$(id -u)" \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    -v "/home/$(whoami)/thesis/install/container/script/container_utility:/home/$(whoami)/script" \
    -v "/home/$(whoami)/thesis/install/container/hadoop_config:/home/$(whoami)/hadoop_config" \
    --name master \
    --hostname master \
    --network hadoop-network \
    hadoop-image \
    /bin/bash -c "sudo service ssh start && exec /bin/bash"

    ### Note: add --device flag

#opae.io ls | sort | grep -v ".0]" | grep vfio | sed 0000:00:00.0

for i in {0..1}; do

    echo "[INFO] Create slave-$i container"
    docker run -i -t -d \
        -u "$(id -u)" \
        -v "/home/$(whoami)/thesis/install/container/hadoop_config:/home/$(whoami)/hadoop_config" \
        --name slave-$i \
        --hostname slave-$i \
        --network hadoop-network \
        hadoop-image \
        /bin/bash -c "sudo service ssh start && exec /bin/bash"

    ### Note: add --device="${VFIO[$i]}"
done

echo "[INFO] Create workers file"
source ./script/create_workers_file.sh