#!/bin/bash -eu

workdir=/opt

cd $workdir

apt-get update -qq && apt-get install -qq --no-install-recommends nginx
cat <<EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes auto;

events {
    worker_connections 512;
}

http {
    limit_req_zone \$binary_remote_addr zone=limit:10m rate=10r/s;

    server {
        listen 80;

        location / {
            proxy_pass http://127.0.0.1:8000/;
            proxy_set_header X-Real-IP \$remote_addr;

            limit_req zone=limit burst=20 nodelay;
            limit_req_status 429;
        }
    }
}
EOF
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

$wc_notify --data-binary '{"status": "SUCCESS"}'
echo "*** build done"
