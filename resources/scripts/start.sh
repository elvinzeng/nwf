#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)

if [ -e 'server.pid' ]; then
    flag=$(ps -ef | grep $(cat server.pid) | wc -l)
else
    flag=0
fi

if [ $flag -gt 1 ]; then
	echo server already running, operation cancelled.
	exit;
fi

echo "current dir: $(pwd)"
npl -d bootstrapper="www/webapp.lua"