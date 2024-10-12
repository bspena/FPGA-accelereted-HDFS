# Thesis

## Version Summary
* Ubuntu 22.04 LTS
* Docker version 27.0.3
* Opae SDK 2.8
* ...

## Enviroment Setup
0) Set general enviroment variables:
```bash
$ source settings.sh
```
1) [Install Intel OFS on the host machine](install/SYCL_AFU/README.md)
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