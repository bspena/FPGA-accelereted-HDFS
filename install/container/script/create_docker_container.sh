echo "[INFO] Create docker network"
docker network create hadoop-network

echo "[INFO] Create master container"
docker run -i -t -d \
    -u "$(id -u)" \
    -p 9870:9870  \
    -p 8088:8088  \
    -p 19888:19888 \
    -p 1022:22 \
    --name master \
    --hostname master \
    --network hadoop-network \
    --device=/dev/vfio/vfio \
    --device=/dev/dfl-fme.0 \
    --device=/dev/dfl-port.0 \
    -v "/home/bspena/SYCL_AFU:/home/bspena/SYCL_AFU" \
    -v "/home/bspena/thesis/install/container/script/setup.sh:/home/bspena/setup.sh" \
    -v "/sys/bus/pci/devices:/sys/bus/pci/devices" \
    -v "/lib/modules/:/lib/modules" \
    hadoop-image \
    /bin/bash -c "sudo service ssh start && exec /bin/bash"

#--device=/dev/vfio/13 \
#   --cap-add=SYS_ADMIN \
    ### Note: add --device=/dev/vfio/<iommu_group>

#opae.io ls | sort | grep -v ".0]" | grep vfio | sed 0000:00:00.0

# Privileged container
# docker run --privileged -i -t -d \
#     -u "$(id -u)" \
#     -p 9870:9870  \
#     -p 8088:8088  \
#     -p 19888:19888 \
#     -p 1022:22 \
#     --name master \
#     --hostname master \
#     --network hadoop-network \
#     -v "/home/bspena/SYCL_AFU:/home/bspena/SYCL_AFU" \
#     -v "/home/bspena/thesis/install/container/script/setup.sh:/home/bspena/setup.sh" \
#     -v "/lib/modules/:/lib/modules" \
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