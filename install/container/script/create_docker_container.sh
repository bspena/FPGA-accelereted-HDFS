echo "[INFO] Create docker network"
docker network create hadoop-network

echo "[INFO] Create master container"
docker run -i -t -d \
    -u "$(id -u)" \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    --name master \
    --hostname master \
    --network hadoop-network \
    hadoop-build_v1 \
    /bin/bash -c "sudo service ssh start && exec /bin/bash"

    ### Note: add --device flag


#opae.io ls | sort | grep -v ".0]" | grep vfio | sed 0000:00:00.0

for i in {0..1}; do

    echo "[INFO] Create slave-$i container"
    docker run -i -t -d \
        -u "$(id -u)" \
        --name slave-$i \
        --hostname slave-$i \
        --network hadoop-network \
        hadoop-build_v1 \
        /bin/bash -c "sudo service ssh start && exec /bin/bash"

    ### Note: add --device="${VFIO[$i]}"
done


echo "[INFO] Copy hadoop archive to containers"
docker cp /home/$(whoami)/hadoop/hadoop-dist/target/hadoop-3.3.5.tar.gz master:/home/$(whoami)/
docker exec master /bin/bash -c "tar -xzf hadoop-3.3.5.tar.gz -C /home/\$(whoami)"

slaves=$(docker ps --filter "name=slave-" --format "{{.Names}}")

for s in $slaves; do
    docker cp /home/$(whoami)/hadoop/hadoop-dist/target/hadoop-3.3.5.tar.gz "$s":/home/$(whoami)/
    docker exec "$s" /bin/bash -c "tar -xzf hadoop-3.3.5.tar.gz -C /home/\$(whoami)"
done

echo "[INFO] Copy utility scripts into master container"
docker cp /home/$(whoami)/thesis/install/container/script/container_utility master:/home/$(whoami)/utility

echo "[INFO] Setup passphraseless ssh"
docker exec master /bin/bash -c "source utility/ssh_no_pass.sh"

echo "[INFO] Create workers file"
source ./script/create_workers_file.sh

docker stop $(docker ps -a -q)