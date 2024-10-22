#!/bin/bash
# Description: Release all VFs from VFIO
# Parameters:
#   None

# Exclude PF0.VF0 (B:00.0)
OPAEIO_SDBFs=$( opae.io ls | grep -v ${PAC_PCIE_SBD}.0 | awk '{print $1}' | sed -E "s/(\[|\])//g" )
for sbdf in ${OPAEIO_SDBFs}; do
    echo "[OPAE.IO $HOSTNAME] Relasing $sbdf"
    sudo opae.io release -d $sbdf
done

echo "[OPAE.IO $HOSTNAME] Setting zero VFs"
sudo pci_device ${PAC_PCIE_SBD}.0 vf 0

# Unset envvars
unset SBDFs
unset SBDFs_COMMA_SEPARATED