#!/bin/bash -eu

workdir=/opt

cd $workdir

cp /tmp/nginx.conf /etc/nginx/nginx.conf
systemctl restart nginx

curl --silent -L https://github.com/traitecoevo/austraits-api/archive/$branch.tar.gz | tar zxf -

cd austraits-api-$branch
sed -i 's/"traitecoevo\/austraits"/&, dependencies=FALSE, build_vignettes=FALSE/' "API.build/API examples v1.R"
sed -i 's/port=80/port=8000/' api_wrapper.R
Rscript api_wrapper.R &

while [ ! `curl --silent -I http://localhost:80/health-check | grep --count "200 OK"` -eq 1 ]; do
    echo "*** waiting for API ..."
    sleep 10
done

$wc_notify --silent --data-binary '{"status": "SUCCESS"}'
echo "*** build done"
