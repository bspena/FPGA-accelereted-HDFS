FROM ubuntu:jammy

WORKDIR /home
RUN apt-get update && apt-get install -y curl git

############
# OPAE SDK #
############

##########
# HADOOP #
##########

### Prerequisites
# Java
RUN apt-get install -y openjdk-8-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Maven
RUN apt-get install -y maven

# Native libraries
RUN apt install -y build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev libsasl2-dev

# Protocol Buffers 3.7.1 (required to build native code)
RUN curl -L -s -S https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-java-3.7.1.tar.gz -o protobuf-3.7.1.tar.gz
RUN mkdir protobuf-3.7-src
RUN tar xzf protobuf-3.7.1.tar.gz --strip-components 1 -C protobuf-3.7-src
WORKDIR /home/protobuf-3.7-src
RUN ./configure
RUN make -j$(nproc)
RUN make install

WORKDIR /home

# Snappy compression (only used for hadoop-mapreduce-client-nativetask)
RUN apt-get install -y libsnappy-dev
# snappy ?????

# Bzip2
RUN apt-get install -y bzip2 libbz2-dev

# Linux FUSE
RUN apt-get install -y fuse libfuse-dev

# ZStandard compression (?)
#RUN apt-get install -y libzstd1-dev

# Setup passphraseless ssh
RUN apt-get install -y ssh pdsh
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys

### Clone Hadoop repository
RUN git clone https://github.com/apache/hadoop.git --branch rel/release-3.3.5 --single-branch

# Copy pom file to avoid an error when building with maven
WORKDIR /home/hadoop
#ENV POM_PATH=hadoop/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-applications/hadoop-yarn-applications-catalog/hadoop-yarn-applications-catalog-webapp
COPY pom.xml /home/hadoop/hadoop-yarn-project/hadoop-yarn/hadoop-yarn-applications/hadoop-yarn-applications-catalog/hadoop-yarn-applications-catalog-webapp/pom.xml 
#COPY pom.xml /home/${POM_PATH}/pom.xml 

### Build Hadoop
RUN mvn package -Pdist,native -DskipTests -Dtar

### Set environment variables
ENV HADOOP_HOME=/home/hadoop/hadoop-dist/target/hadoop-3.3.5
ENV HADOOP_HDFS_HOME=/home/hadoop/hadoop-dist/target/hadoop-3.3.5
ENV HADOOP_MAPRED_HOME=/home/hadoop/hadoop-dist/target/hadoop-3.3.5
ENV HADOOP_YARN_HOME=/home/hadoop/hadoop-dist/target/hadoop-3.3.5
#ENV HADOOP_XML_SITE=hadoop/hadoop-dist/target/hadoop-3.3.5/etc/hadoop

# Copy *-site.xml
COPY core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml
COPY hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
COPY mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
COPY yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml

### Expose daemons ports
# NameNode: 9870
# ResourceManager: 8088
# MapReduce JobHistory Server: 19888
EXPOSE 9870 8088 19888

WORKDIR /home