#!/bin/bash
yum install wget -y
##remove user and prometheus_old
systemctl stop firewalld
systemctl disable firewalld
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

### tao user prometheus 

useradd -m -s /bin/bash prometheus

sleep 1

cd /home/prometheus/
wget https://github.com/prometheus/snmp_exporter/releases/download/v0.17.0/snmp_exporter-0.17.0.linux-amd64.tar.gz

tar -xzf snmp_exporter-0.17.0.linux-amd64.tar.gz


mv snmp_exporter-0.17.0.linux-amd64.tar.gz snmp_exporter

cd /etc/systemd/system/

cat << EOF > node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
ExecStart=/home/prometheus/node_exporter/node_exporter --config.file /home/prometheus/snmp_exporter/snmp.yml
[Install]
WantedBy=default.target
EOF

chown prometheus /home/prometheus/snmp_exporter
systemctl daemon-reload
systemctl restart snmp_exporter
systemctl enable snmp_exporter
