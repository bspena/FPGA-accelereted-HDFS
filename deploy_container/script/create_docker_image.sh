echo "[INFO] Copy hadoop archive"
cp  ~/hadoop/hadoop-dist/target/hadoop-*.tar.gz  ${DEPLOY_CONTAINER_ROOT}/docker

echo "[INFO] Build docker image with hadoop"
docker build \
    --build-arg USER_NAME="${USER}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t hadoop-image \
    ${DEPLOY_CONTAINER_ROOT}/docker/


source ${DEPLOY_CONTAINER_ROOT}/script/create_docker_container.sh