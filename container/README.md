# Hadoop Virtual Cluster


## Cluster Deploy <a name="deploy"></a>
```bash
$ source container/scripts/build_docker_image.sh <slave_containers_num>
```

## Cluster Init <a name="init"></a>
* Access to master container:
```bash
$ docker attach master
or
$ ssh -p 1022 user@localhost
```
* Setup passphraseless ssh:
```bash
$ source ssh_no_pass.sh
```
* Cluster init:
```bash
$ source init_demo.sh
```

## Cluster Clean Up
* Remove docker volumes directories:
```bash
$ source container/scripts/cleanup_container_volumes.sh
```
* Destroy docker containers:
```bash
$ source container/scripts/destroy_docker_container.sh
```