# Description: Build Docker Image and create docker containers
# Arguments:
#   Number of slave containers

###################
# Local Variables #
###################
NUM_SLAVE_CONTAINERS=$1

# Array of iommugroups
#iommugroups=($(ls -d /dev/vfio/[0-9]*))

# Master iommugroups and SBDF
#iommugroup_master=$(basename ${iommugroups[0]})
#sbdf_master=($(ls /sys/kernel/iommu_groups/$iommugroup_master/devices/))

# While loop indeces 
i=0
#j=1

# Note: First iommugroup is give to master container, so j index starts from 1 


###########################
# Common docker run flags #
###########################
user_flag="-u $(id -u)"
memory_flag="--mount type=tmpfs,destination=/dev/hugepages,tmpfs-size=1G,tmpfs-mode=1770
             --ulimit memlock=-1:-1
             --memory 6g"
device_flag='--device=/dev/vfio/vfio
             --device=/dev/dfl-fme.0
             --device=/dev/dfl-port.0'
network_flag='--network hadoop-network'
image_flag='hadoop-image'
commands="source /home/hadoop/.bashrc && sudo service ssh start && exec /bin/bash"                    

# Expanding environment variables (host_path:docker_path)
eval hdfs_demo_path="${HDFS_DEMO_ROOT}:${HADOOP_CONTAINER_HOME}/hdfs_demo"
eval bashrc_path="${HDFS_DEMO_ROOT}/bashrc:/home/hadoop/.bashrc"

common_volume_flags="-v $hdfs_demo_path
                    -v $bashrc_path"         

###########################
# Master docker run flags #
###########################
# Expanding environment variables (host_path:docker_path)
eval master_volume="${DOCKER_VOLUMES}/master:${HADOOP_CONTAINER_HOME}/container_volume"

master_volume_flags="-v $master_volume"
master_iommugroup_flag='--device="${iommugroups[0]}"'
master_name_flag='--name master'
master_hostname_flag='--hostname master'
exposed_ports='-p 1022:22
               -p 9870:9870
               -p 8088:8088
               -p 19888:19888'

master_flags="$user_flag \
              $exposed_ports \
              $common_volume_flags \
              $master_volume_flags \
              $memory_flag \
              $device_flag \
              $master_name_flag \
              $master_hostname_flag \
              $network_flag \
              $image_flag"
            

###########################
# Slaves docker run flags #
###########################
# Expanding environment variables (host_path:docker_path)
eval slave_volume="${DOCKER_VOLUMES}/slave-$i:${HADOOP_CONTAINER_HOME}/container_volume"

slave_volume_flags="-v $slave_volume"
slave_iommugroup_flag='--device="${iommugroups[$j]}"'
slave_name_flag="--name slave-$i"
slave_hostname_flag="--hostname slave-$i"

slave_flags="$user_flag \
             $common_volume_flags \
             $slave_volume_flags \
             $memory_flag \
             $device_flag \
             $slave_name_flag \
             $slave_hostname_flag \
             $network_flag \
             $image_flag"



##########
# Script #
##########

# Check the number of slave containers
if [ "$NUM_SLAVE_CONTAINERS" == "" ]; then
    echo "[ERROR] Expected number of slave containers"
    return 1
fi

echo "[DEPLOY DOCKER CONTAINER] Create docker network"
docker network create hadoop-network > /dev/null

while [ "$i" -lt "$NUM_SLAVE_CONTAINERS" ];
#while [ "$i" -lt "$NUM_SLAVE_CONTAINERS" ] && [ "$j" -lt "${#iommugroups[@]}" ];
do
    #iommugroup_slave=$(basename ${iommugroups[$j]})
    #sbdf_slave=($(ls /sys/kernel/iommu_groups/$iommugroup_slave/devices/))

    # Create volumes directroy for slave containers
    mkdir -p ${DOCKER_VOLUMES}/slave-$i
    mkdir -p ${DOCKER_VOLUMES}/slave-$i/hadoop_storage

    # Copy modules in each directory
    cp -r ${DOCKER_VOLUMES}/hadoop-${HADOOP_VERSION} ${DOCKER_VOLUMES}/slave-$i
    cp -r ${DOCKER_VOLUMES}/hadoop_storage/disk2 ${DOCKER_VOLUMES}/slave-$i/hadoop_storage
    cp -r ${DOCKER_VOLUMES}/apache-activemq-${ACTIVEMQ_VERSION} ${DOCKER_VOLUMES}/slave-$i

    echo "[DEPLOY DOCKER CONTAINER] Create slave-$i container with:"
    #echo "                          SBDF: $sbdf_slave"
    #echo "                          IOMMU_GROUP: $iommugroup_slave"
    docker run -i -t -d $slave_flags \
                        /bin/bash -c "$commands" > /dev/null

    ((i++))
    #((j++))
done


# Create workers file
>  ${HADOOP_ROOT}/install/assets/workers

# Add slave containers name to workers file
slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")
for s in $slaves; do
    echo $s >>  ${HADOOP_ROOT}/install/assets/workers
done

# Create volumes directroy for master container
mkdir -p ${DOCKER_VOLUMES}/master
mkdir -p ${DOCKER_VOLUMES}/master/hadoop_storage

# Copy modules in master directory
cp -r ${DOCKER_VOLUMES}/hadoop-${HADOOP_VERSION} ${DOCKER_VOLUMES}/master
cp -r ${DOCKER_VOLUMES}/hadoop_storage/disk1 ${DOCKER_VOLUMES}/master/hadoop_storage
cp -r ${DOCKER_VOLUMES}/apache-activemq-${ACTIVEMQ_VERSION} ${DOCKER_VOLUMES}/master

# Copy hadoop configuration
cp ${HADOOP_ROOT}/install/assets/workers ${DOCKER_VOLUMES}/master/hadoop-${HADOOP_VERSION}/etc/hadoop/

echo "[DEPLOY DOCKER CONTAINER] Create master container with:"
#echo "                          SBDF: $sbdf_master"
#echo "                          IOMMU_GROUP: $iommugroup_master"
docker run -i -t -d $master_flags \
                    /bin/bash -c "$commands" > /dev/null
