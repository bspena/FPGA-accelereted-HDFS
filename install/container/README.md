# Hadoop Container

## ????
* Docker version 27.0.3
* Docker Compose version 2.29.1
* LXC version 5.0.0
* Distrobuilder ????
* Podman version 3.4.4 ???
* Kubernetes version ???

## Docker
* To build docker image with hadoop, run:
```bash
$ source script/hadoop_container_build.sh
```

> Note: Set the correct paths 

## Start ssh into slave
    * docker exec slave-0 /bin/bash -c "sudo service ssh start"

## Copy file 
* hadoop tar.gz archive
    * docker cp /home/$(whoami)/hadoop/hadoop-dist/target/hadoop-3.3.5.tar.gz master:/home/$(whoami)/
    * docker exec master /bin/bash -c "tar -xzf hadoop-3.3.5.tar.gz -C /home/\$(whoami)"
    * for --> slave container
* hadoop_config
    * for file in /home/spena/thesis/install/container/hadoop_config/*; do
        docker cp "$file" master:/home/spena/hadoop-3.3.5/etc/hadoop/
        docker cp "$file" slave-0:/home/spena/hadoop-3.3.5/etc/hadoop/
        docker cp "$file" slave-1:/home/spena/hadoop-3.3.5/etc/hadoop/
       done

## Passphraseless ssh
* Set password on slave container (added to dockerfile)
    * echo "spena:spena" | sudo chpasswd
* Start ssh in both master and slave container
    * sudo service ssh start
* Set PDSH_RCMD_TYPE=ssh in master container
    * echo 'export PDSH_RCMD_TYPE=ssh' >> ~/.bashrc
    * source ~/.bashrc
* Generate public ssh key on master container
    * ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
* Copy public key to master    
    * cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
* Copy public key to slave
    * ssh-copy-id user@slave



## LXC
* Hadoop
    * sudo $HOME/go/bin/distrobuilder build-lxc ubuntu.yaml
    * sudo lxc-create -n container_name -t local -- --metadata meta.tar.xz --fstree rootfs.tar.xz
    * sudo lxc-start -n container_name
    * sudo bash -c 'echo "lxc.mount.entry = /home/spena/hadoop home/spena/hadoop none bind,create=dir 0 0" >>/var/lib/lxc/hadoop_image/config'
    * sudo bash -c 'echo "lxc.mount.entry = /home/spena/.m2 home/spena/.m2 none bind,create=dir 0 0" >>/var/lib/lxc/hadoop_image/config'
    * sudo bash -c 'echo "lxc.mount.entry = /home/spena/.gnupg home/spena/.gnupg none bind,create=dir 0 0" >>/var/lib/lxc/hadoop_image/config'
    * sudo bash -c 'echo "lxc.mount.entry = /home/spena/thesis/build/container/script/hadoop_daemons.sh home/spena/hadoop_daemons.sh none bind,create=dir 0 0" >>/var/lib/lxc/hadoop_image/config'
* network ????
* Change hostname
    lxc-create -n container_name -- --hostname container_hostname
* Pass a device 
    * lxc-device -n container_name add /dev/device_name 
* Troubleshooting
    * https://discuss.linuxcontainers.org/t/2nd-system-upgraded-from-ubuntu-20-04-w-working-lxd-to-ubuntu-22-04-lxd-again-not-working/14009/7
    * Add to /etc/default/lxc-net --> LXC_USE_NFT=false

### Isntall distrobuilder
* sudo apt-get remove --purge golang-go
* sudo apt-get autoremove
* wget https://go.dev/dl/go1.22.6.linux-amd64.tar.gz
* sudo tar -C /usr/local -xzf go1.22.6.linux-amd64.tar.gz
* echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
* echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
* echo 'export GOPATH=/home/spena/go' >> ~/.bashrc
* echo 'export GOEXPERIMENT=none' >> ~/.bashrc
* echo 'export GOFLAGS="-mod=readonly"' >> ~/.bashrc
* echo 'export GO111MODULE=auto' >> ~/.bashrc
* echo 'export GOPROXY=https://proxy.golang.org,direct' >> ~/.bashrc
* sudo apt update
* sudo apt install -y golang-go debootstrap rsync gpg squashfs-tools git make
* mkdir -p $HOME/go/src/github.com/lxc/
* cd $HOME/go/src/github.com/lxc/
* git clone https://github.com/lxc/distrobuilder
* cd ./distrobuilder
* make

## Kubernetes
* ???
* Hadoop
    * https://medium.com/@big_data_landscape/deploying-a-hadoop-cluster-with-docker-and-kubernetes-a-modern-approach-3d0803ba80d6


### Podman
* ???


## Troubleshooting
### Docker Error 1
* Unable to run a container
* failed to start daemon: Error initializing network controller: error obtaining controller instance: failed to register "bridge" driver: unable to add return rule in DOCKER-ISOLATION-STAGE-1 chain:  (iptables failed: iptables --wait -A DOCKER-ISOLATION-STAGE-1 -j RETURN: iptables v1.8.7 (nf_tables):  RULE_APPEND failed (No such file or directory): rule in chain DOCKER-ISOLATION-STAGE-1
(exit status 4))
* Solution: Update iptables to the legacy version 
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo dockerd &
 
> Note: It showes on the virtual machine