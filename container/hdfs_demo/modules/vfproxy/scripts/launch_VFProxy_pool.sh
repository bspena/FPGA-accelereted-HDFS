#!/bin/bash
# Description: Launch a pool of VFProxies over VFs (already mapped to VFIO)
# Arguments:
#   $1: Maximum number of VFPs to launch
#   $2: RS_SCHEMA
#   $3: Cell Length

##############
# Parse args #
##############
#NUM_VFs=$1
RS_SCHEMA=$1
CELL_LENGTH=$2

#if [ "$NUM_VFs" == "" ] ||
if [ "$RS_SCHEMA" == "" ] ||
    [ "$CELL_LENGTH" == "" ]; then
    #echo "[VFP POOL $(hostname)] Wrong arguments \$1=$1 \$2=$2 \$3=$3"
    echo "[VFP POOL $(hostname)] Wrong arguments \$1=$1 \$2=$2"
    return -1
fi

# Parse VFIO-bound VFs
# - Skip PFx.VF0s
# - Limit the number of VFs for this run
#SBDF_LIST=$( opae.io ls | sort | grep -v 0] | awk '{print $1}' | sed -E "s/(\[|\])//g" | tail -n $NUM_VFs )
#SBDF_LIST=$( opae.io ls | sort | grep -v 0] | awk '{print $1}' | sed -E "s/(\[|\])//g" )
# SBDF_LIST_len=$(echo $SBDF_LIST | wc -w)

# for i in "${SBDF_LIST[@]}"; do
#     echo "$i"
# done

# iommugroups=($(ls -d /dev/vfio/[0-9]*))

# for iommugroup in "${iommugroups[@]}"; do
#     num=$(basename $iommugroup)
#     sbdf_list=($(ls /sys/kernel/iommu_groups/$num/devices/))
# done

# export SBDFs_COMMA_SEPARATED=$( echo $sbdf_list | sed "s/ /,/g" )

# VFP environment
unset VFP_DEBUG
unset VFP_DEBUG_ARRAY
export VFP_DEBUG=1
# export VFP_DEBUG_ARRAY=1

# Create log directory
mkdir -p ${VFP_LOG_DIR}

# Start a VFP for each VF
export RS_K=${RS_SCHEMA:3:1}
export RS_P=${RS_SCHEMA:5:1}


i=0
#for sbdf in ${SBDF_LIST}; do
for sbdf in "${sbdf_list[@]}"; do

    iommugroup=$(basename ${iommugroups[$i]})
    echo "[VFP POOL $(hostname)] Launching VFP SBDF=$sbdf, IOMMUGROUP=$iommugroup, CELL_LENGTH=${CELL_LENGTH}"
    # Send in background

    java -classpath ${ACTIVEMQ_JAR}:${VFP_JAR} \
        -Djava.library.path=${VFP_NATIVE_DIR} \
        -enableassertions \
        -XX:+PrintJNIGCStalls \
        vfproxy.VFProxy \
        $sbdf $RS_K $RS_P ${CELL_LENGTH} \
         > ${VFP_LOG_DIR}/VFP_$sbdf.log &
    # Sleep between launches
    sleep 0.5
    #sleep 2
    #echo "lollo"

    ((i++))
done

#echo "peffffforza"