echo "[INFO] Copy hadoop archive"
cp  ~/hadoop/hadoop-dist/target/hadoop-*.tar.gz  ${INSTALL_CONTAINER_DIR}/docker

echo "[INFO] Build docker image with hadoop"
docker build \
    --build-arg USER_NAME="${USER}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -t hadoop-image \
    ${INSTALL_CONTAINER_DIR}/docker/