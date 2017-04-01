#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
cd npl_packages/main
git pull
cd ../nwf/
updatedFlag=$(git pull | grep "Already up-to-date." | wc -l)
cd ../../


bash npl_packages/nwf/resources/scripts/_update_project.sh