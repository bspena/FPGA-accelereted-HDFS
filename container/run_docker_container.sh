# Arguments:
#   Number of slave containers

# Creat docker containers volumes directory
mkdir -p ${CONTAINER_ROOT}/docker_volumes

# Define the array of devices
iommugroups=($(ls -d /dev/vfio/[0-9]*))
iommugroup_master=$(basename ${iommugroups[0]})
sbdf_master=($(ls /sys/kernel/iommu_groups/$iommugroup_master/devices/))

echo "[DEPLOY DOCKER CONTAINER] Create docker network"
docker network create hadoop-network > /dev/null

mkdir -p ${CONTAINER_ROOT}/docker_volumes/master

echo "[DEPLOY DOCKER CONTAINER] Create master container with:"
echo "                          SBD: $sbdf_master"
echo "                          IOMMU_GROUP: $iommugroup_master"
docker run -i -t -d \
    -u "$(id -u)" \
    -p 1022:22 \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    -v "${HDFS_DEMO_ROOT}:${HADOOP_CONTAINER_ROOT}/hdfs_demo" \
    -v "${CONTAINER_ROOT}/docker_volumes/master:${HADOOP_CONTAINER_ROOT}/container_volume" \
    -v "${REPO_DIR}/test:/home/$(whoami)/test" \
    --mount type=tmpfs,destination=/dev/hugepages,tmpfs-size=1G,tmpfs-mode=1770 \
    --ulimit memlock=-1:-1 \
    --device=/dev/vfio/vfio \
    --device=/dev/dfl-fme.0 \
    --device=/dev/dfl-port.0 \
    --device="${iommugroups[0]}" \
    --name master \
    --hostname master \
    --network hadoop-network \
    hadoop-image \
    /bin/bash -c "sudo service ssh start && exec /bin/bash" > /dev/null


i=0
j=1

#  ./sycl_rs_erasure -f 0000:01:00.3 -l 1048576
# ;: 3: cannot create /home/hadoop/container_volume/apache-activemq-5.16.6//data/activemq.pid: Permission denied

while [ "$i" -lt "$1" ] && [ "$j" -lt "${#iommugroups[@]}" ];
do
    iommugroup_slave=$(basename ${iommugroups[$j]})
    sbdf_slave=($(ls /sys/kernel/iommu_groups/$iommugroup_slave/devices/))
    mkdir -p ${CONTAINER_ROOT}/docker_volumes/slave-$i

    echo "[DEPLOY DOCKER CONTAINER] Create slave-$i container with:"
    echo "                          SBD: $sbdf_slave"
    echo "                          IOMMU_GROUP: $iommugroup_slave"
    docker run -i -t -d \
        -u "$(id -u)" \
        -v "${HDFS_DEMO_ROOT}:${HADOOP_CONTAINER_ROOT}/hdfs_demo" \
        -v "${CONTAINER_ROOT}/docker_volumes/slave-$i:${HADOOP_CONTAINER_ROOT}/container_volume" \
        --mount type=tmpfs,destination=/dev/hugepages,tmpfs-size=1G,tmpfs-mode=1770 \
        --ulimit memlock=-1:-1 \
        --device=/dev/vfio/vfio \
        --device=/dev/dfl-fme.0 \
        --device=/dev/dfl-port.0 \
        --device="${iommugroups[$j]}" \
        --name slave-$i \
        --hostname slave-$i \
        --network hadoop-network \
        hadoop-image \
        /bin/bash -c "sudo service ssh start && exec /bin/bash" > /dev/null

    ((i++))
    ((j++))
done


# Create workers file
>  ${HADOOP_ROOT}/assets/workers

# Add slave containers name to workers file
slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")
for s in $slaves; do
    echo $s >>  ${HADOOP_ROOT}/assets/workers
done