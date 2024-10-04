echo "[INFO] Create docker network"
docker network create hadoop-network

echo "[INFO] Create master container"
docker run -i -t -d \
    -u "$(id -u)" \
    -p 1022:22 \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    -v "~/thesis/install/container/script/container_utility:~/script" \
    -v "~/thesis/install/container/hadoop_config:~/hadoop_config" \
    -v "~/thesis/test:~/test" \
    --name master \
    --hostname master \
    --network hadoop-network \
    hadoop-image \
    /bin/bash -c "sudo service ssh start && exec /bin/bash"

# opae.io ls | sort | grep -v ".0]" | grep vfio | sed 0000:00:00.0
# --device="${VFIO[$i]}"

for i in {0..1}; do
    echo "[INFO] Create slave-$i container"
    docker run -i -t -d \
        -u "$(id -u)" \
        -v "~/thesis/install/container/hadoop_config: ~/hadoop_config" \
        --name slave-$i \
        --hostname slave-$i \
        --network hadoop-network \
        hadoop-image \
        /bin/bash -c "sudo service ssh start && exec /bin/bash"
done

echo "[INFO] Create workers file"
# source ./script/create_workers_file.sh

# Create workers file
#touch  ~/thesis/install/container/hadoop_config/workers
>  ~/thesis/install/container/hadoop_config/workers

# Add slave containers name to workers file
slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")
for s in $slaves; do
    echo $s >>  ~/thesis/install/container/hadoop_config/workers
done


###################################################
# NON-PRIVILEGED CONTAINER (binding in host) #
###################################################
# docker run -i -t -d \
#     -u "$(id -u)" \
#     --name lpbk_2 \
#     --hostname lpbk_2 \
#     --device=/dev/vfio/13 \
#     --device=/dev/vfio/vfio \
#     --device=/dev/dfl-fme.0 \
#     --device=/dev/dfl-port.0 \
#     hadoop-image \
#     /bin/bash -c "sudo service ssh start && exec /bin/bash"



###############################################
# PRIVILEGED CONTAINER (binding in container) #
###############################################
# docker run --privileged -i -t -d \
#     -u "$(id -u)" \
#     -p 1022:22 \
#     --name master \
#     --hostname master \
#     -v "/home/bspena/SYCL_AFU:/home/bspena/SYCL_AFU" \
#     -v "/home/bspena/thesis/install/container/script/setup.sh:/home/bspena/setup.sh" \
#     -v "/lib/modules/6.8.0-45-generic:/lib/modules/6.8.0-45-generic" \
#     hadoop-image \
#     /bin/bash -c "sudo service ssh start && exec /bin/bash"

###################################################
# NON-PRIVILEGED CONTAINER (binding in container) #
###################################################
# docker run -i -t -d \
#     -u "$(id -u)" \
#   --cap-add=SYS_ADMIN \
#     --name np_cont \
#     --hostname np_cont \
#     --device=/dev/vfio/vfio \
#     --device=/dev/dfl-fme.0 \
#     --device=/dev/dfl-port.0 \
#     -v "/home/bspena/SYCL_AFU:/home/bspena/SYCL_AFU" \
#     -v "/home/bspena/thesis/install/container/script/setup.sh:/home/bspena/setup.sh" \
#     -v "/sys/bus/pci/devices:/sys/bus/pci/devices" \
#     -v "/lib/modules/:/lib/modules" \
#     hadoop-image \
#     /bin/bash -c "sudo service ssh start && exec /bin/bash"