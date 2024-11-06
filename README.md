# Virtualized FPGA-acceleration of Distributed File Systems with SR-IOV and Containerizartion

## Version Summary
* Ubuntu 22.04 LTS
* Docker version 27.0.3
* JDK 1.8
* Hadoop 3.4
* Opae SDK 2.8


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