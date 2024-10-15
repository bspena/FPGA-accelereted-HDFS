docker stop $(docker ps -a -q)
echo Y | docker system prune > /dev/null
docker ps -a

sudo rm -rf ${CONTAINER_ROOT}/docker_volumes