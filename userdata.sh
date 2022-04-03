#!/bin/bash -eu

workdir=/opt

cd $workdir

curl --silent -L https://github.com/traitecoevo/austraits-api/archive/$branch.tar.gz | tar zxf -

cd austraits-api-$branch
sed -i 's/"traitecoevo\/austraits@api"/&, dependencies=FALSE, build_vignettes=FALSE/' "API.build/API examples v1.R"
Rscript api_wrapper.R &

while [ ! `curl --silent -I http://localhost:80/health-check | grep --count "200 OK"` -eq 1 ]; do
    echo "*** waiting for API ..."
    sleep 10
done

$wc_notify --data-binary '{"status": "SUCCESS"}'
echo "*** build done"
