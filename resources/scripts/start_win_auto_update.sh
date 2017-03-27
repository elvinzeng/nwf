#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
sh ./update_packages.sh

start start_win.bat