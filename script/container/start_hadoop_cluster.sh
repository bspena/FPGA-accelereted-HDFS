echo "[INFO] Start master container"
docker start master

# Check for existing slave containers
slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")

for s in $slaves; do
        echo "[INFO] Start $s"
        docker start "$s"
done


echo "[INFO] Copy the hadoop configuration to containers"
for file in /home/$(whoami)/thesis/install/container/hadoop_config/*; do

    if [ "$(basename "$file")" = "workers" ]; then
        docker cp "$file" master:/home/$(whoami)/hadoop-3.3.5/etc/hadoop/
    else
        docker cp "$file" master:/home/$(whoami)/hadoop-3.3.5/etc/hadoop/

        for s in $slaves; do
            docker cp "$file" "$s":/home/$(whoami)/hadoop-3.3.5/etc/hadoop/
        done
    fi
done


# Hadoop clean up
#docker exec master /bin/bash -c "source utility/hadoop_cleanup.sh"
#ssh spena@172.18.0.2 "HADOOP_HOME=/home/spena/hadoop-3.3.5/ bash -c 'source utility/hadoop_cleanup.sh'"


#echo "[INFO] Start hadoop daemons"
#docker exec master /bin/bash -c "\$HADOOP_HOME/sbin/start-dfs.sh"

#docker exec master /bin/bash -c "source utility/job_mapred.sh"