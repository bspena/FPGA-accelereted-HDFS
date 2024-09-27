sudo apt-get update && \
sudo apt-get install -y pciutils kmod

export PAC_PCIE_SBD=$(lspci -D -d 8086:bcce | head -n1 | awk '{print $1}' | sed "s/\.0//g")


cd SYCL_AFU

source settings.sh

make opae.io_bind_all