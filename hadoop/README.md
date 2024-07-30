# Hadoop

* Install Hadoop by running the bash script:
```bash
$ source hadoop_build.sh
```

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


## Fully Distributed Mode ?????
* https://hadoop.apache.org/docs/r3.3.5/hadoop-project-dist/hadoop-common/ClusterSetup.html
* https://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-multi-node-cluster/#tutorial-approach-and-structure
* Into yarn-site.xml (for WebServerProxy):
    <property>
        <name>yarn.web-proxy.address</name>
        <value>localhost:9090</value>
    </property>
