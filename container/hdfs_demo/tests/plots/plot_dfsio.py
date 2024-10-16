import matplotlib.pyplot as plt
import glob
import pandas
import numpy
import sys
import os
import plot_common as common

# Source data directory
root_data_dir = "/tmp/test_dfsio_data"
if len(sys.argv) > 1:
	root_data_dir = sys.argv[1]

# Output directory for plots
plot_dir = "./output_plots"
if len(sys.argv) > 2:
	plot_dir = sys.argv[2]

# Create output directory
os.makedirs(plot_dir, exist_ok=True)


DFSIO_COMMAND_list=["write", "read"]
NR_FILES_list=[1, 2, 4, 8, 16, 32, 64,]
FILE_SIZE_list=["10MB", "100MB", "1GB", "10GB",]


#############
# Read data #
#############
# Preallocate arrays
throughput_MBs 		= [[[[[0. 
						for _ in range(len(FILE_SIZE_list))			]  
	                    for _ in range(len(NR_FILES_list)) 			] 
						for _ in range(len(DFSIO_COMMAND_list))		] 
                        for _ in range(len(common.RS_SCHEMA_list))	]
                        for _ in range(len(common.hw_configs))		]
average_io_rate_MBs = [[[[[0. 
						for _ in range(len(FILE_SIZE_list))			]  
	                    for _ in range(len(NR_FILES_list)) 			] 
						for _ in range(len(DFSIO_COMMAND_list))		] 
                        for _ in range(len(common.RS_SCHEMA_list))	]
                        for _ in range(len(common.hw_configs))		]
runtime_s = [[[[[0. 
						for _ in range(len(FILE_SIZE_list))			]  
	                    for _ in range(len(NR_FILES_list)) 			] 
						for _ in range(len(DFSIO_COMMAND_list))		] 
                        for _ in range(len(common.RS_SCHEMA_list))	]
                        for _ in range(len(common.hw_configs))		]

for hw in range(0,len(common.hw_configs)):
	for rs in range(0,len(common.RS_SCHEMA_list)):
		for cmd in range(0,len(DFSIO_COMMAND_list)):
			for nrFiles in range(0,len(NR_FILES_list)):
				for fileSize in range(0,len(FILE_SIZE_list)):
					# Compose filename:
					# ${dfsio_cmd}_nrFiles${NR_FILES}_fileSize${FILE_SIZE}.csv
					file_name = root_data_dir + '/' + DFSIO_COMMAND_list[cmd] + "_nrFiles" + str(NR_FILES_list[nrFiles]) + "_fileSize" + FILE_SIZE_list[fileSize] + '.csv'
					file_name_ref = glob.glob(file_name)
					if ( len(file_name_ref) != 1 ): 
						print("File name error: " + file_name)
						df = numpy.inf
						continue
					
					# Load data
					try:
						df = pandas.read_csv(file_name_ref[0], sep=",", header=None)
					except:
						print("File name error: " + file_name)
						df = numpy.inf

					# Save average/median
					# throughput_MBs[rs][hw][cmd][fileSize][nrFiles] = df[0].median()
					# throughput_MBs[rs][hw][cmd][fileSize][nrFiles] = df[1].median()
					throughput_MBs[rs][hw][cmd][nrFiles][fileSize] = df[0].mean()
					average_io_rate_MBs[rs][hw][cmd][nrFiles][fileSize] = df[1].mean()
					runtime_s[rs][hw][cmd][nrFiles][fileSize] = df[2].mean()

##########
# Figure #
##########
plt.figure("", figsize=common.figsize_1column)
ax = plt.subplot(1,2,1)
# plt.tick_params(labelbottom=False, bottom=False)
for hw in range(0,len(common.hw_configs)):
	for rs in range(0,len(common.RS_SCHEMA_list)):
		for cmd in range(0,len(DFSIO_COMMAND_list)):
			ax = plt.subplot(1,2,cmd +1, sharey=ax)
			plt.title(DFSIO_COMMAND_list[cmd])
			for nrFiles in range(0,len(NR_FILES_list)):
				plt.semilogy(
							FILE_SIZE_list, 
							runtime_s[rs][hw][cmd][nrFiles],
							# common.hw_line[hw] + common.hw_marker[hw],
							"-o",
							label=str(NR_FILES_list[nrFiles]) + " file(s)"
						)
				# # Decorating
				plt.xlabel("File Size")
				plt.ylabel("s")
				# plt.xticks(FILE_SIZE_list)
				plt.grid(visible=True) #, which="both")
				plt.legend()
figname = plot_dir + "/" + "dfsio" + ".png"
plt.savefig(figname, dpi=400, bbox_inches="tight")
print("Figure available at " + figname)


