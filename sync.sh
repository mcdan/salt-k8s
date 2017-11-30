#!/bin/bash
while true
do
rsync -avz --delete --exclude '.git' --exclude 'file_root/certs' --exclude 'pillar_root/public-ip.sls' . coldplay.corp.adobe.com:~/cluster/salt-base
sleep 2
done

