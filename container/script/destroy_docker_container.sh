docker stop $(docker ps -a -q) > /dev/null
echo Y | docker system prune > /dev/null

# Check if eventually there are containers alive
docker ps -a