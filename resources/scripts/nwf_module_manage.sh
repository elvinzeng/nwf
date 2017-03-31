#!/bin/bash

#####################################################################################
# nwf module manage script
# author: elvin
# date: 2017-3-23
#####################################################################################

usage(){
	echo "options:"
	echo "    -i 'module name'"
	echo "        install module"
	echo "    -d 'module name'"
	echo "        delete module"
	echo "    -u 'module name'"
	echo "        reinstall module"
	echo "    -m"
	echo "        list all installed modules"
	echo "    -a"
	echo "        list all available modules"
}

init_repo(){
    echo "init repositories..."
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
	local mod=$1
	if [ "${mod}x" != "x" ]; then
		local di=""
		for di in $(ls npl_packages)
		do
			local modBaseDir="npl_packages/$di/nwf_modules/$mod"
			if [ "${di}x" = "mainx" ]; then
				continue
			fi
			if [ -d $modBaseDir ]; then
				echo "module '$mod' founded in repository '$di'"
				if [ -d www/modules/$mod ]; then
					echo "module '$mod' was already installed, skipped."
				else
					if [ -f $modBaseDir/dependencies.conf ]; then
						echo install dependencies of module $mod...
						cat $modBaseDir/dependencies.conf | grep -v '^$'
						local line=""
						cat $modBaseDir/dependencies.conf | grep -v '^$' | while read line
						do
							install_mod $line
						done
					fi
					echo start install module $mod...
					echo copy files...
					cp $modBaseDir www/modules/ -r
					if [ -f "www/modules/$mod/install.sh" ]; then
						echo executing "www/modules/$mod/install.sh"
						echo $(cd www/modules/$mod && bash ./install.sh)
					fi
					echo "module $mod installattion completed."
				fi
				break;
			else
				echo "module '$mod' was not found in repository '$di'"
			fi
		done
	fi
}

del_mod(){
	mod=$1
	modDir="www/modules/$mod"
	if [ -d $modDir ]; then
		echo "module '$mod' founded in '$modDir'"
		if [ -f "$modDir/del.sh" ]; then
			echo executing "$modDir/del.sh"
			echo $(cd $modDir && bash ./del.sh)
		fi
		echo remove files...
		echo $(cd www/modules && echo "remove dir $mod" && rm $mod -rf)
		echo "done."
	else
		echo "module '$mod' can not found."
	fi
}

reinstall_mod(){
	mod=$1
	init_repo
	for di in $(ls npl_packages)
	do
		echo $(cd "npl_packages/$di" && git pull)
	done
	echo deleting...
	del_mod $mod
	echo reinstall...
	install_mod $mod
	echo completed.
}

installed_modules(){
	for di in $(ls www/modules)
	do
		modDir="www/modules/$di"
		if [ -d $modDir ]; then
			echo "$di"
			if [ -f "$modDir/desc.txt" ]; then
				cat "$modDir/desc.txt"
			fi
			echo " "
			echo "-------"
		fi
	done
}

all_modules(){
	init_repo
	echo "updating repositories..."
	for di in $(ls npl_packages)
	do
	    local cwd=$(pwd)
		cd "npl_packages/$di" && git pull
		cd $cwd
	done
	echo "============ [all available modules] ============"
	for di in $(ls npl_packages)
	do
		if [ -d npl_packages/$di/nwf_modules ]; then
			for mod in $(ls npl_packages/$di/nwf_modules)
			do
				modBaseDir="npl_packages/$di/nwf_modules/$mod"
				if [ "${di}x" = "mainx" ]; then
					continue
				fi
				if [ -d $modBaseDir ]; then
					echo "$mod"
					if [ -f "$modBaseDir/desc.txt" ]; then
						cat "$modBaseDir/desc.txt"
					fi
					echo " "
					echo "-------"
				fi
			done
		fi
	done
	echo "============ [all available modules] end ========="
}

if [ $# -lt 1 ] ; then
	usage
	exit 1;
fi

cd $(cd $(dirname $0) && pwd -P)

while getopts ":i:d:u:ma" opt
do
        case $opt in
                i ) init_repo
                    for di in $(ls npl_packages)
                    do
                        echo $(cd "npl_packages/$di" && git pull)
                    done
                    install_mod $OPTARG ;;
                d ) del_mod $OPTARG ;;
                u ) reinstall_mod $OPTARG ;;
				m ) installed_modules ;;
				a ) all_modules ;;
                ? ) usage
                    exit 1;;
        esac
done
