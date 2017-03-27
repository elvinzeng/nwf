#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
cd npl_packages/main
git pull
cd ../nwf/
git pull
cd ../../


bash npl_packages/nwf/resources/scripts/_update_project.sh