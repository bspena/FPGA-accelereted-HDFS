#!/bin/bash
# Description: Generate experiment points for DFSIO
# Arguments:
# $1: Output file
# $2: Experimental EXPERIMENT_PROFILE
# $3: Number of repetitions

##############
# Parse args #
##############
OUT_FILE=$1
EXPERIMENT_PROFILE=${EXPERIMENT_PROFILE=QUICK}
if [[ $2 != "" ]]; then
    EXPERIMENT_PROFILE=$2
fi
NUM_REPS=${NUM_REPS=3}
if [[ $3 != "" ]]; then
    NUM_REPS=$3
fi

#####################
# Experiment design #
#####################
# - Design type: Full factorial
# - Factors:
#   - Number of files
#   - Size of files

case $EXPERIMENT_PROFILE in
    "MOCK")
        # Single test
        NR_FILES_list=(
            1
        )
        FILE_SIZE_list=(
            100MB
        )
        # Override
        NUM_REPS=1
        ;;
    "QUICK")
        # Quick test
        NR_FILES_list=(
            4 16 32
        )
        FILE_SIZE_list=(
            10MB 100MB 1GB
        )
        ;;
    "COMPLETE")
        # Complete test
        NR_FILES_list=(
            1 2 4 8 16 32 64
        )
        FILE_SIZE_list=(
            10MB 100MB 1GB 10GB
        )
        ;;
    *)
        printf "[ERROR] Experiment EXPERIMENT_PROFILE $1 not supported" >&2
        exit -1
        ;;
esac

# Debug
echo "[INFO EXP-GEN] Generting experiments for EXPERIMENT_PROFILE=$EXPERIMENT_PROFILE and NUM_REPS=$NUM_REPS on file $OUT_FILE"

############################
# Generate experiment list #
############################

# Prepend header
HEADER="NR_FILES,FILE_SIZE"
echo $HEADER > $OUT_FILE

# Clear tmp file
TMP_FILE=tmp.txt
printf "" > $TMP_FILE

# Loop over factor values
for (( rep=0; rep<$NUM_REPS; rep++ )); do
    for nrFiles in "${NR_FILES_list[@]}"; do
        for fileSize in "${FILE_SIZE_list[@]}"; do
            echo "$nrFiles,$fileSize" >> $TMP_FILE
        done
    done
done

# Shuffle experiment points
shuf $TMP_FILE >> $OUT_FILE
# Remove tmp file
rm $TMP_FILE

# Clean up
unset NUM_REPS
