# Define the array of devices
devices=($(ls -d /dev/vfio/[0-9]*))

echo "[INFO] Create docker network"
docker network create hadoop-network

echo "[INFO] Create master container"
docker run -i -t -d \
    -u "$(id -u)" \
    -p 1022:22 \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    -v "${INSTALL_CONTAINER_DIR}/script/ssh_no_pass.sh:/home/$(whoami)/ssh_no_pass.sh" \
    -v "${INSTALL_CONTAINER_DIR}/hadoop_config:/home/$(whoami)/hadoop_config" \
    -v "${REPO_DIR}/test:/home/$(whoami)/test" \
    --device=/dev/vfio/vfio \
    --device=/dev/dfl-fme.0 \
    --device=/dev/dfl-port.0 \
    --device="${devices[0]}" \
    --name master \
    --hostname master \
    --network hadoop-network \
    hadoop-image \
    /bin/bash -c "sudo service ssh start && exec /bin/bash"

i=0
j=1

while [ "$i" -lt "$1" ] && [ "$j" -lt "${#devices[@]}" ];
do
    echo "[INFO] Create slave-$i container"
    docker run -i -t -d \
        -u "$(id -u)" \
        -v "${INSTALL_CONTAINER_DIR}/hadoop_config:/home/$(whoami)/hadoop_config" \
        --device=/dev/vfio/vfio \
        --device=/dev/dfl-fme.0 \
        --device=/dev/dfl-port.0 \
        --device="${devices[$j]}" \
        --name slave-$i \
        --hostname slave-$i \
        --network hadoop-network \
        hadoop-image \
        /bin/bash -c "sudo service ssh start && exec /bin/bash"

    ((i++))
    ((j++))
done


# Create workers file
>  ${INSTALL_CONTAINER_DIR}/hadoop_config/workers

# Add slave containers name to workers file
slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")
for s in $slaves; do
    echo $s >>  ${INSTALL_CONTAINER_DIR}/hadoop_config/workers
done