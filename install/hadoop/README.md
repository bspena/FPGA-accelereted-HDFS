# Hadoop

## Install
* To install and build `Hadoop 3.4.0`, run:
```bash
$ source install/hadoop/hadoop_build.sh
```

## Configure 
* In `$HADOOP_HOME/etc/hadoop/hadoop-env.sh file`:
    * Add `JAVA_HOME` and `HADOOP_HOME` environment variables
    * Uncomment `HADOOP_LOG_DIR` environment variable
    * Set `HADOOP_CLASSPATH` environment variable as follow
    ```bash
    export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$HADOOP_HOME/share/hadoop/tools/lib/junit-4.13.2.jar
    ```