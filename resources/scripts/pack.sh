#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
if [ -f "www.tar.gz" ]; then
	rm www.tar.gz
fi
tar -czvf www.tar.gz www/
