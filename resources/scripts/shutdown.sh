#!/bin/bash
cd $(cd $(dirname $0) && pwd -P)
kill -9 $(cat server.pid)
