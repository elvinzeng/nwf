#!/bin/bash

#####################################################################################
# nwf application init script
# author: elvin
# date: 2017-2-27
# desc: this script will initialize nwf application automatically
#####################################################################################

echo updating init script...
curl -o ._nwf_init.sh https://raw.githubusercontent.com/elvinzeng/nwf/master/resources/scripts/_init.sh
sh ._nwf_init.sh $*