#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
sh ./update_project.sh

start start_win.bat