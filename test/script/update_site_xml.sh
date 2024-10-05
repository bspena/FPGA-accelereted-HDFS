
# Remove proerpty tag with id=0
sed '/<property id="0">/,/<\/property>/d' hdfs-site.xml > temp.xml
mv temp.xml hdfs-site.xml

# Find line with configuration tag and print the new property
awk '/<\/configuration>/{print "\
  <property id=\"0\">\n\
    <name>dfs.blocksize</name>\n\
    <value>80</value>\n\
  </property>\
"}1' hdfs-site.xml > temp.xml

mv temp.xml hdfs-site.xml