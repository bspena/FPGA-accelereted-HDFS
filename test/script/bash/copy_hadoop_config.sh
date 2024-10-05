echo " [INFO] Copy hadoop configuration into master"
cp ~/hadoop_config/* $HADOOP_HOME/etc/hadoop/


echo " [INFO] Copy hadoop configuration into slave containers"
cat  ~/hadoop_config/workers | xargs -I {} bash -c '
    ssh $(whoami)@"{}" "cp  ~/hadoop_config/* $HADOOP_HOME/etc/hadoop/"
'