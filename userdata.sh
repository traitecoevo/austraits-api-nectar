#!/bin/bash

# This is to get a newer version (4.x) of r-base than in Ubuntu repos
echo "deb https://cloud.r-project.org/bin/linux/ubuntu `lsb_release -cs`-cran40/" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9

# This is to get newer versions of r-cran-* packages than in Ubuntu repos
add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+

apt-get update
apt-get install -y r-base r-cran-plumber r-cran-remotes
apt-get install -y r-cran-refmanager r-cran-dplyr r-cran-tidyr r-cran-rlang \
    r-cran-purrr r-cran-tidyselect r-cran-assertthat r-cran-stringr \
    r-cran-jsonlite r-cran-httr r-cran-magrittr r-cran-readr

git clone https://github.com/traitecoevo/austraits-api -b $branch

cd austraits-api
sed -i 's/"traitecoevo\/austraits@api"/&, dependencies=FALSE, build_vignettes=FALSE/' API.build/API\ examples\ v1.R
Rscript api_wrapper.R &

sleep 60 && $wc_notify --data-binary '{"status": "SUCCESS"}'
echo "build done"
