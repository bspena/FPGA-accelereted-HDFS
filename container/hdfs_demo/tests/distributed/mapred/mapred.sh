#!/bin/bash
# Description: Run basic MapReduce application (grep) on DFS file
# Arguments:
#   $1: EC policy

##############
# Parse args #
##############
NUM_EXPECTED_ARGS=2
USAGE="Missing arguments:
  \$1: EC policy, in: ${HDFS_EC_POLICIES[*]}
  \$2: SIZE of file in bytes"

if [ $# -lt $NUM_EXPECTED_ARGS ]; then
    echo -e "$USAGE"
    return 1
fi
POLICY=$1
SIZE=$2

###################
# Local variables #
###################
SOURCE_FILE_NAME=tmpfile
DFS_DIR=/tmp-mapred/
DFS_FILE_NAME=$DFS_DIR/$SOURCE_FILE_NAME

# Prepare directory
echo "[MAPRED BASIC] Prepare directory on DFS"
hdfs dfs -mkdir $DFS_DIR
hdfs dfs -rm -r $DFS_DIR/*
# Set EC policy (assume enabled)
hdfs ec -setPolicy -path $DFS_DIR/ -policy $POLICY

# Prepare test file
echo "[MAPRED BASIC] Prepare input file"
# One byte per character, plus one new line char per line
NUM_CHARS=$(($SIZE / 2))
rm -f $SOURCE_FILE_NAME
for (( rep=0; rep<$NUM_CHARS; rep++ )); do
    echo $(($RANDOM % 10)) >> $SOURCE_FILE_NAME
done

# Copy file to DFS
echo "[MAPRED BASIC] Copy file to DFS"
hdfs dfs -put -f $SOURCE_FILE_NAME $DFS_DIR
hdfs dfs -ls $DFS_DIR

# Mapred grep
echo "[MAPRED BASIC] Mapred grep from DFS"
GREP_OUT_DIR=$DFS_DIR/grep-output
GREP_STRING=5
hadoop jar \
    $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
    grep \
    $DFS_FILE_NAME \
    $GREP_OUT_DIR \
    $GREP_STRING

echo "[MAPRED BASIC] Compare results"
HDFS_CAT_CMD="hdfs dfs -cat $GREP_OUT_DIR/part-*"
echo "[MAPRED BASIC] MapReduce grep found: $($HDFS_CAT_CMD) matches"
LOCAL_GREP="grep $GREP_STRING $SOURCE_FILE_NAME"
echo "[MAPRED BASIC] Local grep found: $($LOCAL_GREP | wc -l) $GREP_STRING matches"

# Clean up
echo "[MAPRED BASIC] Cleaning up local files"
rm -rvf $SOURCE_FILE_NAME $READ_BACK_FILE_NAME
echo "[MAPRED BASIC] Cleaning up DFS files"
hdfs dfs -rm -r $DFS_DIR
