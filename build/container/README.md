# Container

## ????
* Docker Version 27.0.3
* Docker Compose Version 2.29.1
* LXC Version 5.0.0

## Docker
### Build Hadoop Image
```bash
$ docker build \ 
    --build-arg USER_NAME="${USER}" \ 
    --build-arg USER_ID="$(id -u)" \ 
    --build-arg GROUP_ID="$(id -g)" \ 
    -t hadoop-build \ 
    -f "/home/$(whoami)/hadoop/dev-support/docker/Dockerfile" /home/$(whoami)/hadoop/dev-support/docker
```

### Run
* Run one master container and n slave containers
```bash
$ docker compose up -d --scale slave=n
```
> Note: Upon staring conatiners, will be executed bash script start_daemons. Remember to edit the paths into docker compose file.

## Passing device to conatiner with docker compose
* Passing devce to container --> https://stackoverflow.com/questions/73339141/docker-compose-devices-map-all-devices-from-local-to-container


## LXC


## Utils
### Docker 
* Commands 
    * sudo docker run -ti ubuntu:jammy /bin/bash --> start an ubuntu container
    * sudo docker start container_name --> start a container
    * sudo docker attach container_name --> attach session to container console
> Note: All the containers share the host kernel
* Build the docker image from Dockerfile
    * sudo docker build -t image_name:tag_name /path/to/image
* Change name to the image
    * sudo docker tag image_id image_name:tag_name
* Run a docker container with the custom image
    * sudo docker run -ti image_name:tag /bin/bash
* Remove containers
    * sudo docker system prune
    * sudo docker system prune -a --> remove all images
* Info of the docker image:
    * into the container --> cat /etc/os-release
* Run docker without sudo privileges
    * sudo usermod -aG docker $USER
*  Access to container built with docker compose
    * sudo docker compose exec service_name /bin/bash

### Podman
* Doc --> https://docs.podman.io/en/latest/
* Install --> https://podman.io/docs/installation#ubuntu
    * Version: 3.4.4

### Linux Container (LXC)
* Install --> https://linuxcontainers.org/lxc/getting-started/
    > Note: use sudo privileges

### Kubernetes
* ???????


## Hadoop for container
* Docker 
    * https://hadoop.apache.org/docs/r3.3.5/hadoop-yarn/hadoop-yarn-site/DockerContainers.html
    * https://github.com/kiwenlau/hadoop-cluster-docker/tree/master
    * https://github.com/apache/hadoop/tree/docker-hadoop-3
        * based on centOS
    * https://github.com/bigdatafoundation/docker-hadoop/tree/master
    * https://phpfog.com/creating-hadoop-docker-image/
    * https://github.com/big-data-europe/docker-hadoop
* Lxc 
    * https://www.adaltas.com/en/2020/08/04/installing-hadoop-from-source/
* Kubernetes
    * https://medium.com/@big_data_landscape/deploying-a-hadoop-cluster-with-docker-and-kubernetes-a-modern-approach-3d0803ba80d6

## Notes
* To start/stop hdfs/yarn deamons
    * /sbin/start-dfs.sh --> start/stop all deamons
    * /bin/hdfs --daemon start namenode --> start each deamon separately
> Note: After formatting start-dfs.sh returns error and doesn't allow starting hdfs daemons
* format namenode (my_Dockerfil) --> rm -rf /tmp/hadoop-root/dfs/data/* 


## Troubleshooting
### Error 1
* Unable to run a container
* failed to start daemon: Error initializing network controller: error obtaining controller instance: failed to register "bridge" driver: unable to add return rule in DOCKER-ISOLATION-STAGE-1 chain:  (iptables failed: iptables --wait -A DOCKER-ISOLATION-STAGE-1 -j RETURN: iptables v1.8.7 (nf_tables):  RULE_APPEND failed (No such file or directory): rule in chain DOCKER-ISOLATION-STAGE-1
(exit status 4))
* Solution: Updtae iptables to the legacy version 
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo dockerd &
 
> Note: It showes on the virtual machine


#COPY start_daemons.sh /home/start_daemons.sh
#RUN chmod +x /home/start_daemons.sh 