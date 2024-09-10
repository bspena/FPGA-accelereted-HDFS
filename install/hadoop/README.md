# Hadoop

## Install
* To install and build `Hadoop 3.4.0` from the [official repository](https://github.com/apache/hadoop.git), run:
```bash
$ source hadoop_build.sh
```

> Note: Hadoop build with maven might fail due to incompatibility of the node version. Go to `/home/$(whoami)/hadoop/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-applications/hadoop-yarn-applications-catalog/hadoop-yarn-applications-catalog-webapp/pom.xml file` and set node and yarn version as follow:
>```xml
><nodeVersion>v14.15.0</nodeVersion>
><yarnVersion>v1.22.5</yarnVersion>
>```

## Configure 
* In `$HADOOP_HOME/etc/hadoop/hadoop-env.sh file`:
    * Add `JAVA_HOME` and `HADOOP_HOME` environment variables
    * Uncomment `HADOOP_LOG_DIR` environment variable
    * Set `HADOOP_CLASSPATH` environment variable as follow
    ```bash
    export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$HADOOP_HOME/share/hadoop/tools/lib/junit-4.13.2.jar
    ```