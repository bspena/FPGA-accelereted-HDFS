echo "[INFO] Set PDSH_RCMD_TYPE environment variable"
echo 'export PDSH_RCMD_TYPE=ssh' >> ~/.bashrc
source ~/.bashrc

echo "[INFO] Generate public ssh key"
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

echo "[INFO] Copy public key"
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

echo "[INFO] Copy public key in slave containers"
cat ~/hadoop_config/workers | xargs -I {} bash -c '
    ssh $(whoami)@"{}" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    scp ~/.ssh/authorized_keys $(whoami)@"{}":~/.ssh/
    ssh $(whoami)@"{}" "chmod 600 ~/.ssh/authorized_keys"
'