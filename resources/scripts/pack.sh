#!/bin/bash

#####################################################################################
# desc: generate target package for deploy
# author: elvin
# date: 2017-4-28
#####################################################################################

BUILD_DIR="build"
BUILD_DIR_SOURCE="source"
BUILD_DIR_TARGET="target"
SOURCE_DIR="$BUILD_DIR/$BUILD_DIR_SOURCE"
TARGET_DIR="$BUILD_DIR/$BUILD_DIR_TARGET"

cd $(cd $(dirname $0) && pwd -P)

PROJECT_BASE_DIR=$(pwd)

echo creating temp directories...
if [ ! -d "$SOURCE_DIR" ]; then
	mkdir "$SOURCE_DIR" -p
else
	echo cleaning source files...
	cd $BUILD_DIR
	rm $BUILD_DIR_SOURCE -rf
	mkdir $BUILD_DIR_SOURCE
	cd $PROJECT_BASE_DIR
fi
if [ ! -d "$TARGET_DIR" ]; then
        mkdir "$TARGET_DIR" -p
else
	echo cleaning target files...
        cd $BUILD_DIR
        rm $BUILD_DIR_TARGET -rf
        mkdir $BUILD_DIR_TARGET
        cd $PROJECT_BASE_DIR
fi

echo copy files to temp directory...
cp www $SOURCE_DIR -rv
cp dependencies.conf $SOURCE_DIR
cp .git $SOURCE_DIR -r
cp .gitignore $SOURCE_DIR
cp .gitmodules $SOURCE_DIR
cp lib $SOURCE_DIR -rv
cp module_source_repos.conf $SOURCE_DIR
cp npl_packages $SOURCE_DIR -r
cp .nwf $SOURCE_DIR -rv
cp *.sh $SOURCE_DIR -rv
cp *.bat $SOURCE_DIR -rv

cd $SOURCE_DIR
echo "current dir: $(pwd)"
echo "updating files..."
git pull
bash ./update_packages.sh
bash ./nwf_module_manage.sh -I
bash ./nwf_module_manage.sh -r

cd $PROJECT_BASE_DIR/$BUILD_DIR

echo copy files to target directory...
cp $BUILD_DIR_SOURCE/www $BUILD_DIR_TARGET -rv
cp $BUILD_DIR_SOURCE/lib $BUILD_DIR_TARGET -rv
cp $BUILD_DIR_SOURCE/npl_packages $BUILD_DIR_TARGET -r
cp $BUILD_DIR_SOURCE/start.sh $BUILD_DIR_TARGET
cp $BUILD_DIR_SOURCE/shutdown.sh $BUILD_DIR_TARGET
cp $BUILD_DIR_SOURCE/dependencies.conf $BUILD_DIR_TARGET

echo pack completed. target directory: $PROJECT_BASE_DIR/$BUILD_DIR_TARGET

