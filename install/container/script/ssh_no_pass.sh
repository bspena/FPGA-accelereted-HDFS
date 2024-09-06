echo "[INFO] Start ssh service"
sudo service ssh start

echo "[INFO] Set PDSH_RCMD_TYPE environment variable"
echo 'export PDSH_RCMD_TYPE=ssh' >> ~/.bashrc
source ~/.bashrc

echo "[INFO] Generate public ssh key"
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

echo "[INFO] Copy public key"
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys