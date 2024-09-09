echo " [INFO] Copy hadoop configuration into master"
cp /home/$(whoami)/hadoop_config/* $HADOOP_HOME/etc/hadoop/


echo " [INFO] Copy hadoop configuration into slave containers"
for file in /home/$(whoami)/hadoop_config/*; do
    while read slave; do
        scp "$file" $(whoami)@"$slave":$HADOOP_HOME/etc/hadoop/
    done < /home/$(whoami)/hadoop_config/workers
done