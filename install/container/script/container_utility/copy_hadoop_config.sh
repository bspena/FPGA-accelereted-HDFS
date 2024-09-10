echo " [INFO] Copy hadoop configuration into master"
cp /home/$(whoami)/hadoop_config/* $HADOOP_HOME/etc/hadoop/


echo " [INFO] Copy hadoop configuration into slave containers"
cat /home/$(whoami)/hadoop_config/workers | xargs -I {} bash -c '
    ssh $(whoami)@"{}" "cp /home/$(whoami)/hadoop_config/* $HADOOP_HOME/etc/hadoop/"
'