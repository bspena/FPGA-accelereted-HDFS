
import xml.etree.ElementTree as ET                        # Module for parsing and creating XML data
import linecache                                          # Module to extract and access specific lines in python
import subprocess                                         # Module to spawn new processes and capture stout/stderr
import os
import requests                                           # Module to execute http requests
import csv
import pandas
import multiprocessing as mp                              # Module to spaw new processes
import config_file as conf   


############################# STEP 1 FUNCTIONS ######################################

# Function to create one dataframe from test_list.csv and one needed for test_result.csv
def create_dataframe(path_test_list):

    # Read test_list.csv
    df_test_list = pandas.read_csv(path_test_list)                 

    # Create custom indeces
    tests_number = []
    for i in range(1,len(df_test_list.index)+1):
        string = 'test' + str(i)
        tests_number.append(string)

    df_test_list.index = tests_number

    # Create dataframe for test_result.csv
    df_test_result = pandas.DataFrame()                     
    df_test_result.index = tests_number

    # Dataframe to store response variables from test via command line
    df_mapred_commands = pandas.DataFrame()                   
    df_mapred_commands.index = tests_number
    
    # Dataframe to store response variables from TestDFSIO logs 
    df_dfsio_logs = pandas.DataFrame()                  
    df_dfsio_logs.index = tests_number

    return df_test_list,df_test_result,df_mapred_commands,df_dfsio_logs



############################# STEP 2 FUNCTIONS ######################################
        
# Function to update the xml file
def update_xml(file,row,tuple,special_parameters):    
    tree = ET.parse(file)                                               # Parse the XML file
    root = tree.getroot()  

    for property in root.findall('property'):                           # Remove the previous tags
        name = property.find('name').text                               # Find the tags with the parameters configured for the pseudo-distributed mode 
        if name not in special_parameters:    
            root.remove(property)

    for t in tuple:
        property = ET.Element('property')                               # Create property,name and value elements
        name = ET.Element('name')
        value = ET.Element('value')
        name.text = t                                                   # Set the new tags
        value.text = str(row[t])
        root.append(property)                                           # Add the new elements to the root element
        property.append(name)
        property.append(value)
                                
    ET.indent(tree, space='  ', level=0)                                # Indent the xml file
                                                                        # level = 0 means that you are starting the indentation from the root
    tree.write(file, encoding="utf-8", xml_declaration=True)            # Write on xml file


# Function for the cluster configuration
def config_cluster(path_hdfs_site,hdfs_t,path_mapred_site,mapred_t,path_yarn_site,yarn_t,row,special_parameters):
    update_xml(path_hdfs_site,row,hdfs_t,special_parameters)            # Configure hdfs-site.xml
    update_xml(path_mapred_site,row,mapred_t,special_parameters)        # Configure mapred-site.xml
    #update_xml(path_yarn_site,row,yarn_t,special_parameters)           # Configure yarn-site.xml



############################# STEP 4 FUNCTIONS ######################################

# Function to start the dfsio test
def start_dfsio(string):
    os.system(string)

# Function to start the online test
def online_test():
    print("Online Test not Implemented yet")

# Function to use the REST API to measure the response variables
def rest_api():
    response = requests.get('http://localhost:8088/ws/v1/cluster/apps')
    data = response.json()                                                  # data is a dictionary
    print(data['apps']['app'][0]['allocatedMB'])                            # apps and app are keys, the app value is a list --> 0 to access the firts element
    print(data['apps']['app'][0]['allocatedVCores'])


# Function to start TestDFSIO and the Online Test
def dfsio_online_test(row,dfsio_t):
    s = '$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.5-tests.jar TestDFSIO -' + str(row['dfsio.operation'])
    for t in dfsio_t:
        s = s + ' -' + t.split('.')[1] + ' ' + str(row[t])  

    # Start TestDFSIO
    dfsio_process = mp.Process(target = start_dfsio, args=(s,))             # Create new process
    dfsio_process.start()                                                   # Start the process
    
    # Start Online Test
    online_test_process = mp.Process(target = online_test)
    online_test_process.start()                
    
    # Methods block until processes are terminated                                                   
    online_test_process.join()
    dfsio_process.join() 

    # REST API Test
    #rest_api()



############################# STEP 5 FUNCTIONS ######################################

# Function to measure response variables from mapreduce commands
def mapred_commands(index,df_mapred_commands,cn_mapred_commands):
    
    # Find jobID
    job_id_sub = subprocess.run('$HADOOP_HOME/bin/mapred job -list all | grep "job_"',shell = True ,capture_output=True)
    job_id = job_id_sub.stdout.decode().split('\t')[0]

    # Number of map tasks
    map_number_sub = subprocess.run('$HADOOP_HOME/bin/mapred job -status ' + job_id + ' | grep "Number of maps"',shell = True ,capture_output=True)
    map_number = int(map_number_sub.stdout.decode().split(':')[1])

    # CPU time spent by MapReduce Framework, map tasks and reduce tasks
    cpu_time_sub = subprocess.run('$HADOOP_HOME/bin/mapred job -history ' + job_id + ' | grep "CPU time spent"',shell = True ,capture_output=True)
    cpu_time_map = int(cpu_time_sub.stdout.decode().replace(',','').split('|')[3])
    cpu_time_red = int(cpu_time_sub.stdout.decode().replace(',','').split('|')[4])
    cpu_time_tot = int(cpu_time_sub.stdout.decode().replace(',','').split('|')[5])

    # Save on the dataframe row the reponse variables
    df_mapred_commands.loc[df_mapred_commands.index[index], cn_mapred_commands] = [map_number,cpu_time_map,cpu_time_red,cpu_time_tot]


# Function to measure response variables from TestDFSIO log file
def test_dfsio_logs(index,path_test_dfsio_logs,df_dfsio_logs,cn_dfsio_logs):

    with open(path_test_dfsio_logs, 'r') as file:
        lines = file.readlines()                                                            # Lines list
    
    throughput = float(lines[4].split(':')[1].strip())                                      # Strip remove any leading, and trailing whitespaces
    average_io = float(lines[5].split(':')[1].strip())

    # Save on the dataframe row the reponse variables
    df_dfsio_logs.loc[df_dfsio_logs.index[index], cn_dfsio_logs] = [throughput,average_io]


# Function to start the Offline Test
def offline_test(index,df_mapred_commands,cn_mapred_commands,path_test_dfsio_logs,df_dfsio_logs,cn_dfsio_logs):

    # Read the response variables from the mapreduce commands
    mapred_commands(index,df_mapred_commands,cn_mapred_commands)

    # Read the response variables from the TestDFSIO logs
    test_dfsio_logs(index,path_test_dfsio_logs,df_dfsio_logs,cn_dfsio_logs)


############################# STEP 6 FUNCTION ######################################

# Function to clean up the TestDFSIO log file
def clean_up(path_test_dfsio_logs):
    os.system('$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.3.5-tests.jar TestDFSIO -clean')
    os.remove(path_test_dfsio_logs)



############################# STEP 7 FUNCTION ######################################

# Function to save the response variables in test_result.csv
def save_rv(path_test_result,df_test_result,df_mapred_commands,df_dfsio_logs):
    df_test_result = pandas.concat([df_mapred_commands, df_dfsio_logs], axis=1)     # Concatenate pandas objects along a particular axis
    df_test_result.to_csv(path_test_result,index= False)