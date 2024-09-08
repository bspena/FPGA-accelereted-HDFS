
# Create workers file
#touch /home/$(whoami)/thesis/install/container/hadoop_config/workers
> /home/$(whoami)/thesis/install/container/hadoop_config/workers

# Add slave containers name to workers file
slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")
for s in $slaves; do
    echo $s >> /home/$(whoami)/thesis/install/container/hadoop_config/workers
done