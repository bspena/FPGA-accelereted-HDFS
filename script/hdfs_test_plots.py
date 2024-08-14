import os
import pandas
import numpy as np
from matplotlib import pyplot as plt
import oneapi_test_config as config

# Find measurements of central tendency
def find_measurements_ct(df, df_column, n):
    
    # Array whit median or mean values
    list = []

    # Split dataframe into n array 
    split_df = np.split(df, n)
    
    # Find the median or the mean for the specificated dataframe column
    for s in split_df:
        list.append(np.median(s[df_column]))
        #list.append(np.mean(s[df_column]))

    return list


# Plot the values
def line_plot(ax, x, y, x_label, y_label, color ,legend_label):  

    # Set the logarithmic scale 
    ax.set_xscale("log", base=2); 
    ax.set_yscale("log", base=10); 

    # Set custom valuse for x axis
    ax.set_xticks(config.x_values, labels= config.x_custom_values)
    
    # Set labels and grid
    ax.set_xlabel(x_label)                 
    ax.set_ylabel(y_label)
    ax.grid(linestyle='--', color='0.85')     

    # Plot the result                                             
    ax.plot(x, y, marker='o', markerfacecolor ='black', markersize='6', color=color, label = legend_label)


# Plot all values in one figure
def plots(latency_pipes, latency_memch,throughput_pipes, throughput_memch):

    # Define the figure
    fig, ax = plt.subplots(1,2,figsize=(16,8))    
    ax[0].set_title(config.latency_plot_title, size = 20) 
    ax[1].set_title(config.throughputs_plot_title, size = 20)

    # Plot latency values
    line_plot(ax[0], config.x_values, latency_pipes, '', '', 'red', config.legend_label_pipes)
    line_plot(ax[0], config.x_values, latency_memch, config.x_label, config.y_label_latency, 'green', config.legend_label_memch)

    # Plot throughput values
    line_plot(ax[1], config.x_values, throughput_pipes, '', '', 'red', config.legend_label_pipes)
    line_plot(ax[1], config.x_values, throughput_memch, config.x_label, config.y_label_throughput, 'green', config.legend_label_memch)

    # Show the legend
    ax[0].legend()
    ax[1].legend()

    # Autoformat data lables
    fig.autofmt_xdate()

    # Save plot as image
    fig.savefig('latencies_throughputs_plot.png')


if __name__=='__main__':

    # Define samples csv files paths
    pipes_path =        os.getcwd() + '/' + config.sample_names[0] + '_test_result.csv'
    memchannel_path =   os.getcwd() + '/' + config.sample_names[1] + '_test_result.csv'

    # Read results from samples csv files
    pipes_df = pandas.read_csv(pipes_path)
    memchannel_df = pandas.read_csv(memchannel_path)

    # Sort the dataframes on array_size
    pipes_df =      pipes_df.sort_values(by=['array_size'])
    memchannel_df = memchannel_df.sort_values(by=['array_size'])

    # Generate latencies median or mean values
    latency_pipes = find_measurements_ct(pipes_df,      config.test_result_columns[1], config.number_levels)
    latency_memch = find_measurements_ct(memchannel_df, config.test_result_columns[1], config.number_levels)

    # Generate throughputs median or mean values
    throughput_pipes = find_measurements_ct(pipes_df,      config.test_result_columns[2], config.number_levels)
    throughput_memch = find_measurements_ct(memchannel_df, config.test_result_columns[2], config.number_levels)

    # Plot all values in one figure
    plots(latency_pipes, latency_memch,throughput_pipes, throughput_memch)

    # Show plot
    #plt.show()