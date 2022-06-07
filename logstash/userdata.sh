#!/bin/bash -eu

cp /tmp/logstash.yml /etc/logstash/logstash.yml
cp /tmp/logstash-swift.conf /etc/logstash/conf.d/logstash-swift.conf

systemctl start logstash

$wc_notify --silent --data-binary '{"status": "SUCCESS"}'
echo "*** build done"
