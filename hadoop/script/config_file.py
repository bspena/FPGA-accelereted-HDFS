# Files path
path_hdfs_site = '/home/spena/hadoop/hadoop-dist/target/hadoop-3.3.5/etc/hadoop/hdfs-site.xml'
path_mapred_site = '/home/spena/hadoop/hadoop-dist/target/hadoop-3.3.5/etc/hadoop/mapred-site.xml'
path_yarn_site = '/home/spena/hadoop/hadoop-dist/target/hadoop-3.3.5/etc/hadoop/yarn-site.xml'
path_test_list = 'test_list.csv'
path_test_result = 'test_result.csv'
path_test_dfsio_logs = '/home/spena/Downloads/TestDFSIO_results.log'

# Tuples with the test_list.csv parameters
hdfs_t = ('dfs.datanode.handler.count',)
mapred_t = ('mapreduce.map.cpu.vcores',)
yarn_t = ('yarn.scheduler.minimum-allocation-vcores',)
dfsio_t = ('dfsio.nrFiles','dfsio.fileSize','dfsio.resFile')

# Colums names for dataframe with response variables from mapreduce commands
cn_mapred_commands = ['maps.number','cpu.time.map.task','cpu.time.reduce.tasks','cpu.time.tot']

# Colums names for dataframe with response variables from TestDFSIO logs 
cn_dfsio_logs = ['throughput_value','average_io_value']



########################### DO NOT MODIFY ######################################

# String array with the special parameters needed for the cluster configuration in psuedo-distributed mode
special_parameters = ['dfs.replication','mapreduce.framework.name','mapreduce.application.classpath','yarn.nodemanager.aux-services','yarn.nodemanager.env-whitelist']