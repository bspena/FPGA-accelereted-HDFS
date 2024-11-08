# Virtualized FPGA-acceleration of Distributed File Systems with SR-IOV and Containerizartion
Analysis, design and development of a `Virtual Cluster` capable of leveraging `FPGA acceleration` for the Hadoop
Distributed File System (`HDFS`). The Virtual Cluster was implemented using `Docker Containers`, which host the Hadoop
Daemons (background processes). `Single Root I/O Virtualization`, a hardware specification, allows the use of the parallel
computing capabilities of the FPGA, by exposing it as `multiple physical devices`. 

## Version Summary
* Ubuntu 22.04 LTS
* Docker version 27.0.3
* JDK 1.8
* Hadoop 3.4
* Opae SDK 2.8

## Repo structure
```
REPO/
├── container                       # Container set up
│   ├── docker                      # Docker container files
│   ├── hdfs_demo
│   │   ├── modules                 # Cluster Modules
│   │   ├── scripts                 # Cluster-related scripts
│   │   └── tests                   # Bash test scripts
│   ├── README.md
│   └── script                      # Container-related scripts
├── install                         # Install components directory
├── python_test                     # Python test scripts
└──README.md                        # This file
```

## Enviroment Setup
1) Set enviroment variables:
```bash
$ source settings.sh
```
2) Install and build `Hadoop 3.4.0` on host maschine:
```bash
$ source install/hadoop_build.sh
```
3) FPGA Set Up:
```bash
$ make pac_powercycle_<boot_page>       # Set FPGA boot sequence
$ fpgainfo fme                          # Check FPGA Status
$ make opae.io_bind_all                 # Bind all VFs
```
4) [Cluster Deploy](container/README.md#deploy)
5) [Cluster Init](container/README.md#init)


## Test Execution
* Start test:
```bash
$ source $HADOOP_USER_HOME/hdfs_demo/tests/run_test.sh <targert_exeperiments> <EC_policy>
```
* Plot the results:
```bash
$ python3 $HADOOP_USER_HOME/hdfs_demo/tests/plots/plot_dfsio.py
```
