# Description: Add properties to xml site files to configure hadoop
# Arguments:
#   $1: xml site file path
#   $2: Property to update
#   $3: Value

PATH=$1
PROPERTY=$2
VALUE=$3

# Remove proerpty tag with id=0
sed '/<property id="0">/,/<\/property>/d' $PATH > temp.xml
mv temp.xml $PATH

# Find line with configuration tag and print the new property
awk -v name="$PROPERTY" -v value="$VALUE" '
  /<\/configuration>/{print "\
  <property id=\"0\">\n\
    <name>" name "</name>\n\
    <value>" value "</value>\n\
  </property>\
"}1' $PATH > temp.xml

mv temp.xml $PATH