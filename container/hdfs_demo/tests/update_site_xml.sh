# Description: Add properties to xml site files to configure hadoop
# Arguments:
#   None

# Remove proerpty tag with id=0
sed '/<property id="0">/,/<\/property>/d' $1 > temp.xml
mv temp.xml $1

# Find line with configuration tag and print the new property
awk -v name="$2" -v value="$3" '
  /<\/configuration>/{print "\
  <property id=\"0\">\n\
    <name>" name "</name>\n\
    <value>" value "</value>\n\
  </property>\
"}1' $1 > temp.xml

mv temp.xml $1