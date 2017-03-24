#!/bin/bash

#####################################################################################
# nwf module manage script
# author: elvin
# date: 2017-3-23
#####################################################################################

usage(){
	echo "options:"
	echo "\t-i 'module name'"
	echo "\t\tinstall module"
	echo "\t-d 'module name'"
	echo "\t\tdelete module"
	echo "\t-u 'module name'"
	echo "\t\treinstall module"
}

init_repo(){
	cat module_source_repos.conf| grep -v '#'|while read line
	do
		rn=$(echo $line | cut -d' ' -f1)
		rl=$(echo $line | cut -d' ' -f2)
		if [ ! -d "npl_packages/$rn" ]; then
			echo "repository $rn doesn't exist, importing..."
			git submodule add "$rl" "npl_packages/$rn"
		fi
	done
}

install_mod(){
	init_repo
	mod=$1
	for di in $(ls npl_packages)
	do
		echo $(cd "npl_packages/$di" && git pull)
		modBaseDir="npl_packages/$di/nwf_modules/$mod"
		if [ "${di}x" = "mainx" ]; then
			continue
		fi
		if [ -d $modBaseDir ]; then
			echo "module '$mod' founded in repository '$di'"
			if [ -d www/modules/$mod ]; then
				echo "module '$mod' was already installed, skipped."
			else
				echo start install...
				echo copy files...
				cp $modBaseDir www/modules/ -r
				if [ -f "www/modules/$mod/install.sh" ]; then
					echo executing "www/modules/$mod/install.sh"
					echo $(cd www/modules/$mod && bash ./install.sh)
				fi
				echo "done."
				break;
			fi
		else
			echo "module '$mod' was not found in repository '$di'"
		fi
	done
}

del_mod(){
	mod=$1
	flag=0
	for di in $(ls www/modules)
	do
		modDir="www/modules/$di"
		if [ -d $modDir ]; then
			echo "module '$mod' founded in '$modDir'"
			if [ -f "$modDir/del.sh" ]; then
				echo executing "$modDir/del.sh"
				echo $(cd $modDir && bash ./del.sh)
			fi
			echo remove files...
			echo $(cd www/modules && echo "remove dir $di" && rm $di -rf)
			echo "done."
			flag=1
			break;
		fi
	done
	if [ $flag -eq 0 ]; then
		echo "module '$mod' can not found."
	fi
}

reinstall_mod(){
	mod=$1
	echo deleting...
	del_mod $mod
	echo reinstall...
	install_mod $mod
	echo completed.
}

if [ $# -lt 1 ] ; then
	usage
	exit 1;
fi

cd $(cd $(dirname $0) && pwd -P)

while getopts ":i:d:u:" opt
do
        case $opt in
                i ) install_mod $OPTARG ;;
                d ) del_mod $OPTARG ;;
                u ) reinstall_mod $OPTARG ;;
                ? ) usage
                    exit 1;;
        esac
done
