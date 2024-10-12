# Prerequisities
# JDK 8
sudo apt install openjdk-8-jdk

pip3 install pandas==2.2.2

# Maven 3.6
sudo apt-get -y install maven

# Native libraries
sudo apt-get -y install build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev libsasl2-dev libboost-date-time-dev libboost-program-options-dev

# Protocol Buffers 3.7.1 (required to build native code)
cd ~/
curl -L -s -S https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-java-3.7.1.tar.gz -o protobuf-3.7.1.tar.gz
mkdir protobuf-3.7-src
tar xzf protobuf-3.7.1.tar.gz --strip-components 1 -C protobuf-3.7-src && cd protobuf-3.7-src
./configure
make -j$(nproc)
sudo make install

# Snappy compression (only used for hadoop-mapreduce-client-nativetask)
sudo apt-get install -y snappy libsnappy-dev

# Bzip2
sudo apt-get install -y bzip2 libbz2-dev

# Linux FUSE
sudo apt-get install -y fuse libfuse-dev

# ZStandard compression
sudo apt-get install -y libzstd1-dev


# SSH and PDSH
sudo apt-get install -y ssh pdsh

# Hadoop-Opae 3.4.0
cd ~/
#git clone https://github.com/apache/hadoop.git --branch rel/release-3.4.0 --single-branch
git clone https://github.com/MaistoV/hadoop-OPAE.git --branch ... --single-branch

# Set JAVA_HOME environment variable
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc

# Build Hadoop 3.4.0
cd ~/hadoop
mvn package -Pdist,native -DskipTests -Dtar

# Set environment variables
echo 'export HADOOP_HOME= ~/hadoop/hadoop-dist/target/hadoop-3.4.0' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME="$HADOOP_HOME"' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME="$HADOOP_HOME"' >> ~/.bashrc
echo 'export HADOOP_YARN_HOME="$HADOOP_HOME"' >> ~/.bashrc