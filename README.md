# Thesis

## Version Summary
* Ubuntu 22.04 LTS
* Docker version 27.0.3

## Enviroment Setup
0) Set genearl enviroment variables:
```bash
$ source set_env_variables.sh
```
1) [Install Intel OFS on the host machine](install/intel_OFS/README.md)
2) [Install Hadoop on the host machine](install/hadoop/README.md)
3) [Build the Hadoop Container](install/container/README.md)

## Test Exectution
* Write test_list csv file
* Access to master container
* Start test

# To Do
* Repo clean up from useless comments
* Import intel-ofs-hitek repository 
    * Import Dockerfile from intel-ofs-hitek repository into container directory