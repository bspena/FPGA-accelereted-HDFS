echo "[INFO] Copy hadoop archive into container/dcoker directory"
cp  ~/hadoop/hadoop-dist/target/hadoop-*.tar.gz  ~/thesis/install/container/docker

echo "[INFO] Build docker image with hadoop"
docker build \
    --build-arg USER_NAME="${USER}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t hadoop-image \
     ~/thesis/install/container/docker/

# Crete docker containers
source ./script/create_docker_container.sh