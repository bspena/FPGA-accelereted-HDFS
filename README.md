# Thesis

* Ubuntu 22.04 LTS

## Enviroment Setup
1) [???](intel_OFS/README.md)
2) [Installation Steps for Hadoop into the host machine](hadoop/README.md)
3) [???](container/README.md)

> Note: Step 2 is not necessary if you do not want to use the host as the master node for the Hadoop cluster.

# To Do
* Update Readme into hadoop folder
* Run a lxc container
* Import Dockerfile from intel-ofs-hitek repository into container directory
* Import intel-ofs-hitek repository 
* Create bash script "settings_hadoop.sh" with all libraries for hadoop (?)
* Write docker-compose.yml --> multi container (?)
* Rename python and bash scripts into hadoop/script directory
* Create a conf directory into container directory
    * Add hadoop-env.sh file
    * Update dockerfile conf/file_xml
    * Update dockerfile with COPY conf/hadoop-env.sh ...