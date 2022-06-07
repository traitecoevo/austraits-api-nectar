#!/bin/bash -eu

apt_opts="-qq"

export DEBIAN_FRONTEND=noninteractive
echo "debconf debconf/frontend select Noninteractive" | sudo debconf-set-selections

apt-get update $apt_opts
apt-get install $apt_opts apt-utils software-properties-common
apt-get remove $apt_opts unattended-upgrades

curl --silent https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
add-apt-repository "deb https://artifacts.elastic.co/packages/8.x/apt stable main"
apt-get update $apt_opts

apt-get install $apt_opts logstash

/usr/share/logstash/bin/logstash-plugin install logstash-output-swift
(cd / && patch -p0 -i /tmp/logstash.patch)

cp /tmp/logstash.yml /etc/logstash/logstash.yml
cp /tmp/logstash-swift.conf /etc/logstash/conf.d/logstash-swift.conf

systemctl start logstash

$wc_notify --silent --data-binary '{"status": "SUCCESS"}'
echo "*** build done"
