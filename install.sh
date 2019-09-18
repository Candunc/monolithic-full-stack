#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

hide_submodule() {
	mv ./cache-domains/.git ./cache-domains/.git.bak
	mkdir ./cache-domains/.git
}

show_submodule() {
	rmdir ./cache-domains/.git
	mv ./cache-domains/.git.bak ./cache-domains/.git
}

git submodule update --init

# Remove old config files (if they exist)
rm -r /etc/nginx /etc/bind

## BEGIN lancache-dns

cp -a ./lancache-dns/overlay/etc/bind /etc/
cp ./lancache-dns/overlay/hooks/entrypoint-pre.d/10_generate_config.sh ./
sed -i -e 's:/opt/:./:' ./10_generate_config.sh

# Bypass a check in 10_generate_config
hide_submodule

LANCACHE_IP="10.0.1.1"
NOFETCH="true"
USE_GENERIC_CACHE="true"
. ./10_generate_config.sh

rm ./10_generate_config.sh

## BEGIN generic

cp -a ./generic/etc/nginx /etc/

WEBUSER=www-data
CACHE_MEM_SIZE=500m
CACHE_DISK_SIZE=500000m
CACHE_MAX_AGE=3560d
UPSTREAM_DNS="8.8.8.8 8.8.4.4"
BEAT_TIME=1h
LOGFILE_RETENTION=3560
NGINX_WORKER_PROCESSES=16

. ./generic/overlay/hooks/entrypoint-pre.d/10_setup.sh

ln -s /etc/nginx/sites-available/10_generic.conf /etc/nginx/sites-enabled/10_generic.conf

## BEGIN monolithic

cp -a ./monolithic/etc/nginx /etc/

cp ./monolithic/overlay/hooks/entrypoint-pre.d/15_generate_maps.sh ./
sed -i -e 's:/data/cachedomains:./cache-domains:' ./15_generate_maps.sh

. ./15_generate_maps.sh

# Return to our initial state
show_submodule
