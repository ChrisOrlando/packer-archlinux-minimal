#!/bin/bash

mirror_url='http://mirror.rackspace.com/archlinux/iso/latest'

md5sums=$(curl --silent "${mirror_url}/md5sums.txt")
iso_md5=$(awk '/archlinux-x86_64.iso/ {print $1}' <<< "$md5sums")
iso_name=$(awk '/archlinux-x86_64.iso/ {print $2}' <<< "$md5sums")
iso_url="${mirror_url}/${iso_name}"

cp archlinux.json archlinux-tmp.json
sed -i "s#{{iso_url}}#${iso_url}#" archlinux-tmp.json
sed -i "s#{{iso_md5}}#${iso_md5}#" archlinux-tmp.json

packer build archlinux-tmp.json

rm archlinux-tmp.json
