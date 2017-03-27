#!/bin/bash

#####################################################################################
# nwf application init script
# author: elvin
# date: 2017-2-27
# desc: this script will initialize nwf application automatically
#####################################################################################


if [ $# -ne 1 ] ; then
	echo "USAGE: sh $0 'project-name'"
	exit 1;
fi
pn=$1

cd $(cd $(dirname $0) && pwd -P)
if [ ! -d "$pn" ]; then
        mkdir "$pn"
fi
cd $pn
if [ -f "init_flag" ]; then
	cat init_flag
	exit 1
fi

echo start initialize NPL Web application...
echo project name: $pn

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
if [ ! -f "module_source_repos.conf" ]; then
	echo '#nwfModules git@git.idreamtech.com.cn:rddept/nwfModules.git' > module_source_repos.conf
fi
if [ ! -d "www/modules" ]; then
	mkdir www/modules
fi
cp -r npl_packages/nwf/resources/demo/* www/

echo "do not run init script again! project already initialized at: $(date '+%F %T')" > init_flag

echo NPL Web application initialization done.
