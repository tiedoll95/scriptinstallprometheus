#!/bin/bash

cat /root/scriptinstallprometheus/ip_node_exporter.cfg | while read line
do
{
        {
cat << EOF >> /home/prometheus/prometheus/prometheus.yml
  - job_name: 'nodeexport_$line'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['$line:9100']

EOF
echo "da add xong $line vao file config"
}
}
done

