#!/bin/bash -eu

workdir=/opt

echo "*** starting userdata.sh"

echo "*** copying config files"
# config file for webserver
cp /tmp/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx

# config file for logstash
cp /tmp/filebeat.yml /etc/filebeat/filebeat.yml
systemctl start filebeat

# Download api code
echo "*** downloading api code"
cd $workdir

# using curl as slightlightly quicker than git clone (no history)
curl --silent -L https://github.com/traitecoevo/austraits-api/archive/$api_branch.tar.gz | tar zxf -

# Download data needed for API and save in relevant subdirectory
echo "*** downloading data"
cd austraits-api-$api_branch/API.build
mkdir data
cd data

# data is stashed in a local container, to protect against slow zenodo downloads or downtime
data_bucket=https://object-store.rc.nectar.org.au/v1/AUTH_74cb7e7fea1a4d7fa0d10aeb7988ce7a/austraits-data-releases
# mainfest file lists all the files to download. So this can be updated in future
manifest_file=manifest.txt

curl --silent -o $manifest_file $data_bucket/$manifest_file

while read -r line
do
    array=($line)
    filename=${array[0]}
    md5=${array[1]}

    echo "....... downloading $filename"

    curl --silent -o $filename $data_bucket/$filename

    ## files verified via md5 hash, to ensure properly downloaded and indetical to known state
    echo "$md5  $filename" | md5sum --status -c - \
        && echo "$filename verified okay" || (echo "$filename didn't verify okay; removing"; rm $filename)
done < $manifest_file

# Retrun to base dir of api for launch
cd $workdir/austraits-api-$api_branch

# Start api n background
echo "*** starting API"

Rscript api_wrapper.R &

# Watch until health check succeeds
while [ ! `curl --silent -I http://localhost:80/health-check | grep --count "200 OK"` -eq 1 ]; do
    echo "*** waiting for API ..."
    sleep 10
done

# Notify of success
$wc_notify --silent --data-binary '{"status": "SUCCESS"}'
echo "*** build done"
