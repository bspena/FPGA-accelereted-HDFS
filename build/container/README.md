# Hadoop Container

## ????
* Docker version 27.0.3
* Docker Compose version ???
* LXC version 5.0.0 ???
* Podman version 3.4.4 ???
* Kubernetes version ???

## Docker
* To build docker image with hadoop, run:
```bash
$ source hadoop_container build.sh
```

> Note: Set the correct paths 


## LXC
* Hadoop
    * https://www.adaltas.com/en/2020/08/04/installing-hadoop-from-source/


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