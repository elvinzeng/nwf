#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
sh ./update_packages.sh

if [ -f "www.tar.gz" ]; then
	echo "source package 'www.tar.gz' exits, directory www will be replace.."
	rm -rf www
	tar -xf www.tar.gz
fi

pwd
npl -d bootstrapper="www/webapp.lua"

