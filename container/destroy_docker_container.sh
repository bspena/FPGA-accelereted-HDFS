docker stop $(docker ps -a -q)
echo Y | docker system prune > /dev/null
docker ps -a