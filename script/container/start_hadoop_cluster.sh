#########################
# Docker Compose Method #
#########################
#echo "[INFO] Start master and slave containers"
#docker compose -f /home/$(whoami)/thesis/build/container/docker/docker-compose.yml up -d

###########################
# Only Dockerfile Method #
###########################
# Create a hadoop network to connect master and slave containers
# echo "[INFO] Create docker network"
docker network create hadoop-network

# Check if master container already exist
# master_exist=$(docker ps -a --filter "name=hadoop-master" --format "{{.Names}}")
# # Check if master container is running
# master_running=$(docker ps --filter "name=hadoop-master" --format "{{.Names}}")

# # If master container does not exist
# if [ -z "$master_exist" ]; then
    
    # Run master container
    #echo "[INFO] Run master container"
    # docker run -i -t -d \
    #     -v "/home/$(whoami)/hadoop:/home/$(whoami)/hadoop" \
    #     -v "/home/$(whoami)/.m2:/home/$(whoami)/.m2" \
    #     -v "/home/$(whoami)/.gnupg:/home/$(whoami)/.gnupg" \
    #     -v "/home/$(whoami)/thesis/build/container/script/hadoop_daemons.sh:/home/$(whoami)/hadoop_daemons.sh" \
    #     -v "/home/$(whoami)/thesis/build/container/script/job_mapred.sh:/home/$(whoami)/job_mapred.sh" \
    #     -u "$(id -u)" \
    #     -p 9870:9870  \
    #     -p 8088:8088  \
    #     -p 19888:19888 \
    #     --name master \
    #     --hostname master \
    #     --network hadoop-network \
    #     hadoop-build \
    #     /bin/bash

    # docker run -i -t -d \
    #     -v "/home/$(whoami)/thesis/install/container/script/job_mapred.sh:/home/$(whoami)/job_mapred.sh" \
    #     -u "$(id -u)" \
    #     -p 9870:9870  \
    #     -p 8088:8088  \
    #     -p 19888:19888 \
    #     --name master \
    #     --hostname master \
    #     --network hadoop-network \
    #     hadoop-build_v1 \
    #     /bin/bash -c "sudo service ssh start && exec /bin/bash"

    ### Note: add --device flag

    # Fine vfio device (to check)
    #VFIO=($(sudo find /dev/ -name "vfio"))
    #opae.io ls | sort | grep -v ".0]" | grep vfio | sed 0000:00:00.0

    # Loop over VFIO array elements starting from the second on (the first one is for the master container)
    #for i in "${!VFIO[@]:1}";
    #for i in {0..1}; do
        # Run hadoop slave containers
        #echo "[INFO] Run slave container"
        # docker run -i -t -d \
        #     -v "/home/$(whoami)/hadoop:/home/$(whoami)/hadoop" \
        #     -v "/home/$(whoami)/.m2:/home/$(whoami)/.m2" \
        #     -v "/home/$(whoami)/.gnupg:/home/$(whoami)/.gnupg" \
        #     -v "/home/$(whoami)/thesis/build/container/script/hadoop_daemons.sh:/home/$(whoami)/hadoop_daemons.sh" \
        #     -u "$(id -u)" \
        #     --name slave-$i \
        #     --hostname slave-$i \
        #     --network hadoop-network \
        #     hadoop-build \
        #     /bin/bash

    #     docker run -i -t -d \
    #         -u "$(id -u)" \
    #         --name slave-$i \
    #         --hostname slave-$i \
    #         --network hadoop-network \
    #         hadoop-build_v1 \
    #         /bin/bash -c "sudo service ssh start && exec /bin/bash"

    #     ## Note: add --device="${VFIO[$i]}"

    # done

# If master already exist but is not running
# elif [ -z "$master_running" ]; then 

    # echo "[INFO] Start master container"
    # docker start hadoop-master

    # # Check for existing slave containers
    # slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")

    # for s in $slave_containers; do
    #         echo "[INFO] Start $s"
    #         docker start "$s"
    # done
# fi

# echo "[INFO] Start master daemons"
# docker exec hadoop-master /bin/bash -c "./hadoop_daemons.sh"

# Check for all running slave containers 
# slave_containers=$(docker ps --filter "name=hadoop-slave-" --format "{{.Names}}")

# for s in $slave_containers;
# do
#     echo "[INFO] Start slave damons for $s"
#     docker exec "$s" /bin/bash -c "./hadoop_daemons.sh"
# done




slaves=$(docker ps --filter "name=slave-" --format "{{.Names}}")

for file in /home/$(whoami)/thesis/install/container/hadoop_config/*; do

    if [ "$(basename "$file")" = "workers" ]; then
        docker cp "$file" master:/home/$(whoami)/hadoop-3.3.5/etc/hadoop/
    else

        for s in $slaves; do
            docker cp "$file" "$s"-0:/home/$(whoami)/hadoop-3.3.5/etc/hadoop/
        done
    fi
done