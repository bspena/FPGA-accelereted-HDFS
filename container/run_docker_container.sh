# Arguments:
#   Number of slave containers


NUMBER_SLAVE_CONTAINERS=$1
if [ "$NUMBER_SLAVE_CONTAINERS" == "" ]; then
    echo "[ERROR] Expected number of slave containers"
    return 1
fi

# Array of iommugroups
iommugroups=($(ls -d /dev/vfio/[0-9]*))

# Master iommugroups and SBDF
iommugroup_master=$(basename ${iommugroups[0]})
sbdf_master=($(ls /sys/kernel/iommu_groups/$iommugroup_master/devices/))

echo "[DEPLOY DOCKER CONTAINER] Create docker network"
docker network create hadoop-network > /dev/null

i=0
j=1


while [ "$i" -lt "$1" ] && [ "$j" -lt "${#iommugroups[@]}" ];
do
    iommugroup_slave=$(basename ${iommugroups[$j]})
    sbdf_slave=($(ls /sys/kernel/iommu_groups/$iommugroup_slave/devices/))

    # Create volumes directroy
    mkdir -p ${DOCKER_VOLUMES}/slave-$i
    mkdir -p ${DOCKER_VOLUMES}/slave-$i/hadoop_storage

    # Copy modules in each directory
    cp -r ${DOCKER_VOLUMES}/hadoop-${HADOOP_VERSION} ${DOCKER_VOLUMES}/slave-$i
    cp -r ${DOCKER_VOLUMES}/hadoop_storage/disk2 ${DOCKER_VOLUMES}/slave-$i/hadoop_storage
    cp -r ${DOCKER_VOLUMES}/apache-activemq-${ACTIVEMQ_VERSION} ${DOCKER_VOLUMES}/slave-$i

    echo "[DEPLOY DOCKER CONTAINER] Create slave-$i container with:"
    echo "                          SBDF: $sbdf_slave"
    echo "                          IOMMU_GROUP: $iommugroup_slave"
    docker run -i -t -d \
        -u "$(id -u)" \
        -v "${HDFS_DEMO_ROOT}:${HADOOP_CONTAINER_HOME}/hdfs_demo" \
        -v "${HDFS_DEMO_ROOT}/bashrc:/home/hadoop/.bashrc" \
        -v "${DOCKER_VOLUMES}/slave-$i/hadoop-${HADOOP_VERSION}:${HADOOP_CONTAINER_HOME}/hadoop-${HADOOP_VERSION}" \
        -v "${DOCKER_VOLUMES}/slave-$i/apache-activemq-${ACTIVEMQ_VERSION}:${HADOOP_CONTAINER_HOME}/apache-activemq-${ACTIVEMQ_VERSION}" \
        -v "${DOCKER_VOLUMES}/slave-$i/hadoop_storage:${HADOOP_CONTAINER_HOME}/hadoop_storage" \
        --mount type=tmpfs,destination=/dev/hugepages,tmpfs-size=1G,tmpfs-mode=1770 \
        --ulimit memlock=-1:-1 \
        --device=/dev/vfio/vfio \
        --device=/dev/dfl-fme.0 \
        --device=/dev/dfl-port.0 \
        --device="${iommugroups[$j]}" \
        --name slave-$i \
        --hostname slave-$i \
        --network hadoop-network \
        hadoop-image-3 \
        /bin/bash -c "source /home/hadoop/.bashrc && sudo service ssh start && exec /bin/bash" > /dev/null

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

mkdir -p ${DOCKER_VOLUMES}/master
mkdir -p ${DOCKER_VOLUMES}/master/hadoop_storage

cp -r ${DOCKER_VOLUMES}/hadoop-${HADOOP_VERSION} ${DOCKER_VOLUMES}/master
cp -r ${DOCKER_VOLUMES}/hadoop_storage/disk1 ${DOCKER_VOLUMES}/master/hadoop_storage
cp -r ${DOCKER_VOLUMES}/apache-activemq-${ACTIVEMQ_VERSION} ${DOCKER_VOLUMES}/master

cp ${HADOOP_ROOT}/assets/workers ${DOCKER_VOLUMES}/master/hadoop-${HADOOP_VERSION}/etc/hadoop/

echo "[DEPLOY DOCKER CONTAINER] Create master container with:"
echo "                          SBDF: $sbdf_master"
echo "                          IOMMU_GROUP: $iommugroup_master"
docker run -i -t -d \
    -u "$(id -u)" \
    -p 1022:22 \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    -v "${HDFS_DEMO_ROOT}:${HADOOP_CONTAINER_HOME}/hdfs_demo" \
    -v "${HDFS_DEMO_ROOT}/bashrc:/home/hadoop/.bashrc" \
    -v "${DOCKER_VOLUMES}/master/hadoop-${HADOOP_VERSION}:${HADOOP_CONTAINER_HOME}/hadoop-${HADOOP_VERSION}" \
    -v "${DOCKER_VOLUMES}/master/apache-activemq-${ACTIVEMQ_VERSION}:${HADOOP_CONTAINER_HOME}/apache-activemq-${ACTIVEMQ_VERSION}" \
    -v "${DOCKER_VOLUMES}/master/hadoop_storage:${HADOOP_CONTAINER_HOME}/hadoop_storage" \
    --mount type=tmpfs,destination=/dev/hugepages,tmpfs-size=1G,tmpfs-mode=1770 \
    --ulimit memlock=-1:-1 \
    --device=/dev/vfio/vfio \
    --device=/dev/dfl-fme.0 \
    --device=/dev/dfl-port.0 \
    --device="${iommugroups[0]}" \
    --name master \
    --hostname master \
    --network hadoop-network \
    hadoop-image-3 \
    /bin/bash -c "source /home/hadoop/.bashrc && sudo service ssh start && exec /bin/bash" > /dev/null