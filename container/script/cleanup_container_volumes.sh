# Description: Remove docker volumes directories
# Arguments:
#   None

sudo rm -r ${DOCKER_VOLUMES}/master

slaves=$(docker ps -a --filter "name=slave-" --format "{{.Names}}")
for s in $slaves; do
    rm -r ${DOCKER_VOLUMES}/$s
done
