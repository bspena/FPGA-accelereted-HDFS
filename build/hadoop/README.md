# Hadoop

## Install
* Install Hadoop by running the bash script:
```bash
$ source hadoop_build.sh
```

## Build
* Set JAVA_HOME environment variable:
```bash
$ nano .bashrc                    
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

* Build Hadoop using Maven:
```bash
$ cd /home/$(whoami)/hadoop
$ mvn package -Pdist,native -DskipTests -Dtar
```

> Note: Hadoop build with maven might fail due to incompatibility of the node version. Go to the pom.xml file located in the /home/$(whoami)/hadoop/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-applications/hadoop-yarn-applications-catalog/hadoop-yarn-applications-catalog-webapp path and set node and yarn version as follow:
>```xml
><nodeVersion>v14.15.0</nodeVersion>
><yarnVersion>v1.22.5</yarnVersion>
>```

## Configure 
* Set Hadoop environment variables:
```bash
$ nano .bashrc                                    
export HADOOP_HOME=/home/$(whoami)/hadoop/hadoop-dist/target/hadoop-3.3.5
export HADOOP_HDFS_HOME="$HADOOP_HOME"
export HADOOP_MAPRED_HOME="$HADOOP_HOME"
export HADOOP_YARN_HOME="$HADOOP_HOME"
```

* Into $HADOOP_HOME/etc/hadoop/hadoop-env.sh:
    * Add `JAVA_HOME` and `HADOOP_HOME` environment variables
    * Uncomment `HADOOP_LOG_DIR` environment variable
    * Set `HADOOP_CLASSPATH` environment variable as follow
    ```bash
    export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/home/$(whoami)/hadoop/hadoop-dist/target/hadoop-3.3.5/share/hadoop/tools/lib/junit-4.13.2.jar
    ```


## Fully Distributed Mode
* https://hadoop.apache.org/docs/r3.3.5/hadoop-project-dist/hadoop-common/ClusterSetup.html
* https://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-multi-node-cluster/#tutorial-approach-and-structure

## Downlaod
* https://dlcdn.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz