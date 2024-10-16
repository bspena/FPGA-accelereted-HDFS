import numpy

# Common utilities and constants

################
# Figure sizes #
################
# 1 column
figsize_1column=[16,9]
# 2 columns
figsize_2columns=[16,4.5]

###############
# Set formats #
###############

# Hardware configurations
hw_configs = ["ISA-L"]#, "SYCL_AFU"]
ISA_L		= 0
# SYCL_AFU  	= 1

# Source data directories
data_dirs = ["" for _ in range(len(hw_configs)) ]
data_dirs[ISA_L   ]	= "/data_ISA_L/"
# data_dirs[SYCL_AFU] = "/data_SYCL_AFU/"

# Plot formats
hw_marker 		= ["" for _ in range(len(hw_configs)) ]
hw_line 		= ["" for _ in range(len(hw_configs)) ]
hw_linewidth	= ["" for _ in range(len(hw_configs)) ]
hw_color		= ["" for _ in range(len(hw_configs)) ]
hw_name			= ["" for _ in range(len(hw_configs)) ]

# ISA-L format
hw_marker		[ISA_L] = "*"
hw_line	 		[ISA_L] = "--"
hw_linewidth	[ISA_L] = 1
hw_color		[ISA_L] = "purple"
hw_name			[ISA_L] = "ISA-L AVX-512"

# # SYCL AFU format
# hw_marker		[SYCL_AFU] = "o"
# hw_line	 		[SYCL_AFU] = "-"
# hw_linewidth	[SYCL_AFU] = 2
# hw_color		[SYCL_AFU] = "b"
# hw_name			[SYCL_AFU] = "SYCL AFU"

########################
# Reed-Solomon formats #
########################
RS_SCHEMA_list = ["3_2"]#, "6_3" ]
RS_SCHEMA_txt  = ["RS[3:2]", "RS[6:3]" ]
RS_color = ["g", "b"]
RS_3_2 = 0
#RS_6_3 = 1
# Arrays of K:P values
RS_K_list = [3, 6]
RS_P_list = [2, 3]

###############
# Data length #
###############

KB = 1024
MB = 1024 * KB
GB = 1024 * MB

###############
# Cell length #
###############

# cell_length = [ 
# 				# "64B"	,	"128B",	"256B",	"512B", 
# 				"1KB"	,	"2KB"	,	"4KB"	,	"8KB"	,	"16KB"	,
# 				"32KB"	,	"64KB"	,	"128KB"	, 	"256KB"	,	"512KB"	,
# 				"1MB"	,	"2MB"	,	"4MB"	,	"8MB"	, 	"16MB"	,
# 				#  "32MB"	,	"64MB"#	,	"128MB"	, 	"256MB"	,	"512MB"	,
# 				]
# cell_length_int = [ 
# 					# 64				, 128			, 256			, 512			, 
# 					1*KB	, 2*KB    , 4*KB    , 8*KB	 	, 16*KB 	,
# 					32*KB	, 64*KB   , 128*KB  , 256*KB	, 512*KB 	,
# 					1*MB    , 2*MB    , 4*MB    , 8*MB		, 16*MB 	,
# 					# 32*MB  , 64*MB   #, 128*MB  , 256*MB, 512*MB ,
# 				]

##################
# PCIe bandwidth #
##################

# Figure Throughput
B_s		= [ "100MB/s", "1GB/s", "10GB/s"]
B_s_int = [ 100*MB, 1*GB, 10*GB]
# Data for max physical throughput for PCIe Gen4 x16
PCIE_PHY_BANDWIDTH = 32 * GB # 32 GB/s
# Max read bandwidth as reported by "aocl diagnose acl0"
PCIE_ASP_BANDWIDTH = 16 * GB # 16 GB/s
# PAC is full duplex 32GB/s tx and 32G/s rx, tx and rx bandwidth should hinder each other, 
# therefore we just need to consider the worst case, which is reading the K input blocks
data_amount = [0. for _ in range(len(RS_SCHEMA_list))]
data_amount = numpy.array(data_amount)
data_amount [RS_3_2] = RS_K_list[RS_3_2]
# data_amount [RS_6_3] = RS_K_list[RS_6_3]

# Derive arrays
peak_phy_throughput = PCIE_PHY_BANDWIDTH / data_amount
peak_asp_throughput = PCIE_ASP_BANDWIDTH / data_amount