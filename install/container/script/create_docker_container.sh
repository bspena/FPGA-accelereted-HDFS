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

# docker run -i -t -d \
#     -u "$(id -u)" \
#     --name mem_5 \
#     --hostname mem_5 \
#     --device=/dev/vfio/18 \
#     --device=/dev/vfio/vfio \
#     --device=/dev/dfl-fme.0 \
#     --device=/dev/dfl-port.0 \
#     hadoop-image \
#     /bin/bash -c "sudo service ssh start && exec /bin/bash"

# docker run -i -t -d \
#     -u "$(id -u)" \
#     --name lpbk_6 \
#     --hostname lpbk_6 \
#     --device=/dev/vfio/19 \
#     --device=/dev/vfio/vfio \
#     --device=/dev/dfl-fme.0 \
#     --device=/dev/dfl-port.0 \
#     hadoop-image \
#     /bin/bash -c "sudo service ssh start && exec /bin/bash"

# docker run -i -t -d \
#     -u "$(id -u)" \
#     --name mem_7 \
#     --hostname mem_7 \
#     --device=/dev/vfio/20 \
#     --device=/dev/vfio/vfio \
#     --device=/dev/dfl-fme.0 \
#     --device=/dev/dfl-port.0 \
#     hadoop-image \
#     /bin/bash -c "sudo service ssh start && exec /bin/bash"


###################################################
# NON-PRIVILEGED CONTAINER (binding in container) #
###################################################
# docker run -i -t -d \
#     -u "$(id -u)" \
#     -p 1022:22 \
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

##   --cap-add=SYS_ADMIN \

###################################################
# PRIVILEGED CONTAINER (binding in container) #
###################################################
docker run --privileged -i -t -d \
    -u "$(id -u)" \
    -p 1022:22 \
    --name master \
    --hostname master \
    -v "/home/bspena/SYCL_AFU:/home/bspena/SYCL_AFU" \
    -v "/home/bspena/thesis/install/container/script/setup.sh:/home/bspena/setup.sh" \
    -v "/lib/modules/6.8.0-45-generic:/lib/modules/6.8.0-45-generic" \
    hadoop-image \
    /bin/bash -c "sudo service ssh start && exec /bin/bash"

#####################
# Hadoop Containers #
#####################
#opae.io ls | sort | grep -v ".0]" | grep vfio | sed 0000:00:00.0

#echo "[INFO] Create docker network"
#docker network create hadoop-network

#echo "[INFO] Create master container"

# docker run -i -t -d \
#     -u "$(id -u)" \
#     -p 9870:9870  \
#     -p 8088:8088  \
#     -p 19888:19888 \
#     -v "~/thesis/install/container/script/container_utility: ~/script" \
#     -v "~/thesis/install/container/hadoop_config: ~/hadoop_config" \
#     --name master \
#     --hostname master \
#     --network hadoop-network \
#     hadoop-image \
#     /bin/bash -c "sudo service ssh start && exec /bin/bash"


# for i in {0..1}; do

#     echo "[INFO] Create slave-$i container"
#     docker run -i -t -d \
#         -u "$(id -u)" \
#         -v "~/thesis/install/container/hadoop_config: ~/hadoop_config" \
#         --name slave-$i \
#         --hostname slave-$i \
#         --network hadoop-network \
#         hadoop-image \
#         /bin/bash -c "sudo service ssh start && exec /bin/bash"

#     ### Note: add --device="${VFIO[$i]}"
#     # --device=/dev/vfio/<iommu_group>
# done

# echo "[INFO] Create workers file"
# source ./script/create_workers_file.sh