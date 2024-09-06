
slaves=$(docker ps --filter "name=slave-" --format "{{.Names}}")

for file in /home/$(whoami)/thesis/install/container/hadoop_config/*; do

    if [ "$(basename "$file")" = "workers" ]; then
        docker cp "$file" master:/home/$(whoami)/hadoop-3.3.5/etc/hadoop/
    else

        for s in $slaves; do
            docker cp "$file" "$s"-0:/home/$(whoami)/hadoop-3.3.5/etc/hadoop/
        done
    fi
done
