
import xml.etree.ElementTree as xmlET                     # For parsing and creating XML data
import subprocess                                         # For spawning new processes and capture stout/stderr
import os                                                 # For OS command proxying
# import requests                                           # For HTTP requests (broken in Python 3.11)
import pandas                                             # For Pandas Dataframes
import multiprocessing as mp                              # For spawning new processes
import inspect                                            # For debug prints
import hdfs_test_config as config                         # HDFS test configuration file

######################
# 0. Debug utilities #
######################

def debug_print(prefix, msg):
    print(prefix + " " + __file__ + ":" + str(inspect.currentframe().f_lineno) + ": " + msg )

def print_warning( msg ):
    debug_print("[WARNING]", msg )

def print_error( msg ):
    debug_print("[ERROR]", msg )

# Check if test_list.csv independent factors are equal to tuples Independent factors
def assert_config():
    df_test_list = pandas.read_csv(config.path_test_list)  
    for value in config.test_list_columns:
        assert ( value in list(df_test_list.columns) ), "Property " + value + " not in " + config.path_test_list

def dump_config():
    print("Test factors: " + str(config.test_list_columns))
    print("Number of repetitions: " + str(config.test_list_num_repetitions))

# Create a .csv from test_list_columns configuration 
def gen_test_list_header(path_test_list):
    df = pandas.DataFrame(columns=config.test_list_columns, index=None)
    df.to_csv(path_test_list, index=None)


###########################
# 1. Initialization utils #
###########################

# Function to create one dataframe from test_list.csv and one needed for test_result.csv
def initTest_create_dataframe():

    # Read test_list.csv
    df_test_list = pandas.read_csv(config.path_test_list)                 
    
    # Expand by the number of repetitions
    df_test_list = pandas.concat([df_test_list]*config.test_list_num_repetitions, ignore_index=True)

    # Reshuffle for randomness
    df_test_list = df_test_list.sample(frac=1).reset_index(drop=True)

    # Create custom indeces
    tests_numbers = []
    for i in range(1,len(df_test_list.index)+1):
        string = 'test' + str(i)
        tests_numbers.append(string)

    # Set new index array
    df_test_list.index = tests_numbers

    # Dataframe to store final results
    df_test_result = pandas.DataFrame(
            index=tests_numbers,
            columns=config.df_test_result_columns
        )

    # Dataframe to store response variables from test via command line
    df_mapred_commands = pandas.DataFrame(
            index=tests_numbers,
            columns=config.columns_mapred_commands
        )                   
    
    # Dataframe to store response variables from TestDFSIO logs 
    df_dfsio_logs = pandas.DataFrame(
            index=tests_numbers,
            columns=config.columns_dfsio_logs
        )                  

    # Return list of dataframes
    return df_test_list, df_test_result, df_mapred_commands, df_dfsio_logs

# Wrapper function
def initTest():
    # Create output directories
    os.makedirs(os.path.dirname(os.path.expanduser(config.path_test_dfsio_logs)), exist_ok=True)
    os.makedirs(os.path.dirname(os.path.expanduser(config.path_test_result))    , exist_ok=True)

    # Directly return tuple, for simplicity
    # NOTE: this is a bit messy
    return initTest_create_dataframe()


#####################
# 2. Config cluster #
#####################

# Update site xml files
def configCluster_update_xml(file_path, row, tuple_format):    
    # tree = xmlET.parse(file)                                            # Parse the XML file
    # root = tree.getroot()  

    # for property in root.findall('property'):                           # For each property under root                    
    #     name = property.find('name').text                               # Find the tags with the parameters configured for the pseudo-distributed mode 
    #     if name not in config.dont_touch_parameters:                    # Excluding config.dont_touch_parameters
    #         root.remove(property)                                       # Remove the previous tags

    # for t in tuple_format:
    #     try:
    #         property   = xmlET.Element('property')                       # Create property, name and value elements
    #         name       = xmlET.Element('name')
    #         value      = xmlET.Element('value')
    #         name.text  = t                                               # Set the new name
    #         value.text = str(row[t])                                     # Set the new value
    #         root.append(property)                                        # Add the new elements to the root element
    #         property.append(name)
    #         property.append(value)
    #     except:
    #         # Handle exception by skipping property
    #         print_warning("Column " + t + " not found in " + config.path_test_list + ". Skipping property setup")
    
    # xmlET.indent(tree, space='    ', level=0)                           # Indent the xml file
    #                                                                     # level = 0 means that you are starting the indentation from the root
    # tree.write(file, encoding="utf-8", xml_declaration=True)            # Write on xml file

    for t in tuple_format:
        value = str(row[t])
        update_cmd = (
                    '~/thesis/test/script/bash/update_site_xml.sh ' 
                    + file_path + ' ' + t + ' ' + value
                    )
        os.system(update_cmd)

# Update cluster configuration
def configCluster( row ):
    configCluster_update_xml( config.path_hdfs_site  , row, config.hdfs_t   )   # Configure hdfs-site.xml
    configCluster_update_xml( config.path_mapred_site, row, config.mapred_t )   # Configure mapred-site.xml
    #configCluster_update_xml( config.path_yarn_site  , row, config.yarn_t   )   # Configure yarn-site.xml


####################
# 3. Start cluster #
####################
def startCluster():
    os.system('./start_hadoop_cluster.sh')


##################
# 4. Online test #
##################

# Wrap os.system
def onlineTest_os_cmd(string):
    os.system(string)

# Start the online test
def onlineTest_run_test():
    print_warning("Online Test not Implemented yet")

# Use the REST API to measure the response variables
# def onlineTest_REST_get():
    # # TODO: if necessary, use config.yarn_resourcemanager_webapp_address
    # #   for YARN
    # response = requests.get( config.dfs_namenode_http_address +  + '/ws/v1/cluster/apps')
    # data = response.json()                                                  # data is a dictionary
    # print(data['apps']['app'][0]['allocatedMB'])                            # apps and app are keys, the app value is a list --> 0 to access the firts element
    # print(data['apps']['app'][0]['allocatedVCores'])


# Start TestDFSIO as online test
def onlineTest_TestDFSIO_run( row ):
    # Compose DFSIO command
    dfsio_cmd = (
                '$HADOOP_HOME/bin/hadoop jar ' + config.path_dfsio_jar + ' ' +
                'TestDFSIO -resFile ' + config.path_test_dfsio_logs + 
                ' -' + str(row['dfsio.operation']) + " > /dev/null"
                )
                
    # Adjust parameters format
    for t in config.dfsio_t:
        dfsio_cmd = dfsio_cmd + ' -' + t.split('.')[1] + ' ' + str(row[t])  

    print("dfsio_cmd: " + dfsio_cmd)

    # Start TestDFSIO
    dfsio_process = mp.Process(target = onlineTest_os_cmd, args=(dfsio_cmd,))
    dfsio_process.start()
    
    # Start Online Test
    online_test_process = mp.Process(target = onlineTest_run_test)
    online_test_process.start()                
    
    # REST API Test
    # TODO: implement
    # onlineTest_REST_get()
    
    # Wait for subprocesses to terminate                                                  
    online_test_process.join()
    dfsio_process.join()

# Start TeraSort as online test
# def onlineTest_TeraSort_run( row ):
#     # TODO: compose rerun_teragen condition
#     # 1. If exists output
#     # 2. If not terasort settings changed
    
#     if ( rerun_teragen == 1 ):
#         # Compose Teragen command
#         teragen_cmd = (
#                     '$HADOOP_HOME/bin/hadoop jar ' + config.path_tergen_jar + ' ' +
#                     'tergen' + str(row['teragen.operation']) + " > /dev/null"
#                     )
                    
#         # Adjust parameters format
#         for t in config.teragen_t:
#             teragen_cmd = teragen_cmd + ' -' + t.split('.')[1] + ' ' + str(row[t])  
    
#         print("teragen_cmd: " + teragen_cmd)
    
#         # Run TeraGen
#         os.system(teragen_cmd)
    
#     # Compose TeraSort command
#     teragen_cmd = (
#                 '$HADOOP_HOME/bin/hadoop jar ' + config.path_tergen_jar + ' ' +
#                 'terasort' + config.path_teragen_output + ' ' + config.path_terasort_output +
#                 ' > /dev/null"
#                 )
#     # Start TeraSort
#     teragen_process = mp.Process(target = onlineTest_os_cmd, args=(terasort_cmd,))
#     teragen_process.start()
    
#     # Start Online Test
#     online_test_process = mp.Process(target = onlineTest_run_test)
#     online_test_process.start()                
    
#     # Wait for subprocesses to terminate                                                  
#     online_test_process.join()
#     teragen_process.join() 

#     # Check with TeraValidate
#     if ( run_teravalidate == 1 ):
#         teravalidate_cmd = (
#                 '$HADOOP_HOME/bin/hadoop jar ' + config.path_tergen_jar + ' ' +
#                 'teravalidate' + config.path_terasort_output + ' ' + config.path_teravalidate_output +
#                 ' > /dev/null"
#         )        
#         os.system(teravalidate_cmd)

# Wrapper function for onlineTest_TestDFSIO_run
def onlineTest (row):
    # Start TestDFSIO
    onlineTest_TestDFSIO_run( row )
    # Start Terasort
    #onlineTest_Teragen_run ( row ) # TODO


###################
# 5. Offline-test #
###################

# Function to read response variables from mapreduce commands
def offlineTest_mapred_commands(index, df_mapred_commands):
    
    # Find jobID
    job_id_cmd = '$HADOOP_HOME/bin/mapred job -list all | grep "job_"'
    job_id_sub = subprocess.run(job_id_cmd, shell = True ,capture_output=True)
    job_id = job_id_sub.stdout.decode().split('\t')[0]
    print("job_id:" + job_id)

    # Number of map tasks
    map_number_cmd = '$HADOOP_HOME/bin/mapred job -status ' + job_id + ' | grep "Number of maps"'
    map_number_sub = subprocess.run(map_number_cmd, shell = True ,capture_output=True)
    print("map_number_sub:" + str(map_number_sub))
    map_number = int(map_number_sub.stdout.decode().split(':')[1])

    # CPU time spent by MapReduce Framework, map tasks and reduce tasks
    cpu_time_cmd = '$HADOOP_HOME/bin/mapred job -history ' + job_id + ' | grep "CPU time spent"'
    cpu_time_sub = subprocess.run(cpu_time_cmd,shell = True ,capture_output=True)
    cpu_time_map = int(cpu_time_sub.stdout.decode().replace(',','').split('|')[3])
    cpu_time_red = int(cpu_time_sub.stdout.decode().replace(',','').split('|')[4])
    cpu_time_tot = int(cpu_time_sub.stdout.decode().replace(',','').split('|')[5])

    # Save on the dataframe row the reponse variables
    # TODO: Assignment style requires much attention to ordering in the rigth-hand expression.
    #       Using dictionary-based syntax, matching config.columns_mapred_commands would prevent potential errors
    df_mapred_commands.loc[df_mapred_commands.index[index], config.columns_mapred_commands] = [map_number,cpu_time_map,cpu_time_red,cpu_time_tot]


# Function to read response variables from TestDFSIO log file
def offlineTest_TestDFSIO_logs(index, df_dfsio_logs):

    with open(config.path_test_dfsio_logs, 'r') as file:
        lines = file.readlines()                                                            # Lines list
    
    throughput = float(lines[4].split(':')[1].strip())                                      # Strip remove any leading, and trailing whitespaces
    average_io = float(lines[5].split(':')[1].strip())

    # Save on the dataframe row the reponse variables
    df_dfsio_logs.loc[df_dfsio_logs.index[index], config.columns_dfsio_logs] = [throughput, average_io]


# Function to start the Offline Test
def offlineTest(index, df_mapred_commands,  df_dfsio_logs):

    # Read the response variables from the mapreduce commands
    offlineTest_mapred_commands(index, df_mapred_commands)

    # Read the response variables from the TestDFSIO logs
    offlineTest_TestDFSIO_logs(index, df_dfsio_logs)


###############
# 6. Clean up #
###############

# Function to clean up the TestDFSIO log file
def cleanUp(path_test_dfsio_logs):
    # Compose DFSIO command
    dfsio_clean_cmd = (
                '$HADOOP_HOME/bin/hadoop jar ' + config.path_dfsio_jar + ' ' +
                'TestDFSIO -resFile ' + config.path_test_dfsio_logs + 
                ' -clean'
                )
    os.system(dfsio_clean_cmd)
    os.remove(path_test_dfsio_logs)


###################
# 7. Save results #
###################

# Function to save the response variables in test_result.csv
def saveResults(path_test_result, df_test_result, df_mapred_commands, df_dfsio_logs):
    # Concatenate pandas objects along a particular axis
    df_test_result = pandas.concat([df_mapred_commands, df_dfsio_logs], axis=1)    
    # Write to csv 
    df_test_result.to_csv(path_test_result,index= False)
    # Plot the results
