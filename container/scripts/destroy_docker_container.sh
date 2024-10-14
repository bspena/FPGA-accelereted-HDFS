docker stop $(docker ps -a -q)
echo Y | docker system prune
docker ps -a