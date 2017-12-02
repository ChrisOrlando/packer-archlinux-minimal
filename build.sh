#!/bin/bash

mirror_url='http://mirror.rackspace.com/archlinux/iso/latest/'

md5sums=$(curl --silent "${mirror_url}md5sums.txt")
iso_md5=$(echo $md5sums | head -n1 | awk '{print $1}')
iso_name=$(echo $md5sums | head -n1 | awk '{print $2}')
iso_url="${mirror_url}${iso_name}"

cp archlinux.json archlinux-tmp.json
sed -i "s#{{iso_url}}#${iso_url}#" archlinux-tmp.json
sed -i "s#{{iso_md5}}#${iso_md5}#" archlinux-tmp.json

packer build archlinux-tmp.json

rm archlinux-tmp.json

