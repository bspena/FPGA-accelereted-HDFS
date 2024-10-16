#!/bin/bash
# Description: This is the demo master script. It allows to cleanse the cluster and reconfigure it with the desired configuration
# Arguments:
#   -r|--rs   : Codec configuration    in [RS_3_2|RS_6_3]
#   -i|--impl : Coder implementation   in [ISA-L|FPGA]
#   -d|--dist : Distributed init mode  in [0|1]
#   -f|--vfs  : Number of VFs          positive integer (only applies for FPGA coder)"

######################
# Rough control flow #
######################
# - Setup environment
# - Parse adn sanitize args
# - Stop Hadoop deamons
# - If FPGA:
#   - Kill all Java processes (for VFP and ActiveMQ)
#   - Release VFs
#   - Powercycle PACs (if necessary)
#   - Bind VFs
#   - Launch ActiveMQ and VFPs
# - If DISTRIBUTED
#   - Recovery Hadoop DFS
#   - Start Hadoop deamins
#   - Enable DFS EC policies

# Check user
# if [ $(whoami) != "demo" ]; then
#     echo "[ERROR] This script must be run as demo user"
#     return -1
# fi

# Check environemnt
if [ ${MODULES_ROOT} == "" ]; then
    echo "[ERROR] Must source settings.sh first!"
    return -1    
fi

# Clean up environment
unset RS_SCHEMA
unset CODER_IMPL
#unset DISTRIBUTED_MODE
#unset NUM_VFs

# Usage message
USAGE="Expected args:
        -r|--rs   : Codec configuration    in [RS_3_2|RS_6_3]
        -i|--impl : Coder implementation   in [ISA-L|FPGA]"
#        -d|--dist : Distributed init mode  in [0|1]
#        -f|--vfs  : Number of VFs          positive integer (only applies for FPGA coder)"

##############
# Parse args #
##############
VALID_ARGS=$(getopt -o r:i:d:f: --long rs:,impl:,dist:,vfs: -- "$@")
eval set -- "$VALID_ARGS"
while [ : ]; do
    case "$1" in
    -r | --rs)
        export RS_SCHEMA=$2
        shift 2
        ;;
    -i | --impl)
        export CODER_IMPL=$2
        shift 2
    #    ;;
    # -d | --dist)
    #     export DISTRIBUTED_MODE=$2
    #     shift 2
    #    ;;
    # -f | --vfs)
    #     export NUM_VFs=$2
    #     shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "[ERROR] Unsupported $1"
        echo -e "$USAGE"
        return 1
        ;;
    esac
done

# Default args
if [[ "$RS_SCHEMA" == "" ]] ; then
    export RS_SCHEMA=RS_3_2
fi
if [[ "$CODER_IMPL" == "" ]] ; then
    export CODER_IMPL=FPGA
fi
# if [[ "$DISTRIBUTED_MODE" == "" ]] ; then
#     export DISTRIBUTED_MODE=1
# fi
# if [[ "$NUM_VFs" == "" ]] ; then
#     export NUM_VFs=1
# fi

# Debug
echo "[DEMO INIT] RS_SCHEMA=$RS_SCHEMA"
echo "[DEMO INIT] CODER_IMPL=$CODER_IMPL"
#echo "[DEMO INIT] DISTRIBUTED_MODE=$DISTRIBUTED_MODE"
#echo "[DEMO INIT] NUM_VFs=$NUM_VFs"

#################
# Sanitize args #
#################

# RS_SCHEMA
rs_regex='RS_(3_2|6_3)'
if ! [[ $RS_SCHEMA =~ $rs_regex ]] ; then
    echo "[ERROR] Unsupported RS_SCHEMA $RS_SCHEMA"
    echo -e "$USAGE"
    return -1
fi
export RS_K=${RS_SCHEMA:3:1}
export RS_P=${RS_SCHEMA:5:1}

# CODER_IMPL
coder_regex='ISA-L|FPGA'
if ! [[ $CODER_IMPL =~ $coder_regex ]] ; then
    echo "[ERROR] Unsupported CODER_IMPL $CODER_IMPL"
    echo -e "$USAGE"
    return -1
fi

# DISTRIBUTED_MODE
# is_number_regex='0|1'
# if ! [[ $DISTRIBUTED_MODE =~ $is_number_regex ]] ; then
#     echo "[ERROR] Unsupported DISTRIBUTED_MODE $DISTRIBUTED_MODE"
#     echo -e "$USAGE"
#     return -1
# fi

# NUM_VFs
# if [[ $CODER_IMPL == "FPGA" ]]; then
#     is_number_regex='[1-9]+'
#     if ! [[ $NUM_VFs =~ $is_number_regex ]] ; then
#         echo "[ERROR] Unsupported NUM_VFs $NUM_VFs"
#         echo -e "$USAGE"
#         return -1
#     fi
# fi

#################
# Script starts #
#################

# - Stop Hadoop
echo "[DEMO INIT] Stopping Hadoop deamons (if any)"
${HADOOP_HOME}/sbin/stop-dfs.sh
${HADOOP_HOME}/sbin/stop-yarn.sh
${HADOOP_HOME}/bin/mapred --daemon stop historyserver


# - Launch ActiveMQ + VFPs
if [[ $CODER_IMPL == "FPGA" ]]; then
    # Kill all Java processes, including VFPs and ActiveMQ
    # NOTE: this might be overkill, but works for a demo

    echo "[DEMO INIT] Killing all java processes on master"
    killall java

    for ip in "${slaves_ip_list[@]}"; do
        echo "[DEMO INIT] Killing all Java processes on $ip"
        ssh ${HADOOP_USER}@$ip "killall java"
    done

    # Launch VFP
    source ${ACTIVEMQ_ROOT}/scripts/stop_activemq.sh > /dev/null

    #echo "[LAUNCH ACTIVEMQ] Launching ActiveMQ on master"
    source ${ACTIVEMQ_ROOT}/scripts/launch_activemq.sh

    # for ip in "${slaves_ip_list[@]}"; do
    #     echo "[LAUNCH ACTIVEMQ]] Launching ActiveMQ on $ip"
    #     ssh ${HADOOP_USER}@$ip "bash -c 'source ${HDFS_DEMO}/settings.sh && \
    #                             source ${ACTIVEMQ_ROOT}/scripts/launch_activemq.sh'"
    # done

    # Heuristic sleep for JMSProvider safety
    sleep 2

    echo "[DEMO INIT] Launching VFProxying"
    #echo "[DEMO INIT] Launching VFProxying on master"
    source ${VFP_INSTALL}/scripts/launch_VFProxy_pool.sh $RS_SCHEMA $CELL_LENGTH
    #bash -x ${VFP_INSTALL}/scripts/launch_VFProxy_pool.sh $RS_SCHEMA $CELL_LENGTH

    #echo "pizza"

    for ip in "${slaves_ip_list[@]}"; do
        #echo "[DEMO INIT] Launching VFProxying on $ip"
        # ssh ${HADOOP_USER}@$ip "bash -x ${HDFS_DEMO}/settings.sh && \
        #                                 bash -x ${VFP_INSTALL}/scripts/launch_VFProxy_pool.sh \
        #                                 $RS_SCHEMA $CELL_LENGTH" 

        # Flag -f put SSH session in background
        # The source of the settings file is a workaround (aka o' pzzott)
        ssh -f ${HADOOP_USER}@$ip "bash -c 'source ${HDFS_DEMO}/settings.sh && \
                                            source ${VFP_INSTALL}/scripts/launch_VFProxy_pool.sh \
                                                    $RS_SCHEMA $CELL_LENGTH'" 

        # echo "ramem"
    done

    echo "[DEMO INIT master] Jps" 
    jps | egrep "DEMO INIT|activemq|VFProxy"

    for ip in "${slaves_ip_list[@]}"; do
        ssh ${HADOOP_USER}@$ip "echo [DEMO INIT $ip] Jps; jps" | egrep "DEMO INIT|activemq|VFProxy"
    done
fi

# - Only for distributed mode
#if [ ${DISTRIBUTED_MODE} -eq 1 ]; then
    # - Cleanse Hadoop
    #source ${HADOOP_ROOT}/recovery/hadoop_recovery.sh

    source ${HADOOP_ROOT}/recovery/hadoop_recovery.sh
    
    # - Start Hadoop
    echo "[DEMO INIT] Starting Hadoop (HDFS and YARN)"
    ${HADOOP_HOME}/sbin/start-dfs.sh
    ${HADOOP_HOME}/bin/hdfs dfsadmin -report | grep -i "Live datanodes"
    ${HADOOP_HOME}/sbin/start-yarn.sh
    ${HADOOP_HOME}/bin/yarn node -list | grep RUNNING
    ${HADOOP_HOME}/bin/mapred --daemon start historyserver
#fi

# - Enable EC
echo "[DEMO INIT] Launch EC policy setup"
source ${HADOOP_ROOT}/ec/enable_ec_policies.sh