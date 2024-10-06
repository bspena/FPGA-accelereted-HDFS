# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dockerfile for installing the necessary dependencies for building Hadoop.
# See BUILDING.txt.

FROM ubuntu:jammy

########
# Hadoop
########

WORKDIR /root

# The commands within the Dockerfile are executed with bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USER_NAME
ARG USER_ID
ARG GROUP_ID
ARG HADOOP_VERSION=3.3.5

#####
# Disable suggests/recommends
#####
RUN echo APT::Install-Recommends "0"\; > /etc/apt/apt.conf.d/10disableextras
RUN echo APT::Install-Suggests "0"\; >>  /etc/apt/apt.conf.d/10disableextras

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_TERSE true

######
# Install common dependencies from packages. Versions here are either
# sufficient or irrelevant.
#
# WARNING: DO NOT PUT JAVA APPS HERE! Otherwise they will install default
# Ubuntu Java.  See Java section below!
######
# hadolint ignore=DL3008
RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends \
        apt-utils bats build-essential bzip2 clang cmake curl doxygen fuse g++ gcc git gnupg-agent \
        libbz2-dev libcurl4-openssl-dev libfuse-dev libprotobuf-dev libprotoc-dev libsasl2-dev \
        libsnappy-dev libssl-dev libsnappy-dev libtool \
        #libzstd1-dev \
        locales \
        make \
        pinentry-curses pkg-config python3 python3-pip python3-pkg-resources \
        python3-setuptools python3-wheel rsync shellcheck software-properties-common sudo valgrind \
        zlib1g-dev ssh pdsh \
    && pip3 install matplotlib \
    && pip3 install pandas \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV PYTHONIOENCODING=utf-8

######
# Set env vars required to build Hadoop
######
ENV MAVEN_HOME /usr
# JAVA_HOME must be set in Maven >= 3.5.0 (MNG-6003)
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

#######
# Install SpotBugs 4.2.2
#######
RUN mkdir -p /opt/spotbugs \
    && curl -L -s -S https://github.com/spotbugs/spotbugs/releases/download/4.2.2/spotbugs-4.2.2.tgz \
      -o /opt/spotbugs.tgz \
    && tar xzf /opt/spotbugs.tgz --strip-components 1 -C /opt/spotbugs \
    && chmod +x /opt/spotbugs/bin/*
ENV SPOTBUGS_HOME /opt/spotbugs

#######
# OpenJDK 8
#######
# hadolint ignore=DL3008
RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends openjdk-8-jdk libbcprov-java \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

######
# Install Google Protobuf 3.7.1 (3.0.0 ships with Bionic)
######
# hadolint ignore=DL3003
RUN mkdir -p /opt/protobuf-src \
    && curl -L -s -S https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-java-3.7.1.tar.gz \
      -o /opt/protobuf.tar.gz \
    && tar xzf /opt/protobuf.tar.gz --strip-components 1 -C /opt/protobuf-src \
    && cd /opt/protobuf-src \
    && ./configure --prefix=/opt/protobuf \
    && make "-j$(nproc)" \
    && make install \
    && cd /root \
    && rm -rf /opt/protobuf-src
ENV PROTOBUF_HOME /opt/protobuf
ENV PATH "${PATH}:/opt/protobuf/bin"

######
# Install Apache Maven 3.6.0 (3.6.0 ships with Bionic)
######
# hadolint ignore=DL3008
RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends maven \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV MAVEN_HOME /usr
# JAVA_HOME must be set in Maven >= 3.5.0 (MNG-6003)
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install pylint and python-dateutil
RUN pip3 install pylint==2.6.0 python-dateutil==2.8.1

###
# Install hadolint
####
RUN curl -L -s -S https://github.com/hadolint/hadolint/releases/download/v1.11.1/hadolint-Linux-x86_64 \
        -o /bin/hadolint \
   && chmod a+rx /bin/hadolint \
   && shasum -a 512 /bin/hadolint | \
        awk '$1!="734e37c1f6619cbbd86b9b249e69c9af8ee1ea87a2b1ff71dccda412e9dac35e63425225a95d71572091a3f0a11e9a04c2fc25d9e91b840530c26af32b9891ca" {exit(1)}'

######
# Intel ISA-L 2.29.0
######
# hadolint ignore=DL3003,DL3008
RUN mkdir -p /opt/isa-l-src \
    && apt-get -q update \
    && apt-get install -y --no-install-recommends automake yasm \
    && apt-get clean \
    && curl -L -s -S https://github.com/intel/isa-l/archive/v2.29.0.tar.gz \
      -o /opt/isa-l.tar.gz \
    && tar xzf /opt/isa-l.tar.gz --strip-components 1 -C /opt/isa-l-src \
    && cd /opt/isa-l-src \
    && ./autogen.sh \
    && ./configure \
    && make "-j$(nproc)" \
    && make install \
    && cd /root \
    && rm -rf /opt/isa-l-src

###
# Avoid out of memory errors in builds
###
ENV MAVEN_OPTS -Xms256m -Xmx1536m

# Skip gpg verification when downloading Yetus via yetus-wrapper
ENV HADOOP_SKIP_YETUS_VERIFICATION true

####################################
# Everything past this point is either not needed for testing or breaks Yetus.
# So tell Yetus not to read the rest of the file:
# YETUS CUT HERE
###

# Hugo static website generator for new hadoop site
RUN curl -L -o hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.58.3/hugo_0.58.3_Linux-64bit.deb \
    && dpkg --install hugo.deb \
    && rm hugo.deb

# Add a welcome message and environment checks.
#COPY hadoop_env_checks.sh /root/hadoop_env_checks.sh
#RUN chmod 755 /root/hadoop_env_checks.sh
# hadolint ignore=SC2016
#RUN echo '${HOME}/hadoop_env_checks.sh' >> /root/.bashrc
####################################


# Remove log files and add both group and user
RUN rm -f /var/log/faillog /var/log/lastlog \
    && groupadd --non-unique -g ${GROUP_ID} ${USER_NAME} \
    && useradd -g ${GROUP_ID} -u ${USER_ID} -k /root -m ${USER_NAME} -d /home/${USER_NAME} \
    # The user will use sudo without password
    && echo "${USER_NAME} ALL=NOPASSWD: ALL" > "/etc/sudoers.d/hadoop-build-${USER_ID}"

# Set the user password 
RUN echo "${USER_NAME}:${USER_NAME}" | chpasswd

# Copy and extract hadoop archive
COPY hadoop-${HADOOP_VERSION}.tar.gz /home/${USER_NAME}/hadoop-${HADOOP_VERSION}.tar.gz
RUN tar -xzf /home/${USER_NAME}/hadoop-${HADOOP_VERSION}.tar.gz -C /home/${USER_NAME}/
RUN rm /home/${USER_NAME}/hadoop-${HADOOP_VERSION}.tar.gz

# Set HOME environment variable
ENV HOME /home/${USER_NAME}
ENV HADOOP_HOME /home/${USER_NAME}/hadoop-${HADOOP_VERSION}
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_YARN_HOME=$HADOOP_HOME

### Expose ports
# NameNode: 9870
# ResourceManager: 8088
# MapReduce JobHistory Server: 19888
EXPOSE 9870 8088 19888

WORKDIR /home/${USER_NAME}


##########
# Opae SDK
##########

# Prerequisites
# RUN apt-get update \ 
#     &&  sudo apt-get install -y python3 python3-pip python3-jsonschema  python3-dev git gcc g++ make cmake uuid-dev \
#     libjson-c-dev libhwloc-dev libtbb-dev libedit-dev libudev-dev linuxptp pandoc \
#     devscripts debhelper doxygen libcli11-dev libspdlog-dev libsystemd-dev libcap-dev python3-pyyaml-env-tag
#     # librpm-dev python3-sphinx  python3-virtualenv  podman
    
# RUN pip3 install jsonschema virtualenv pyyaml pybind11 \
#     && sudo pip3 install Pybind11==2.10.0 \
#     && sudo pip3 install setuptools==59.6.0 --prefix=/usr
#     # pip3 install --upgrade --prefix=/usr pip setuptools pybind11

# # Copy patches files
# COPY hitek_release /home/${USER_NAME}/hitek_release

# # Build opae sdk
# RUN git clone https://github.com/OFS/opae-sdk.git \
#     && cd opae-sdk \
#     && git checkout tags/2.8.0-1 -b nc220 \
#     && git apply /home/${USER_NAME}/hitek_release/AG_C220_NC220_OFS_Release_v1_0_2024-01-22/htk_ofs_nc220/patches/opae-sdk-nc220.patch \
#     && cd /home/${USER_NAME}/opae-sdk/packaging/opae/deb \
#     && ./create \
#     && sudo dpkg -i opae*.deb

CMD [ "/bin/bash"]