#!/bin/bash
# Description: Run single DFSIO benchmark
# Arguments:
#   $1: COMMAND in [read|write]
#   $2: NUM_FILES -nrFiles: the number of files (equal to the number of map tasks)
#   $3: FILE_SIZE -fileSize: the size of a file to generate B|KB|MB|GB|TB is allowed
#   $4: RESULT_FILE

COMMAND="write"
if [[ $1 != "" ]]; then
    COMMAND=$1
    # if [[ $COMMAND == "read" ]]; then
    #     echo "If no data was previously written on HDFS, this command will fail"
    # fi
fi

NR_FILES=16
if [[ $2 != "" ]]; then
    NR_FILES=$2
fi

FILE_SIZE=100MB
if [[ $3 != "" ]]; then
    FILE_SIZE=$3
fi

RESULT_FILE=/tmp/$USER-dfsio-$COMMAND.txt
if [[ $4 != "" ]]; then
    RESULT_FILE=$4
fi

EC_POLICY=RS-3-2-1024k
if [[ $5 != "" ]]; then
    EC_POLICY=$5
fi

JAR_FILE=${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-${HADOOP_VERSION}-tests.jar 
echo "DFSIO command:    $COMMAND"
echo "Number of files:  $NR_FILES"
echo "File size:        $FILE_SIZE"
echo "Result file:      $RESULT_FILE"
echo "Jar file:         $JAR_FILE"

# Prepare log directory
mkdir -p ${DFSIO_ROOT}/logs

# Compose command
LOG_FILE=${DFSIO_ROOT}/logs/${COMMAND}_nrFiles${NR_FILES}_fileSize${FILE_SIZE}.log # TODO: differenciate between repetitions
DFSIO_CMD="${HADOOP_HOME}/bin/hadoop jar $JAR_FILE TestDFSIO -$COMMAND \
    -nrFiles $NR_FILES \
    -fileSize $FILE_SIZE \
    -resFile $RESULT_FILE \
    -erasureCodePolicy $EC_POLICY \
    2>&1 | tee ${LOG_FILE}"

# Launch command
ssh hadoop@master ${DFSIO_CMD}
#${DFSIO_CMD}

# if [[ $COMMAND != "clean" ]]; then
#     echo "Result file: $RESULT_FILE"
# fi


#${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-${HADOOP_VERSION}-tests.jar TestDFSIO -write -erasureCodePolicy RS-3-2-1024k
