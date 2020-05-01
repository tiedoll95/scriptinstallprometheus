#!/bin/bash
yum install wget -y
##remove user and prometheus_old
systemctl stop firewalld
systemctl disable firewalld
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
userdel prometheus
rm -rf /home/prometheus/

### tao user prometheus 

useradd -m -s /bin/bash prometheus

sleep 1

cd /home/prometheus/
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz

tar -xzvf node_exporter-0.18.1.linux-amd64.tar.gz

mv node_exporter-0.18.1.linux-amd64 node_exporter

cd /etc/systemd/system/

cat << EOF > node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/home/prometheus/node_exporter/node_exporter

[Install]
WantedBy=default.target

EOF

chown prometheus /home/prometheus/node_exporter
systemctl daemon-reload
systemctl restart node_exporter
systemctl enable node_exporter
