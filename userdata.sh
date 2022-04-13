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
    upstream austraits-api {
        server localhost:8000;
    }

    limit_req_zone \$binary_remote_addr zone=limit:10m rate=10r/s;

    server {
        listen 80;

        location / {
            proxy_pass http://austraits-api;
            proxy_set_header X-Real-IP \$remote_addr;

            limit_req zone=limit burst=20 nodelay;
            limit_req_status 429;
        }

        location /health-check {
            proxy_pass http://austraits-api/health-check;
            access_log off;
        }

        location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2)$ {
            proxy_pass http://austraits-api;
            access_log off;

            add_header Cache-Control "max-age=1382400";
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
