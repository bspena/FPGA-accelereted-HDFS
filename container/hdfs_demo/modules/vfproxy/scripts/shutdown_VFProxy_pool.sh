# #!/bin/bash
# Description: Gracefully shutdown all active VFProxies through JMS messages. This only works if the VFP is running correctly. It must be forcefully killed otherwise.
# Arguments:
#   None

export VFP_DEBUG=1

# VFIO-bound VFs
# Skip PF0.VF0s
# SBDF_LIST=$( opae.io ls | sort | grep -v 0] | grep vfio | awk '{print $1}' | sed -E "s/(\[|\])//g" )
# SBDF_LIST_len=$(echo $SBDF_LIST | wc -w)


iommugroups=($(ls -d /dev/vfio/[0-9]*))

for iommugroup in "${iommugroups[@]}"; do
    num=$(basename $iommugroup)
    sbdf_list=($(ls /sys/kernel/iommu_groups/$num/devices/))
done

# Loop over availabe VFs
#for sbdf in ${SBDF_LIST}; do
for sbdf in "${sbdf_list[@]}"; do
    # Launch shut-down class
    java -classpath ${ACTIVEMQ_JAR}:${VFP_JAR} \
        -enableassertions \
        vfproxy.ShutDownVFProxy \
        $sbdf
done

# Clean up env
unset VFP_DEBUG
