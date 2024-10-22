#!/bin/bash
# Description: Power-cycle PAC on target bootpage
# Parameters:
#   $1: REQUESTED_VFs: number of requested VFs

REQUESTED_VFs=100
if [[ $1 != "" ]]; then
    REQUESTED_VFs=$1
fi
# Initial setup
SRIOV_NUMVF=$(sudo find /sys/ -wholename "*/${PAC_PCIE_SBD}.0/sriov_numvfs" | head -n1 | xargs cat)
SRIOV_TOTVF=$(sudo find /sys/ -wholename "*/${PAC_PCIE_SBD}.0/sriov_totalvfs" | head -n1 | xargs cat)
echo "[OPAE.IO $HOSTNAME] Found $SRIOV_NUMVF sriov_numvfs"
echo "[OPAE.IO $HOSTNAME] Found $SRIOV_TOTVF sriov_totalvfs"
echo "[OPAE.IO $HOSTNAME] Requested $REQUESTED_VFs VFs"
# Min(REQUESTED_VFs, SRIOV_TOTVF)
TARGET_VFs=$REQUESTED_VFs
if [ $TARGET_VFs -gt $SRIOV_TOTVF ]; then
    TARGET_VFs=$SRIOV_TOTVF
fi

# Setup TARGET_VFs
if [ $TARGET_VFs -gt 0 ]; then
    echo "[OPAE.IO $HOSTNAME] Setting up ${TARGET_VFs} VFs"
    
    # Create new VFs
    sudo pci_device ${PAC_PCIE_SBD}.0 vf ${TARGET_VFs}

    # FIM and PR AFUs VFs
    # Exclude PF0.VF0 (BB:00.0) and BB:01.0
    # NOTE: BB:01.0 would not bind on Ubuntu, but is safe to use on RHEL
    OPAEIO_SDBFs=$( opae.io ls | sort | grep -v "\.0" | awk '{print $1}' | sed -E "s/(\[|\])//g" )
    for sbdf in ${OPAEIO_SDBFs}; do
        sudo opae.io init -d $sbdf $HADOOP_USER:$HADOOP_USER
    done

    SRIOV_NUMVF=$(sudo find /sys/ -name "sriov_numvfs" | grep ${PAC_PCIE_SBD} | xargs cat)
    echo "[OPAE.IO $HOSTNAME] Setup $SRIOV_NUMVF sriov_numvfs"
fi

# Set envvars
export SBDFs=$( opae.io ls | sort | grep -v "\.0" | grep vfio | awk '{print $1}' | sed -E "s/(\[|\])//g" )
export SBDFs_COMMA_SEPARATED=$( echo $SBDFs | sed "s/ /,/g" )