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
	echo "    -r"
	echo "        update(reinstall) all modules"
}

init_repo(){
    echo "init repositories..."
    cwd=$(pwd)
    bash npl_packages/nwf/resources/scripts/_dos2unix.sh module_source_repos.conf
	cat module_source_repos.conf| grep -v '#'|while read line
	do
		rn=$(echo $line | cut -d' ' -f1)
		rl=$(echo $line | cut -d' ' -f2)
		rb=$(echo $line | cut -d' ' -f3)
		if [ ! -d "npl_packages/$rn" ]; then
			echo "repository $rn doesn't exist, importing..."
			git submodule add "$rl" "npl_packages/$rn"
			cd "npl_packages/$rn"
            git checkout "${rb:-master}"
            cd "$cwd"
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
						#bash npl_packages/nwf/resources/scripts/_dos2unix.sh $modBaseDir/dependencies.conf
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
						local cwd="$(pwd)"
						cd www/modules/$mod
						bash ${cwd}/npl_packages/nwf/resources/scripts/_dos2unix.sh install.sh
						bash ./install.sh
						cd "$cwd"
						echo executing "www/modules/$mod/install.sh"
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
	cancelFlag=0;
	depm=""

	for m in $(ls www/modules)
	do
	    if [ -e www/modules/$m/dependencies.conf ]; then
	        bash npl_packages/nwf/resources/scripts/_dos2unix.sh www/modules/$m/dependencies.conf
	        count=$(grep "$mod" www/modules/$m/dependencies.conf | wc -l)
	        if [ $count -gt 0 ]; then
	            cancelFlag=1;
	            depm="$m"
	            break;
	        fi
	    fi
	done

    if [ $cancelFlag -ne 0 ]; then
        echo "Module \"$mod\" cannot be uninstalled because module \"$depm\" is dependent on it."
    else
        modDir="www/modules/$mod"
        if [ -d $modDir ]; then
            echo "module '$mod' founded in '$modDir'"
            if [ -f "$modDir/del.sh" ]; then
                local cwd="$(pwd)"
                cd "$modDir"
                bash ${cwd}/npl_packages/nwf/resources/scripts/_dos2unix.sh del.sh
                bash ./del.sh
                cd "$cwd"
                echo executing "$modDir/del.sh"
            fi
            echo remove files...
            echo $(cd www/modules && echo "remove dir $mod" && rm $mod -rf)
            echo "done."
        else
            echo "module '$mod' can not found."
        fi
	fi
}

del_mod_force(){
	mod=$1
    modDir="www/modules/$mod"
    if [ -d $modDir ]; then
        echo "module '$mod' founded in '$modDir'"
        if [ -f "$modDir/del.sh" ]; then
            local cwd="$(pwd)"
            cd "$modDir"
            bash ${cwd}/npl_packages/nwf/resources/scripts/_dos2unix.sh del.sh
            bash ./del.sh
            cd "$cwd"
            echo executing "$modDir/del.sh"
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
		local cwd=$(pwd)
		cd "npl_packages/$di" && git pull
		cd $cwd
	done
	echo deleting...
	del_mod_force $mod
	echo reinstall...
	install_mod $mod
	echo completed.
}

reinstall_all_mod(){
	echo "updating repositories..."
	for di in $(ls npl_packages)
	do
		local cwd=$(pwd)
		cd "npl_packages/$di" && git pull
		cd $cwd
	done
	echo "==============================="
	for di in $(ls www/modules)
	do
		echo deleting...
		del_mod_force $di
		echo reinstall...
		install_mod $di
		echo completed.
		echo "------------"
	done
}

installed_modules(){
	for di in $(ls www/modules)
	do
		modDir="www/modules/$di"
		if [ -d $modDir ]; then
			echo "name: $di"
			if [ -f "$modDir/desc.txt" ]; then
			    echo "introduction:"
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
					echo "name: $mod"
					if [ -f "$modBaseDir/desc.txt" ]; then
						echo "introduction:"
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

while getopts ":i:d:u:mar" opt
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
				r ) reinstall_all_mod ;;
				a ) all_modules ;;
                ? ) usage
                    exit 1;;
        esac
done
