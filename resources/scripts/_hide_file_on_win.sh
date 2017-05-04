#!/bin/bash
# desc: A util for script on cygwin
# if it running on cygwin, it will hide specified file or directory.

homepath="$(echo $HOME)"
target="$1"

if [ ${#homepath} -gt 9 -a "${homepath:0:9}x" = "/c/Users/x" ]; then
    attrib +H "$target"
fi