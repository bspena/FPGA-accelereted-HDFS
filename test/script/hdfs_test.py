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

    # For each row in df_test_list
    for i,row in df_test_list.iterrows():
        # test_index to increase the dataframe rows of the test via command line
        test_index = int(i.split('test')[1]) - 1    
        print("##########################")             
        print("[INFO] Running test n. " + i.split('test')[1] + "/" + str(df_test_list.shape[0]) )
        print("##########################")

        # Stop hadoop daemons
        print("[STEP 2] Stop hadoop daemons")
        utils.stopDaemons()

        # Configure cluster
        print("[STEP 3] Cluster Configuration")
        utils.configCluster( row )
        
        # Start hadoop daemons
        print("[STEP 4] hadoop daemons")
        utils.startDaemons()

        # Start on-line tests
        print("[STEP 5] Start Online Test")
        utils.onlineTest( row )

        # Start off-line tests
        print("[STEP 6] Start the Offline Test")
        utils.offlineTest(
            test_index,
            df_mapred_commands,
            df_dfsio_logs,
            )

        # Clean-up
        print("[STEP 7] Clean up")
        # utils.cleanUp(
        #         config.path_test_dfsio_logs
        #     )

        # Write out
        print("[STEP 8] Save response variables on" + config.path_test_result)
        utils.saveResults(
                config.path_test_result,
                df_test_result,
                df_mapred_commands,
                df_dfsio_logs
            )