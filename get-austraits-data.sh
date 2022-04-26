#!/bin/bash

data_bucket=https://object-store.rc.nectar.org.au/v1/AUTH_74cb7e7fea1a4d7fa0d10aeb7988ce7a/austraits-data-releases
manifest_file=manifest.txt

curl --silent -o $manifest_file $data_bucket/$manifest_file

while read -r line
do
    array=($line)
    filename=${array[0]}
    md5=${array[1]}

    curl --silent -o $filename $data_bucket/$filename

    echo "$md5  $filename" | md5sum --status -c - \
        && echo "$filename verified okay" || (echo "$filename didn't verify okay; removing"; rm $filename)
done < $manifest_file
