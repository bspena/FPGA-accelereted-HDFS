#!/bin/bash
# Description: Perform basic DFS file operations
# Arguments:
#   $1: EC policy
#   $2: File size (in B, KB, MB, ...)

##############
# Parse args #
##############
NUM_EXPECTED_ARGS=2
USAGE="Expecting $NUM_EXPECTED_ARGS arguments:
  \$1: EC policy, in: ${HDFS_EC_POLICIES[*]}
  \$2: File size (in B, KB, MB, ...)"

if [ $# -ne $NUM_EXPECTED_ARGS ]; then
    echo -e "$USAGE"
    return 1
fi
POLICY=$1
SIZE=$2

###################
# Local variables #
###################
SOURCE_FILE_NAME=tmpfile
DFS_DIR=/tmp-dfsbasic
DFS_FILE_NAME=$DFS_DIR/$SOURCE_FILE_NAME
READ_BACK_FILE_NAME=tmpfile.readback

# Prepare directory
echo "[DFS BASIC] Prepare directory on DFS"
hdfs dfs -mkdir $DFS_DIR
hdfs dfs -rm $DFS_DIR/*
# Set EC policy (assume enabled)
hdfs ec -setPolicy -path $DFS_DIR -policy $POLICY

# Prepare test file
echo "[DFS BASIC] Prepare input file"
dd if=/dev/urandom of=$SOURCE_FILE_NAME bs=$SIZE count=1

# Copy file to DFS
echo "[DFS BASIC] Copy file to DFS"
hdfs dfs -put -f $SOURCE_FILE_NAME $DFS_DIR
hdfs dfs -ls $DFS_DIR

# Read back from DFS
echo "[DFS BASIC] Read back file to DFS"
hdfs dfs -get -f $DFS_FILE_NAME $READ_BACK_FILE_NAME

# Compare files (hashes)
echo "[DFS BASIC] Compare files"
md5sum $SOURCE_FILE_NAME $READ_BACK_FILE_NAME
HASH_MATCH=$(md5sum $SOURCE_FILE_NAME $READ_BACK_FILE_NAME | awk '{print $1}' | uniq | wc -l)
if [ $HASH_MATCH -ne 1 ]; then
    echo "[DFS BASIC] [ERROR] Files do not match"
else
    echo "[DFS BASIC] [SUCCESS] Successful readback"
fi

# Clean up
echo "[DFS BASIC] Cleaning up"
rm -rvf $SOURCE_FILE_NAME $READ_BACK_FILE_NAME
hdfs dfs -rm -f $DFS_FILE_NAME
