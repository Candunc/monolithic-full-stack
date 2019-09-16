#!/bin/bash

#mkdir /tmp/monolithic/

mkdir ./root
mkdir ./root/etc

cp -a ./lancache-dns/overlay/etc/bind ./root/etc

cp ./lancache-dns/overlay/hooks/entrypoint-pre.d/10_generate_config.sh ./
sed -i -e 's:/opt/:./:' ./10_generate_config.sh
sed -i -e 's:/etc/:./root/etc/:' ./10_generate_config.sh

# Bypass a check in 10_generate_config
mv ./cache-domains/.git ./cache-domains/.git.bak
mkdir ./cache-domains/.git

LANCACHE_IP="10.0.1.1"
NOFETCH="true"
USE_GENERIC_CACHE="true"
. ./10_generate_config.sh

rm ./10_generate_config.sh

rmdir ./cache-domains/.git
mv ./cache-domains/.git.bak ./cache-domains/.git
