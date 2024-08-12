# Container

* It works
* docker run -i -t -d -v "/home/$(whoami)/hadoop:/home/$(whoami)/hadoop" -v "/home/$(whoami)/.m2:/home/$(whoami)/.m2" -v "/home/$(whoami)/.gnupg:/home/$(whoami)/.gnupg"  -v "/home/$(whoami)/thesis/build/container/start_daemons.sh:/home/$(whoami)/start_daemons.sh" -u "$(id -u)" --name "slave" --hostname "slave" --network host hadoop-build /bin/bash 
* docker exec slave /bin/bash -c "./start_daemons.sh"


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
    -t hadoop-build . \
    -f "/home/$(whoami)/hadoop/dev-support/docker/Dockerfile" \
    /home/$(whoami)/hadoop/dev-support/docker
```

### Run
* Copy config/site.xml file into hadoop directory
```bash
$ cp config/* $HADOOP_HOME/etc/hadoop/
```
* Run one master container and n slave containers
```bash
$ docker compose up -d --scale slave=n
```
> Note: Upon staring conatiners, will be executed the bash script start_daemons. Remember to edit the paths into docker compose file.

* docker compose stop

### Passing device to conatiner with docker compose
* https://stackoverflow.com/questions/73339141/docker-compose-devices-map-all-devices-from-local-to-container
* differnt containers different devices ????
    * no --scale flag --> different services
    * bash script--> for {variable docker compose}
    * bash script --> for {doker run ...}

### Remove the Containers
```bash
$ docker system prune
```

### Network
https://sophilabs.com/blog/communication-between-containers-and-host-machine


## LXC
* https://discuss.linuxcontainers.org/t/unprivileged-container-does-not-work-in-ubuntu-22-04/14904


## Utils
### Docker 
* Commands 
    * sudo docker run -ti ubuntu:jammy /bin/bash --> start an ubuntu container
    * sudo docker start container_name --> start a container
    * sudo docker attach container_name --> attach session to container console
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
* Hadoop
    * https://github.com/kiwenlau/hadoop-cluster-docker/tree/master
    * https://github.com/apache/hadoop/tree/docker-hadoop-3 (based on centOS)
* Access to container via ssh
    * Identify container ip
        * docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name_or_id
    * Change password 
        * sudo passwd spena
        * or echo "spena:newpassword" | sudo chpasswd
    * Connect
        * ssh spena@container_ip
* Connect host to container 
    * https://www.howtogeek.com/devops/how-to-connect-to-localhost-within-a-docker-container/

### Linux Container (LXC)
* Install --> https://linuxcontainers.org/lxc/getting-started/
    > Note: use sudo privileges
* Hadoop
    * https://www.adaltas.com/en/2020/08/04/installing-hadoop-from-source/

### Kubernetes
* ???????
* Hadoop
    * https://medium.com/@big_data_landscape/deploying-a-hadoop-cluster-with-docker-and-kubernetes-a-modern-approach-3d0803ba80d6

### Podman
* Doc --> https://docs.podman.io/en/latest/
* Install --> https://podman.io/docs/installation#ubuntu
    * Version: 3.4.4


## Troubleshooting
### Docker Error 1
* Unable to run a container
* failed to start daemon: Error initializing network controller: error obtaining controller instance: failed to register "bridge" driver: unable to add return rule in DOCKER-ISOLATION-STAGE-1 chain:  (iptables failed: iptables --wait -A DOCKER-ISOLATION-STAGE-1 -j RETURN: iptables v1.8.7 (nf_tables):  RULE_APPEND failed (No such file or directory): rule in chain DOCKER-ISOLATION-STAGE-1
(exit status 4))
* Solution: Updtae iptables to the legacy version 
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo dockerd &
 
> Note: It showes on the virtual machine