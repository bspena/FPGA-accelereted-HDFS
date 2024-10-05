import sys
import hdfs_test_config as config                # HDFS test configuration file
import hdfs_test_utils as utils                  # Utility functions

if __name__=='__main__':
    print("[STEP 0]: Check enviroment and user configuration")
    # Check Python version
    assert sys.version_info >= (3, 10), "Must use Python 3.10 or newer"

    # Check test_list configuration
    utils.assert_config()
    utils.dump_config
    
    # Read parameters from config file
    print("[STEP 1] Initialize test")
    df_test_list, df_test_result, df_mapred_commands, df_dfsio_logs = utils.initTest()

    # riga = df_test_list.columns.tolist()
    # riga1= tuple(df_test_list.columns)[0,1]
    # print(riga1)
    #print(riga1[0])

    # For each row in df_test_list
    for i,row in df_test_list.iterrows():
        # test_index to increase the dataframe rows of the test via command line
        test_index = int(i.split('test')[1]) - 1    
        print("##########################")             
        print("[INFO] Running test n. " + i.split('test')[1] + "/" + str(df_test_list.shape[0]) )
        print("##########################")

        # # Configure cluster
        # print("[STEP 2] Cluster Configuration")
        # utils.configCluster( row )
        
        # #Start cluster
        # print("[STEP 3] Start the cluster")
        # utils.startCluster()

        # # Start on-line tests
        # print("[STEP 4] Start Online Test")
        # utils.onlineTest( row )

        # # Start off-line tests
        # print("[STEP 5] Start the Offline Test")
        # utils.offlineTest(
        #     test_index,
        #     df_mapred_commands,
        #     df_dfsio_logs,
        #     )

        # # Clean-up
        # print("[STEP 6] Clean up")
        # utils.cleanUp(
        #         config.path_test_dfsio_logs
        #     )

        # # Write out
        # print("[STEP 7] Save response variables on" + config.path_test_result)
        # utils.saveResults(
        #         config.path_test_result,
        #         df_test_result,
        #         df_mapred_commands,
        #         df_dfsio_logs
        #     )