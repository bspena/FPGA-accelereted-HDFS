#########################
# Docker Compose Method #
#########################
#echo "#########################################"
#echo "[INFO] Start master and slave containers"
#echo "#########################################"
#docker compose -f /home/$(whoami)/thesis/build/container/docker/docker-compose.yml up -d

###########################
# Only Docker File Method #
###########################
# Check if master container already exist
master_exist=$(docker ps -a --filter "name=hadoop-master" --format "{{.Names}}")
# Check if master container is running
master_running=$(docker ps -a --filter "name=hadoop-master" --format "{{.Names}}")

# If master container does not exist
if [ -z "$master_exist" ]; then
    
    # Run master container
    echo "###########################"
    echo "[INFO] Run master container"
    echo "###########################"
    docker run -i -t -d \
        -v "/home/$(whoami)/hadoop:/home/$(whoami)/hadoop" \
        -v "/home/$(whoami)/.m2:/home/$(whoami)/.m2" \
        -v "/home/$(whoami)/.gnupg:/home/$(whoami)/.gnupg" \
        -v "/home/$(whoami)/thesis/build/container/script/hadoop_daemons.sh:/home/$(whoami)/hadoop_daemons.sh" \
        -v "/home/$(whoami)/thesis/build/container/script/job_mapred.sh:/home/$(whoami)/job_mapred.sh" \
        -u "$(id -u)" \
        -p 9870:9870  \
        -p 8088:8088  \
        -p 19888:19888 \
        --name hadoop-master \
        --hostname master \
        --network hadoop-network \
        hadoop-build \
        /bin/bash

    ### Note: add --device flag

    # Fine vfio device (to check)
    #VFIO=($(sudo find /dev/ -name "vfio"))

    # Loop over VFIO array elements starting from the second on (the first one is for the master container)
    #for i in "${!VFIO[@]:1}";
    for i in {0..3}
    do
        # Run hadoop slave containers
        echo "###########################"
        echo "[INFO] Run slave container"
        echo "###########################"
        docker run -i -t -d \
        -v "/home/$(whoami)/hadoop:/home/$(whoami)/hadoop" \
        -v "/home/$(whoami)/.m2:/home/$(whoami)/.m2" \
        -v "/home/$(whoami)/.gnupg:/home/$(whoami)/.gnupg" \
        -v "/home/$(whoami)/thesis/build/container/script/hadoop_daemons.sh:/home/$(whoami)/hadoop_daemons.sh" \
        -u "$(id -u)" \
        --name hadoop-slave-$i \
        --hostname slave \
        --network hadoop-network \
        hadoop-build \
        /bin/bash

        ### Note: add --device="${VFIO[$i]}"

    done

# If master already exist but is not running
elif [ -z "$master_running" ]; then 

    echo "##############################"
    echo "[INFO] Start master container"
    echo "##############################"
    docker start hadoop-master

    # Check for existing slave containers
    slave_containers=$(docker ps -a --filter "name=hadoop-slave-" --format "{{.Names}}")

    for s in $slave_containers;
        do
            echo "################"
            echo "[INFO] Start $s"
            echo "################"
            docker start "$s"
        done
fi

echo "###########################"
echo "[INFO] Start master daemons"
echo "###########################"
docker exec hadoop-master /bin/bash -c "./hadoop_daemons.sh"

# Check for all running slave containers 
slave_containers=$(docker ps --filter "name=hadoop-slave-" --format "{{.Names}}")

for s in $slave_containers;
do
    echo "[INFO] Start slave damons for $s"
    docker exec "$s" /bin/bash -c "./hadoop_daemons.sh"
done





