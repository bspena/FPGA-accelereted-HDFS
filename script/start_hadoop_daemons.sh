echo Start hadoop damons into hadoop-master
docker exec hadoop-master /bin/bash -c "./hadoop_daemons.sh"

containers=$(docker ps --filter "name=hadoop-slave-" --format "{{.Names}}")

for c in $containers;
do
    echo Start hadoop damons into $c
    docker exec "$c" /bin/bash -c "./hadoop_daemons.sh"
done