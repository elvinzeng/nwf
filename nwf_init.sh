#!/bin/bash

#####################################################################################
# nwf application init script
# author: elvin
# date: 2017-2-27
# desc: this script will initialize nwf application automatically
#####################################################################################

echo updating init script...
echo detecting the current location...
country_flag=$(curl "http://ip.taobao.com/service/getIpInfo.php?ip=$(curl http://ipecho.net/plain)" | grep '"country_id":"CN"' | wc -l)
if [ $country_flag -ge 1 ]; then
    #echo "We have detected that you are currently in China, so we will use the mirror repository located in China."
    curl -o ._nwf_init.sh http://git.oschina.net/elvinzeng/nwf/raw/master/resources/scripts/_init.sh
else
    #echo "We have detected that you are not currently in China, so we will use github repository directly."
    curl -o ._nwf_init.sh https://raw.githubusercontent.com/elvinzeng/nwf/master/resources/scripts/_init.sh
fi

sh ._nwf_init.sh $*