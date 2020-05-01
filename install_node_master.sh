#!/bin/bash
yum install wget -y
##remove user and prometheus_old
systemctl stop firewalld
systemctl disable firewalld
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
rm -rf /home/prometheus/

### tao user prometheus 

useradd -m -s /bin/bash prometheus

sleep 1

cd /home/prometheus

wget https://github.com/prometheus/prometheus/releases/download/v2.17.2/prometheus-2.17.2.linux-amd64.tar.gz

tar -xzvf prometheus-2.17.2.linux-amd64.tar.gz

mv prometheus-2.17.2.linux-amd64/ prometheus/

cd /etc/systemd/system/

cat << EOF > prometheus.service 
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=prometheus
Restart=on-failure

#Change this line if you download the
#Prometheus on different path user
ExecStart=/home/prometheus/prometheus/prometheus \
  --config.file=/home/prometheus/prometheus/prometheus.yml \
  --storage.tsdb.path=/home/prometheus/prometheus/data

[Install]
WantedBy=multi-user.target

EOF

sleep 1

chown prometheus /home/prometheus/prometheus


systemctl daemon-reload


systemctl enable prometheus

cd /home/prometheus

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
systemctl restart prometheus
systemctl status prometheus

echo 'Dang add ip cac node_exporter tu file ip_node_exporter.cfg'

sleep 5

./add_ip_nodeexporter.sh

echo > 'OK'
