import config_file as conf                       # Variables module
import functions as func                         # Functions module
import os

if __name__=='__main__':

    print("STEP 1: Create dataframes")
    df_test_list,df_test_result,df_mapred_commands,df_dfsio_logs = func.create_dataframe(conf.path_test_list)           

    for i,row in df_test_list.iterrows():
        print("\n")

        index = int(i.split('test')[1]) - 1                 # Index to increase the dataframe rows of the test via command line 
        print("Test n. " + i.split('test')[1])
    
        print("STEP 2: Cluster Configuration \n")
        func.config_cluster(conf.path_hdfs_site,conf.hdfs_t,conf.path_mapred_site,conf.mapred_t,conf.path_yarn_site,conf.yarn_t,row,conf.special_parameters)
        
        print("STEP 3: Start the cluster in pseudo-distributed mode")
        os.system('./start_cluster.sh')
        print("\n")

        print("STEP 4: Start the TestDFSIO and Online Test")
        func.dfsio_online_test(row,conf.dfsio_t)
        print("\n")
                                
        print("STEP 5: Start the Offline Test")
        func.offline_test(index,df_mapred_commands,conf.cn_mapred_commands,conf.path_test_dfsio_logs,df_dfsio_logs,conf.cn_dfsio_logs)
        print("\n")

        print("STEP 6: Clean up TestDFSIO results")
        func.clean_up(conf.path_test_dfsio_logs)
        print("\n")     

    print("STEP 7: Save response variables on test_result.csv")
    func.save_rv(conf.path_test_result,df_test_result,df_mapred_commands,df_dfsio_logs)