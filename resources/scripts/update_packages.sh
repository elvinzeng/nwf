#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
cd npl_packages/main
git pull
cd ../nwf/
git pull
cd ../../