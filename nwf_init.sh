#!/bin/bash

#####################################################################################
# nwf application init script
# author: elvin
# date: 2017-2-27
# desc: this script will initialize nwf application automatically
#####################################################################################

echo start initialize nwf application...

if [ $# -ne 1 ] ; then
	echo "USAGE: sh $0 'project-name'"
	exit 1;
fi 
pn=$1
echo project name: $pn
cd $(cd $(dirname $0) && pwd -P)
if [ ! -d "$pn" ]; then
        mkdir "$pn"
fi
cd $pn

if [ ! -d ".git" ]; then
	git init 
fi
if [ ! -d "npl_packages" ]; then
	mkdir "npl_packages"
fi
if [ ! -f "npl_packages/main/README.md" ]; then
	git submodule add https://github.com/NPLPackages/main npl_packages/main
fi
if [ ! -f "npl_packages/nwf/README.md" ]; then
	git submodule add https://github.com/elvinzeng/nwf.git npl_packages/nwf
fi
cd npl_packages/main && git pull
cd ../nwf && git pull
cd ../../

cp npl_packages/nwf/resources/config/gitignore .gitignore
cp npl_packages/nwf/resources/scripts/* .

if [ ! -d "www" ]; then
	mkdir "www"
fi

cp npl_packages/nwf/resources/lua/* www/
cp npl_packages/nwf/resources/config/webserver.config.xml www/ 
cp -r npl_packages/nwf/resources/demo/* www/

echo nwf application initialization done.
