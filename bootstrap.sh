#!/bin/sh

# set elasticsearch cluster name:
ES_CLUSTER_NAME="myescluster"

# create backup directory for elasticsearch config
mkdir /opt/backups/elasticsearch -p
yum update -y
# install some requisites
yum install -y java-1.8.0-openjdk.x86_64 wget jq

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.9.2-x86_64.rpm

# create elasticsearch repository
# cat > /etc/yum.repos.d/es.repo << EOF
# [elasticsearch-7.x]
# name=Elasticsearch repository for 7.x packages
# baseurl=https://artifacts.elastic.co/packages/7.x/yum
# gpgcheck=1
# gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
# enabled=0
# autorefresh=1
# type=rpm-md
# EOF

rpm -ivh elasticsearch-7.9.2-x86_64.rpm

rm -f elasticsearch-7.9.2-x86_64.rpm
systemctl daemon-reload
systemctl enable elasticsearch.service
service elasticsearch start

# stop elasticsearch and backup config
systemctl stop elasticsearch
mv /etc/elasticsearch/elasticsearch.yml /opt/backups/elasticsearch/elasticsearch.yml.BAK

# bootstrap elasticsearch config with defined values
cat > /etc/elasticsearch/elasticsearch.yml << EOF
cluster.name: $ES_CLUSTER_NAME
node.name: ${HOSTNAME}
node.roles: [master, data, ingest]
# To add connection for external hosts...
network.host: 0.0.0.0
discovery.seed_hosts : ["localhost", "127.0.0.1"]
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /var/lib/elasticsearch
#
# Path to log files:
#
path.logs: /var/log/elasticsearch
EOF

# # start elasticsearch
systemctl enable elasticsearch
systemctl restart elasticsearch

