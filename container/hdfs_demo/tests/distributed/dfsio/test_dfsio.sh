#!/bin/bash
# Description: Master script for DFSIO tests
# Arguments:
#   $1: EC_POLICY

##############
# Parse args #
##############
EC_POLICY=$1

###################
# Local variables #
###################
# Root dir of measurement scripts
DFSIO_ROOT=${DEMO_ROOT}/tests/distributed/dfsio
# Output data directory
DFSIO_DATA_DIR=/tmp/test_dfsio_data
# Slave script
RUN_DFSIO_SCRIPT=${DFSIO_ROOT}/run_dfsio.sh
# Command list for slave script
# NOTE: DFSIO needs a write in order to run a read
DFSIO_COMMAND_list=("write" "read")

# Response variables parse strings
THROUGHPUT_STRING="Throughput mb/sec:"
IO_RATE_STRING="Average IO rate mb/sec"
RUNTIME_STRING="Test exec time sec"


#####################
# Setup environment #
#####################
# Number of reconstruction for each client
# export EXPERIMENT_PROFILE=${EXPERIMENT_PROFILE="COMPLETE"}
# export EXPERIMENT_PROFILE=${EXPERIMENT_PROFILE="QUICK"}
export EXPERIMENT_PROFILE=${EXPERIMENT_PROFILE="MOCK"}
# Creat output data dir
mkdir -p $DFSIO_DATA_DIR

########################
# Generate experiments #
########################
EXP_FILE=${DFSIO_ROOT}/tmp.experiments.dfsio.csv
rm -f $EXP_FILE
source ${DFSIO_ROOT}/gen_experiements_dfsio.sh $EXP_FILE $EXPERIMENT_PROFILE
unset EXPERIMENT_PROFILE

# Read experimental points
readarray -t experiment_list < $EXP_FILE
if [ ${#experiment_list[@]} -eq 0 ]; then
    echo "[ERROR $HOSTNAME] Experiment list is empty, aborting..." >&2
    return -1
fi

##############
# Start runs #
##############

# For each line in experiment_list, skipping header
for (( exp_index=1; exp_index<${#experiment_list[@]}; exp_index++ )); do
    # Print info
    echo "[INFO TOP ${RS_SCHEMA}]: Running experiment $exp_index/$(( ${#experiment_list[@]} -1 )) ${experiment_list[$exp_index]}"

    # Parse factors' values
    NR_FILES=$(  echo ${experiment_list[$exp_index]} | awk -F ","  '{print $1}' )
    FILE_SIZE=$( echo ${experiment_list[$exp_index]} | awk -F ","  '{print $2}' )
    
    # ########################
    # # Run read/write tests #
    # ########################
    for COMMAND in "${DFSIO_COMMAND_list[@]}"; do
        # Factor levels combination
        FACTORS=${COMMAND}_nrFiles${NR_FILES}_fileSize${FILE_SIZE}
        # Output file
        OUT_FILE=$DFSIO_DATA_DIR/${FACTORS}.csv
        # Result file
        RESULT_FILE=/tmp/dfsio_${FACTORS}.txt

        # Launch test
        echo "[DFSIO] Running DFSIO test ${FACTORS}"
        source ${RUN_DFSIO_SCRIPT} \
            $COMMAND \
            $NR_FILES \
            $FILE_SIZE \
            $RESULT_FILE \
            $EC_POLICY

        # Grep results from output file
        dfsio_throughput=$(grep "$THROUGHPUT_STRING" $RESULT_FILE | awk '{print $3}' )
        dfsio_io_rate=$(grep "$IO_RATE_STRING" $RESULT_FILE | awk '{print $5}' )
        runtime=$(grep "$RUNTIME_STRING" $RESULT_FILE | awk '{print $5}' )

        # Find jobID
        # job_id_cmd="${HADOOP_HOME}/bin/mapred job -list all | grep 'job_'"
        # job_id_output=$(eval "$job_id_cmd")
        # job_id=$(echo "$job_id_output" | awk '{print $1}')

        # # Find number of map tasks
        # mappers_cmd="$HADOOP_HOME/bin/mapred job -status $job_id | grep 'Number of maps'"
        # mappers_output=$(eval "$mappers_cmd")
        # mappers=$(echo "$mappers_output" | awk -F':' '{print $2}')
        # #mappers=$(echo "$mappers_output" | awk '{print $2}')

        # # Find the cpu time
        # cpu_time_cmd = "${HADOOP_HOME}/bin/mapred job -history $job_id | grep 'CPU time spent'"
        # cpu_time_output=$(eval "$cpu_time_cmd")
        # cpu_time_map=$(echo "$cpu_time_sub" | tr -d ',' | awk -F'|' '{print $3}')
        # cpu_time_red=$(echo "$cpu_time_sub" | tr -d ',' | awk -F'|' '{print $4}')
        # cpu_time_tot=$(echo "$cpu_time_sub" | tr -d ',' | awk -F'|' '{print $5}')

        # Save results
        echo $dfsio_throughput,$dfsio_io_rate,$runtime >> $OUT_FILE
        #echo $dfsio_throughput,$dfsio_io_rate,$runtime,$mappers,$cpu_time_map,$cpu_time_red,$cpu_time_tot >> $OUT_FILE

        # Clean up
        # NOTE: instead of remove this file, it could be parsed in a subsequent loop to clear the repetition issue
        rm $RESULT_FILE
    done # COMMAND

    ############
    # Clean up #
    ############
    echo "[DFSIO] Running DFSIO clean"
    source ${RUN_DFSIO_SCRIPT} clean

done # exp_index
