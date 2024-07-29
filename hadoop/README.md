# Environment Setup

Virtual machine running `Ubuntu 22.04 LTS` :
  * 8 GB of RAM 
  * 4 cores
  * 150 GB of memory

## Tools <a name="tool"></a>

### Java 1.8
* Install
```bash
$ sudo apt install openjdk-8-jdk
```

* Setting JAVA_HOME environment variable 
```bash
$ nano .bashrc                    
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64   # Add this line to the end of the file                      
```

### Python Libraries
* pandas
```bash
$ pip install pandas
```

### Maven 3.6
```bash
$ sudo apt-get -y install maven
```

### Hadoop 3.3.5
* Install
```bash
$ git clone https://github.com/apache/hadoop.git --branch rel/release-3.3.5 --single-branch
```
* Setting HADOOP_HOME environment variable (necessary to run the test cases script)
```bash
$ nano .bashrc                                      # Open the bashrc file
export HADOOP_HOME=/path/to/hadoop-3.3.5/directory    # Add at the end of the file
```

### Libraries

* Native libraries
```bash
$ sudo apt-get -y install build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev libsasl2-dev
```

* Protocol Buffers 3.7.1 (required to build native code)
```bash
$ curl -L -s -S https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-java-3.7.1.tar.gz -o protobuf-3.7.1.tar.gz
$ mkdir protobuf-3.7-src
$ tar xzf protobuf-3.7.1.tar.gz --strip-components 1 -C protobuf-3.7-src && cd protobuf-3.7-src
$ ./configure
$ make -j$(nproc)
$ sudo make install
```

* Snappy compression (only used for hadoop-mapreduce-client-nativetask)
```bash
$ sudo apt-get install snappy libsnappy-dev
```
* Bzip2
```bash
$ sudo apt-get install bzip2 libbz2-dev
```
* Linux FUSE
```bash
$ sudo apt-get install fuse libfuse-dev
```
* ZStandard compression
```bash
$ sudo apt-get install libzstd1-dev
```

### SSH and PDSH
* Install 
```bash
$ sudo apt-get install ssh
$ sudo apt-get install pdsh
```
* Setup passphraseless ssh

```bash
# Check that you can ssh to the localhost without a passphrase
$ ssh localhost

# If you cannot ssh to localhost without a passphrase, execute the following commands
$ ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
$ chmod 0600 ~/.ssh/authorized_keys
```

## Building Hadoop <a name="build"></a>
To build Hadoop from within the build enviroment run the following command :

```bash
$ cd hadoop
$ mvn package -Pdist,native -DskipTests -Dtar
```
* `-DskipTests` flag : Makes a build without running the unit tests. 
* `-Pdist` and `-Dtar` flags :  Produce a distribution with a .tar.gz file extension.
* `native` flag : Build the native hadoop library.

## Setting up Hadoop Cluster <a name="cluster"></a>
To run the single-node cluster in pseudo-distributed mode, set the **-site.xml* file as following<sup>[[12]](References.md#single_node_cluster)</sup>:
* etc/hadoop/core-site.xml :
```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
```
* etc/hadoop/hdfs-site.xml:
```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
```
* etc/hadoop/mapred-site.xml:
```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
```
* etc/hadoop/yarn-site.xml:
```xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>
```



# Fully distributed
* https://hadoop.apache.org/docs/r3.3.5/hadoop-project-dist/hadoop-common/ClusterSetup.html
* Into hadoop-env.sh:
    * set JAVA_HOME and HADOOP_HOME
    * Uncomment HADOOP_LOG_DIR 
* Into yarn-site.xml (for WebServerProxy):
    <property>
        <name>yarn.web-proxy.address</name>
        <value>localhost:9090</value>
    </property>
* Set HADOOP_HDFS_HOME/HADOOP_MAPRED_HOME/HADOOP_YARN_HOME=HADOOP_HOME

* https://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-multi-node-cluster/#tutorial-approach-and-structure