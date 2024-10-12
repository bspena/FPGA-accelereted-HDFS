import os
import getpass

user = getpass.getuser()

#######################################
# Test configuration and result files #
#######################################
#path_test_list       = os.getcwd() + '/test_lists/test_list.csv'
#path_test_result     = os.getcwd() + '/test_results/test_result.csv'
path_test_list       = '/home/' + user + '/test/test_lists/test_list.csv'
path_test_result     = '/home/' + user + '/test/test_results/test_result.csv'


############################
# Test_list.csv parameters #
############################
# Independent factors
hdfs_t   = ('dfs.datanode.handler.count',)
mapred_t = ('mapreduce.map.cpu.vcores',)
yarn_t   = ('yarn.nodemanager.resource.cpu-vcores',)
dfsio_t  = ('dfsio.nrFiles','dfsio.fileSize')
teragen_t = ('',) # TBD
#test_list_columns = hdfs_t + mapred_t + yarn_t + dfsio_t + teragen_t
test_list_columns = hdfs_t + mapred_t + dfsio_t
# Number of repetitions for each test
test_list_num_repetitions = 1


############################
# Columns for test results #
############################
# Colums names for dataframe with response variables from mapreduce commands
columns_mapred_commands = ['maps.number','cpu.time.map.task','cpu.time.reduce.tasks','cpu.time.tot']
#columns_mapred_commands = ['cpu.time.map.task','cpu.time.reduce.tasks','cpu.time.tot']

# Colums names for dataframe with response variables from TestDFSIO logs 
columns_dfsio_logs = ['throughput_value','average_io_value']

# Column names for test result dataframe
df_test_result_columns = columns_mapred_commands + columns_dfsio_logs


##########
# Hadoop #
##########
# Get HADOOP_HOME from env
HADOOP_HOME = os.environ['HADOOP_HOME']
# Hadoop configuration files
# path_hdfs_site       = HADOOP_HOME + '/etc/hadoop/hdfs-site.xml'
# path_mapred_site     = HADOOP_HOME + '/etc/hadoop/mapred-site.xml'
# path_yarn_site       = HADOOP_HOME + '/etc/hadoop/yarn-site.xml'
path_hdfs_site       = '/home/' + user + '/hadoop_config/hdfs-site.xml'
path_mapred_site     = '/home/' + user + '/hadoop_config/mapred-site.xml'
path_yarn_site       = '/home/' + user + '/hadoop_config/yarn-site.xml'


# HTTP addresses
# TODO: import from hdfs-site.xml
dfs_namenode_http_address = "master:9870"
# TODO: import from YARN-site.xml
yarn_resourcemanager_webapp_address = "master:8032"


#########
# DFSIO #
#########
# Path to DFSIO JAR
path_dfsio_jar = HADOOP_HOME + '/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.5-tests.jar'
# Path to DFSIO logfile
#path_test_dfsio_logs = os.getcwd() + '/logs/TestDFSIO_results.log'
path_test_dfsio_logs = '/home/' + user + '/test/logs/TestDFSIO_results.log'


###########
# Teragen #
###########
# Path to Teragen JAR
path_teragen_jar = HADOOP_HOME + '/<path-to>/hadoop-mapreduce-examples-3.4.0.jar'
# path_teragen_output = # TBD
# path_terasort_output = # TBD
# path_teravalidate_output = # TBD


########################### DO NOT MODIFY ######################################

# TODO: what to do with this?
# String array with the special parameters needed for the cluster configuration in psuedo-distributed mode
#dont_touch_parameters = []
# dont_touch_parameters = ['dfs.replication','mapreduce.framework.name','mapreduce.application.classpath','yarn.nodemanager.aux-services','yarn.nodemanager.env-whitelist']
# From old cluster
# dont_touch_parameters = [
#                         'yarn.nodemanager.vmem-check-enabled',
#                         'yarn.nodemanager.aux-services',
#                         'yarn.acl.enable'
#                     ]
