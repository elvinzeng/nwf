#!/bin/bash

#####################################################################################
# auto reinitialize project
# author: elvin
# date: 2017-4-13
# description by English:
# When you just clone the project from git,
# your project directory maybe could not found many files,
# because your git submodule has not been initialized.
# This time you need to run this script. It will automatically init all submodule.
# description by Chinese:
# 在你刚刚将项目克隆下来的时候，git子模块尚未初始化，此时你的项目目录中可能或缺少很多文件。
# 这个时候你需要运行一次这个脚本。这个脚本将会自动帮你重新初始化项目。
#####################################################################################

PROJECT_BASE_DIR="$(pwd)"
if [ ! -f ".nwf/reinitialized_flag" ]; then
    echo "reinitializing project..."
    echo "init submodules..."
    git submodule update --init --recursive
    for di in $(ls npl_packages)
	do
		cd "npl_packages/$di"
		git checkout master
		cd "$PROJECT_BASE_DIR"
	done

	echo "init modules sources..."
    bash npl_packages/nwf/resources/scripts/_dos2unix.sh module_source_repos.conf
	cat module_source_repos.conf| grep -v '#'|while read line
	do
		rn=$(echo $line | cut -d' ' -f1)
		rl=$(echo $line | cut -d' ' -f2)
		rb=$(echo $line | cut -d' ' -f3)
		if [ ! -d "npl_packages/$rn" ]; then
			echo "repository $rn doesn't exist, importing..."
			git submodule add "$rl" "npl_packages/$rn"
		fi
		cd "npl_packages/$rn"
        git checkout "${rb:-master}"
        cd "$PROJECT_BASE_DIR"
	done

    echo "do not run reinitialize script again! project already reinitialized at: $(date '+%F %T')" > .nwf/reinitialized_flag
    echo "reinitialize completed."
else
    cat .nwf/reinitialized_flag
fi



