#!/bin/bash


echo Refresh / clean / build the Bibledit kernel source for iOS.


IOSSOURCE=`dirname $0`
if [ $? -ne 0 ]; then exit; fi
cd $IOSSOURCE
if [ $? -ne 0 ]; then exit; fi
IOSSOURCE=`pwd`
if [ $? -ne 0 ]; then exit; fi
echo The source path is $IOSSOURCE


WEBROOT=Bibledit/webroot

pushd $WEBROOT
if [ $? -ne 0 ]; then exit; fi

echo Creating array of directories
directories=($(find . -type d))
echo Creating array of files
files=($(find . -type f))


for directory in ${directories[@]}
do
  echo $directory
  echo ${directory#./}
done


# function process_item ()
# {
#   item=$1
#   echo $item
#   if test -d $item
#   then
#     echo "directory"
#     for item in $item/*
#     do
#         process_item $item
#     done
#   elif
#     echo "file"
#  fi
#     echo $dir
#     # Remove the trailing slash
#     dir=${dir%*/}
#     echo $dir
#     # Print everything after the final slash.
#     echo "${dir##*/}"
# }


# for item in *
# do
#     process_item $item
# done


popd
if [ $? -ne 0 ]; then exit; fi

echo Succesfully imploded the webroot
