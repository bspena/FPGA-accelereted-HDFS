#!/bin/bash
# Description: Power-cycle PAC on target bootpage
# Parameters:
#   $1: RS_SCHEMA in {RS_3_2, RS_6_3}

# Parse args
RS_SCHEMA=$1

# Select over RS_SCHEMA envvar
case ${RS_SCHEMA} in
    "RS_3_2")
        # Assuming boot page "user1" contains flat 13xRS_3_2
        TARGET_BOOT_PAGE=user1
        ;;
    "RS_6_3")
        # Assuming boot page "user2" contains flat 6xRS_6_3
        TARGET_BOOT_PAGE=user2
        ;;
    *)
        echo "[Error $HOSTNAME] Unsupported RS_SCHEMA=${RS_SCHEMA}, must be in {RS_3_2, RS_6_3}"
        return 1
        ;;
esac

# Get current bootpage
CURRENT_BOOT_PAGE=$(fpgainfo fme | grep "Boot Page" | awk $'{print $4}')

# Save power-cycle if not necessary
# NOTE: this assumes the PAC is in a safe state, which might be over-optimistic
if [ "${CURRENT_BOOT_PAGE}" != "${TARGET_BOOT_PAGE}" ]; then
    echo "[FPGA $HOSTNAME] Power-cycling PAC on boot page ${TARGET_BOOT_PAGE} for ${RS_SCHEMA}"
    sudo rsu fpga --page=${TARGET_BOOT_PAGE} ${PAC_PCIE_SBD}.0
else
    echo "[FPGA $HOSTNAME] Skipping PAC power-cycle, already on boot page ${TARGET_BOOT_PAGE} for ${RS_SCHEMA}"
fi