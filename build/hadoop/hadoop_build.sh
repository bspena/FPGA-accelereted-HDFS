# Prerequisities
# JDK 8
sudo apt install openjdk-8-jdk

pip3 install pandas==2.2.2

# Maven 3.6
sudo apt-get -y install maven

# Native libraries
sudo apt-get -y install build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev libsasl2-dev

# Protocol Buffers 3.7.1 (required to build native code)
curl -L -s -S https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-java-3.7.1.tar.gz -o protobuf-3.7.1.tar.gz
cd /home/$(whoami)
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

# Setup passphraseless ssh
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

# Hadoop 3.3.5
cd /home/$(whoami)
git clone https://github.com/apache/hadoop.git --branch rel/release-3.3.5 --single-branch