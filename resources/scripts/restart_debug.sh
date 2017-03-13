#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
./shutdown.sh && rm log.txt && ./start.sh
