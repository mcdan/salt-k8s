#!/bin/bash
while true
do
rsync -avz --delete --exclude '.git' --exclude 'certs' . coldplay.corp.adobe.com:~/cluster/salt-base
sleep 2
done

