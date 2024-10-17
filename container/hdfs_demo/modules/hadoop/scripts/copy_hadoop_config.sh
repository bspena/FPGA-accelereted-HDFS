echo "[COPY CONFIG] Copy hadoop configuration into master"
cp -r ${HADOOP_ROOT}/assets/sites/* ${HADOOP_HOME}/etc/hadoop/


#echo "[INFO] Copy hadoop configuration into slave containers"
# cat  ~/hadoop_config/workers | xargs -I {} bash -c '
#     ssh $(whoami)@"{}" "cp  ~/hadoop_config/* $HADOOP_HOME/etc/hadoop/"
# '

for ip in "${slaves_ip_list[@]}"; do
    echo "[COPY CONFIG] Copy Hadoop configuration in $ip"
    ${SSH_CMD} ${HADOOP_USER}@$ip cp  -r ${HADOOP_ROOT}/assets/sites/* $HADOOP_HOME/etc/hadoop/
done