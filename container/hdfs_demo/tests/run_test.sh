#!/bin/bash
# Description: Master script launching experiments
# Arguments:
#   $1: Experiment in:
#       all         Run, in sequence: ec, vpf, dfsio, terasort
#       ec          Single-core: single-thread EC latency and throughput
#       vfp         Single-node: multi-threaded EC latency and throughput (VFProxy)
#       dfsio       DFSIO read/write
#       terasort    Terasort + Teravalidate
#       dfsbasic    Basic DFS file operataions, for debug
#   $2...: Test-specific args TBD

###################
# Local variables #
###################
#TEST_DIR=${DEMO_ROOT}/tests
TEST_DIR=${DEMO_ROOT}/tests
USAGE="[RUN TEST] Missing arguments:
\$1: Target experiment, in:
    all         Run, in sequence: ec, vpf, dfsio, terasort
    ec          Single-core: single-thread EC latency and throughput
    vfp         Single-node: multi-threaded EC latency and throughput (VFProxy)
    dfsio       DFSIO read/write
    terasort    Terasort + Teravalidate
    dfsbasic    Basic DFS file operataions, intended for debug
    mapred      Basic MapReduce, intended for debug
\$2: EC policy, in: ${HDFS_EC_POLICIES[*]}
\$3...: Test-specific args TBD"

##############
# Parse args #
##############
# Expand the $@ macro
cnt=0
ALL_ARGS=()
for arg in $@; do
    ALL_ARGS[${cnt}]=$arg
    cnt=$(($cnt + 1))
done
# Discard first element
SCRIPT_ARGS=()
for (( i=1; i<= ${#ALL_ARGS[*]}; i++ )); do
    SCRIPT_ARGS[$(($i - 1))]=${ALL_ARGS[$i]}
    cnt=$(($cnt + 1))
done

# Test
TEST=$1
if [ "$TEST" == "" ]; then
    echo -e "$USAGE"
    return 1
fi

# EC policy
if [ "${SCRIPT_ARGS[0]}" == "" ]; then
    SCRIPT_ARGS[0]=RS-OPAE-3-2-1024k
fi

case $TEST in
    "all")
        echo "[DEMO TEST] Launching all tests..."
        echo TBD, uninmplemented
    ;;

    "EC"|"ec")
        echo "[DEMO TEST] Running single-core EC test..."
        echo TBD, uninmplemented
    ;;

    "vfp"|"VFP")
        echo "[DEMO TEST] Running single-node VFP test..."
        echo TBD, uninmplemented
    ;;

    "dfsio"|"DFSIO")
        echo "[DEMO TEST] Running distributed DFSIO test..."
        TARGET_SCRIPT=${TEST_DIR}/distributed/dfsio/test_dfsio.sh 
    ;;

    "tera"|"terasort"|"Terasort")
        echo "[DEMO TEST] Running distributed Terasort test..."
        TARGET_SCRIPT=${TEST_DIR}/distributed/terasort/test_terasort.sh 
    ;;
    "dfsbasic")
        echo "[DEMO TEST] Launching basic DFS test..."
        TARGET_SCRIPT=${TEST_DIR}/distributed/basic/dfs_basic.sh 
    ;;
    "mapred")
        echo "[DEMO TEST] Launching basic MapReduce test..."
        TARGET_SCRIPT=${TEST_DIR}/distributed/mapred/mapred.sh 
    ;;

    *)
        echo "[DEMO TEST] Unsupported argument test $1"
        echo -e "$USAGE"
        return 1
    ;;

esac

# Launch test
echo "[RUN TEST] Launch test script with args: ${SCRIPT_ARGS[*]}"
#${SSH_HADOOP_MASTER} source ${TARGET_SCRIPT} ${SCRIPT_ARGS[*]}
source ${TARGET_SCRIPT} ${SCRIPT_ARGS[*]}