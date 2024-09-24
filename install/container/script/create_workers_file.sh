
# Create workers file
#touch  ~/thesis/install/container/hadoop_config/workers
>  ~/thesis/install/container/hadoop_config/workers

# Add slave containers name to workers file
slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")
for s in $slaves; do
    echo $s >>  ~/thesis/install/container/hadoop_config/workers
done