#!/bin/bash

#####################################################################################
# nwf application project update script
# author: elvin
# date: 2017-2-27
# desc: this script will update nwf project automatically
#####################################################################################

echo updating project...

get_hash(){
    f=$1
    cat .nwf/md5sum | sed 's/*//' | while read line
    do
        p=$(echo $line | awk '{print $2}')
        h=$(echo $line | awk '{print $1}')
        if [ "${f}x" = "${p}x" -o "./${f}x" = "${p}x" ] ; then
            echo "$h"
            break;
        fi
    done
}

update_hash(){
    f=$1
    focs=$(get_hash $f)
    fncsi=$(md5sum $f)
    lno=$(grep "$focs" .nwf/md5sum -n | cut -d':' -f1)
    sed -i "$lno d" .nwf/md5sum
    echo $fncsi >> .nwf/md5sum
}

echo analyzing...

dlst="$(pwd)/.nwf/upd.dir.list"
echo -n "" > $dlst

cwd=$(pwd)
cd ./npl_packages/nwf/resources/demo/
find . -type d | while read line
do
    echo ./npl_packages/nwf/resources/demo/${line:2} www/${line:2} >> $dlst
done
cd "$cwd"
echo "https://github.com/elvinzeng/nwf lib/so" >> $dlst
echo "https://github.com/elvinzeng/nwf lib/dll" >> $dlst

flst="$(pwd)/.nwf/upd.file.list"
echo -n "" > $flst

echo npl_packages/nwf/resources/config/gitignore .gitignore >> $flst
echo npl_packages/nwf/resources/config/module_source_repos.conf module_source_repos.conf >> $flst
echo npl_packages/nwf/resources/config/webserver.config.xml www/webserver.config.xml >> $flst

find ./npl_packages/nwf/resources/lua/ -type f | while read line
do
    echo $line www/$(basename $line) >> $flst
done

find ./npl_packages/nwf/resources/scripts/ ! -name "_*.sh" -type f | while read line
do
    echo $line $(basename $line) >> $flst
done

cwd=$(pwd)
cd ./npl_packages/nwf/resources/demo/
find . -type f | while read line
do
    echo ./npl_packages/nwf/resources/demo/${line:2} www/${line:2} >> $flst
done
cd "$cwd"


echo check directory...
cat $dlst | while read line
do
    di=$(echo $line | cut -d' ' -f2)
    if [ ! -d "$di" ]; then
        mkdir -p "$di"
        echo "directory $di does not exist, automatically created."
    else
        echo "directory $di already exist, skipped."
    fi
done

echo ckeck file...
cat $flst | while read line
do
    sf=$(echo $line | cut -d' ' -f1)
    tf=$(echo $line | cut -d' ' -f2)
    if [ -f "$tf" ]; then
        ccs=$(md5sum $tf | cut -d' ' -f1)
        ocs=$(get_hash $tf)
        if [ "${ccs}" = "" -o "$ocs" = "" ]; then
            echo checksum error, failed to update project.
            exit 1
        fi
        if [ "${ccs}x" = "${ocs}x" ]; then
            cp $sf $tf
            update_hash $tf
            echo "file $tf already exist, automatically updated."
        else
            echo "file $tf already exist, but has been modified by hand, skipped."
        fi
    else
        cp $sf $tf
        md5sum $tf >> .nwf/md5sum
        echo "file $tf does not exist, automatically copied."
    fi
done

echo project updated.