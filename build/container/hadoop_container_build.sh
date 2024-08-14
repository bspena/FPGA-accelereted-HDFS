
# Build hadoop docker image
# docker build \
#     --build-arg USER_NAME="${USER}" \
#     --build-arg USER_ID="$(id -u)" \
#     --build-arg GROUP_ID="$(id -g)" \
#     -t hadoop-build .

# Copy config/site.xml file into hadoop directory
cp config/* $HADOOP_HOME/etc/hadoop/

# Create a hadoop network to connect master and slave containers
docker network create hadoop-network

# Run master container
docker run -i -t -d \
    -v "/home/$(whoami)/hadoop:/home/$(whoami)/hadoop" \
    -v "/home/$(whoami)/.m2:/home/$(whoami)/.m2" \
    -v "/home/$(whoami)/.gnupg:/home/$(whoami)/.gnupg" \
    -v "$(pwd)/hadoop_daemons.sh:/home/$(whoami)/hadoop_daemons.sh" \
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


# Add settings_opae --> number of containers = number of vf

# Run hadoop slave containers
for i in {0..3}
do
    docker run -i -t -d \
    -v "/home/$(whoami)/hadoop:/home/$(whoami)/hadoop" \
    -v "/home/$(whoami)/.m2:/home/$(whoami)/.m2" \
    -v "/home/$(whoami)/.gnupg:/home/$(whoami)/.gnupg" \
    -v "$(pwd)/hadoop_daemons.sh:/home/$(whoami)/hadoop_daemons.sh" \
    -u "$(id -u)" \
    --name hadoop-slave-$i \
    --hostname slave \
    --network hadoop-network \
    hadoop-build \
    /bin/bash
done

### Note: add --device flag