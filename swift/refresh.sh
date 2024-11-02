#!/bin/bash


echo Refresh / clean / build the Bibledit kernel source for iOS.


IOSSOURCE=`dirname $0`
if [ $? -ne 0 ]; then exit; fi
cd $IOSSOURCE
if [ $? -ne 0 ]; then exit; fi
IOSSOURCE=`pwd`
if [ $? -ne 0 ]; then exit; fi
echo The source path is $IOSSOURCE


KERNELSOURCE=../../cloud
KERNELDEST=Bibledit/src
WEBROOT=Bibledit/webroot


echo Copying Bibledit kernel files from $KERNELSOURCE to $KERNELDEST
mkdir -p $KERNELDEST
if [ $? -ne 0 ]; then exit; fi
rsync --archive --delete --exclude bridging_header.h --exclude cpp_file.* $KERNELSOURCE/ $KERNELDEST/
if [ $? -ne 0 ]; then exit; fi


# List distinct file suffixes:
# find . -name '*.?*' -type f | rev | cut -d. -f1 | rev | sort | uniq


echo Prepare and clean the Bibledit kernel code
pushd $KERNELDEST
if [ $? -ne 0 ]; then exit; fi
rm -rf .git
if [ $? -ne 0 ]; then exit; fi
echo Configure Bibledit in client mode
echo Run only one parallel task so the interface is more responsive
echo Enable the single-tab browser
./configure --enable-ios
if [ $? -ne 0 ]; then exit; fi
make clean
if [ $? -ne 0 ]; then exit; fi
echo Switch to MbedTLS 2.x
rm -rf mbedtls
if [ $? -ne 0 ]; then exit; fi
mv mbedtls2 mbedtls
if [ $? -ne 0 ]; then exit; fi
echo Remove all files except C and C++ source code
find . -type f ! -name '*.h' ! -name '*.hpp' ! -name '*.c' ! -name '*.cpp' ! -name '*.cxx' -delete
rm -f .DS_Store
if [ $? -ne 0 ]; then exit; fi
rm -rf .github
if [ $? -ne 0 ]; then exit; fi
rm -rf autom4te.cache
if [ $? -ne 0 ]; then exit; fi
rm -rf xcode.xcodeproj
if [ $? -ne 0 ]; then exit; fi
rm -rf unittests
if [ $? -ne 0 ]; then exit; fi
rm -rf sources
if [ $? -ne 0 ]; then exit; fi
rm -rf executable
if [ $? -ne 0 ]; then exit; fi
find . -name .deps -type d -delete
if [ $? -ne 0 ]; then exit; fi
find . -name exampleProgram.cpp -delete
if [ $? -ne 0 ]; then exit; fi
find . -name shell.c -delete
if [ $? -ne 0 ]; then exit; fi
rm -rf i18n
if [ $? -ne 0 ]; then exit; fi
echo Update the configuration: No external SWORD / ICU / UTF8PROC / PUGIXML libraries
sed -i.bak '/HAVE_SWORD/d' config.h
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/HAVE_ICU/d' config.h
if [ $? != 0 ]; then exit; fi
sed -i.bak '/HAVE_UTF8PROC/d' config.h
if [ $? != 0 ]; then exit; fi
sed -i.bak '/HAVE_PUGIXML/d' config.h
if [ $? != 0 ]; then exit; fi
echo The embedded web view cannot upload files
sed -i.bak '/CONFIG_ENABLE_FILE_UPLOAD/d' config/config.h
if [ $? -ne 0 ]; then exit; fi
find . -name '*.bak' -delete
if [ $? -ne 0 ]; then exit; fi
popd
if [ $? -ne 0 ]; then exit; fi






# echo Copying Bibledit kernel files from $KERNELSOURCE to $WEBROOT
# mkdir -p $WEBROOT
# if [ $? -ne 0 ]; then exit; fi
# rsync --archive --delete $KERNELSOURCE/  $WEBROOT/
# if [ $? -ne 0 ]; then exit; fi


# echo Prepare and clean the Bibledit kernel webroot
# pushd $WEBROOT
# if [ $? -ne 0 ]; then exit; fi
# echo Build several databases and other data for inclusion with the iOS package
# echo Building them on iOS takes a lot of time during the setup phase
# echo Including pre-built data speeds up the setup phase of Bibledit on iOS
# ./configure
# if [ $? -ne 0 ]; then exit; fi
# make --jobs=`sysctl -n hw.ncpu`
# if [ $? -ne 0 ]; then exit; fi
# ./generate . locale
# if [ $? -ne 0 ]; then exit; fi
# ./generate . mappings
# if [ $? -ne 0 ]; then exit; fi
# ./generate . versifications
# if [ $? -ne 0 ]; then exit; fi
# echo Remove the journal entries that were logged in the process
# rm -f logbook/1*
# if [ $? -ne 0 ]; then exit; fi
# make clean
# if [ $? -ne 0 ]; then exit; fi
# clean_source_and_webroot
#popd
#if [ $? -ne 0 ]; then exit; fi


# Todo
# function clean_source_and_webroot
# {
# echo Clean files up in directory `pwd`
# rm -f bibledit
# if [ $? -ne 0 ]; then exit; fi
# rm -r autom4te.cache
# if [ $? -ne 0 ]; then exit; fi
# rm dev
# if [ $? -ne 0 ]; then exit; fi
# rm reconfigure
# if [ $? -ne 0 ]; then exit; fi
# rm -f server
# if [ $? -ne 0 ]; then exit; fi
# rm -f unittest
# if [ $? -ne 0 ]; then exit; fi
# rm valgrind
# if [ $? -ne 0 ]; then exit; fi
# rm -r xcode*
# if [ $? -ne 0 ]; then exit; fi
# rm -r executable
# if [ $? -ne 0 ]; then exit; fi
# rm -rf sources/hebrewlexicon
# if [ $? -ne 0 ]; then exit; fi
# rm -rf sources/morphgnt
# if [ $? -ne 0 ]; then exit; fi
# rm -rf sources/morphhb
# if [ $? -ne 0 ]; then exit; fi
# rm -rf sources/sblgnt
# if [ $? -ne 0 ]; then exit; fi
# rm sources/oshb.xml.gz
# if [ $? -ne 0 ]; then exit; fi
# rm -rf unittests
# if [ $? -ne 0 ]; then exit; fi
# }







#
#echo Target iOS 13 excludes 32 bits builds
#
##clean
##compile armv7 iPhoneOS 32
#
##clean
##compile armv7s iPhoneOS 32
#
#clean
#compile arm64 iPhoneOS 64
#
##clean
##compile i386 iPhoneSimulator 32
#
#clean
#compile x86_64 iPhoneSimulator 64
#
#mkdir -p include
#if [ $? -ne 0 ]; then exit; fi
#cp webroot/library/bibledit.h include
#if [ $? -ne 0 ]; then exit; fi
#
#echo Creating fat library file
## lipo -create -output /tmp/libbibledit.a /tmp/libbibledit-armv7.a /tmp/libbibledit-armv7s.a /tmp/libbibledit-arm64.a /tmp/libbibledit-i386.a /tmp/libbibledit-x86_64.a
#lipo -create -output /tmp/libbibledit.a /tmp/libbibledit-arm64.a /tmp/libbibledit-x86_64.a
#if [ $? -ne 0 ]; then exit; fi
#lipo -info /tmp/libbibledit.a
#if [ $? -ne 0 ]; then exit; fi
#
#echo Copying library into place
#mkdir -p lib
#if [ $? -ne 0 ]; then exit; fi
#mv /tmp/libbibledit.a lib
#if [ $? -ne 0 ]; then exit; fi
#
#echo Clean libraries
##rm /tmp/libbibledit-armv7.a
##if [ $? -ne 0 ]; then exit; fi
##rm /tmp/libbibledit-armv7s.a
##if [ $? -ne 0 ]; then exit; fi
#rm /tmp/libbibledit-arm64.a
#if [ $? -ne 0 ]; then exit; fi
##rm /tmp/libbibledit-i386.a
##if [ $? -ne 0 ]; then exit; fi
#rm /tmp/libbibledit-x86_64.a
#if [ $? -ne 0 ]; then exit; fi
#
#echo Clean webroot
#pushd webroot
#if [ $? -ne 0 ]; then exit; fi
#rm aclocal.m4
#rm AUTHORS
#rm ChangeLog
#rm compile
#rm config.guess
#rm config.h.in
#rm config.log
#rm config.status
#rm config.sub
#rm configure
#rm configure.ac
#rm COPYING
#rm depcomp
#rm DEVELOP
#rm INSTALL
#rm install-sh
#rm Makefile
#rm Makefile.in
#rm Makefile.am
#rm missing
#rm NEWS
#rm README
#rm stamp-h1
#find . -name "*.h" -delete
#find . -name "*.cpp" -delete
#find . -name "*.c" -delete
#find . -name "*.o" -delete
#find . -name ".deps" -exec rm -r "{}" \; > /dev/null 2>&1
#find . -name ".dirstamp" -delete
#rm locale/README
#rm sandbox/*
#rm -rf unittests
#rm -rf sources
#
#popd
#if [ $? -ne 0 ]; then exit; fi
#
## Remove scripts so they won't get included with the submitted package.
#cd $BIBLEDITIOS/ios
#if [ $? -ne 0 ]; then exit; fi
#rm build.sh
#if [ $? -ne 0 ]; then exit; fi
#
## say Compile for iOS is ready
#
## Build the app.
#cd $BIBLEDITIOS/ios
#if [ $? -ne 0 ]; then exit; fi
#xcodebuild
#if [ $? -ne 0 ]; then exit; fi
#
#echo To graphically build the app for iOS open the project in Xcode:
#echo open $BIBLEDITIOS/ios/Bibledit.xcodeproj
#echo Then build it from within Xcode





# Build libbibledit for one iOS architecture.
# This script runs on macOS.
#function compile
#{
#
#ARCH=$1
#PLATFORM=$2
#BITS=$3
#echo Compile for architecture $ARCH $BITS bits
#
#export IPHONEOS_DEPLOYMENT_TARGET="13.0"
#SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM.sdk
#if [ $? -ne 0 ]; then exit; fi
#TOOLDIR=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
#if [ $? -ne 0 ]; then exit; fi
#COMPILEFLAGS="-Wall -g -O2 -c -I.."
#if [ $? -ne 0 ]; then exit; fi
#
#pushd webroot
#if [ $? -ne 0 ]; then exit; fi
#
## The following command saves all source files from Makefile.am to file.
## It uses several steps to obtain the result:
## * Obtain source files between the correct patterns.
## * Remove first line.
## * Remove last line.
## * Remove tabs.
## * Remove new lines.
## * Remove backslashes.
## * Remove the mbedtls sources.
#sed -n "/libbibledit_a_SOURCES/,/bin_PROGRAMS/p" Makefile.am | tail -n +2 | sed '$d' | strings | sed 's/\\//g' | sed '/mbedtls/d' > sources.txt
#if [ $? -ne 0 ]; then exit; fi
#
## Save the names of the C++ sources to file and load them.
#grep .cpp sources.txt > cppfiles.txt
#if [ $? -ne 0 ]; then exit; fi
#grep .cxx sources.txt >> cppfiles.txt
#if [ $? -ne 0 ]; then exit; fi
#CPPFILES=(`cat cppfiles.txt`)
#if [ $? -ne 0 ]; then exit; fi
#
## Save the name of the C sources to file and load them.
#cat sources.txt | sed '/.cpp/d' | sed '/.cxx/d' > cfiles.txt
#if [ $? -ne 0 ]; then exit; fi
#ls mbedtls/*.c >> cfiles.txt
#if [ $? -ne 0 ]; then exit; fi
#CFILES=(`cat cfiles.txt`)
#if [ $? -ne 0 ]; then exit; fi
#
#for cpp in ${CPPFILES[@]}; do
#
#extension="${cpp##*.}"
#basepath="${cpp%.*}"
#echo Compiling $cpp
#
## For debugging, add --verbose
#$TOOLDIR/clang++ -arch ${ARCH} -isysroot $SYSROOT -I. $COMPILEFLAGS -std=c++20 -stdlib=libc++ -o $basepath.o $cpp
#if [ $? -ne 0 ]; then exit; fi
#
#done
#
#for c in ${CFILES[@]}; do
#
#extension="${c##*.}"
#basepath="${c%.*}"
#echo Compiling $c
#
#$TOOLDIR/clang -arch ${ARCH} -isysroot $SYSROOT -I. $COMPILEFLAGS -o $basepath.o $c
#if [ $? -ne 0 ]; then exit; fi
#
#done
#
#popd
#if [ $? -ne 0 ]; then exit; fi
#
#
## Linking
#echo Linking
#
#pushd webroot
#if [ $? -ne 0 ]; then exit; fi
#
#$TOOLDIR/ar cru libbibledit.a `find . -name *.o`
#if [ $? -ne 0 ]; then exit; fi
#
#$TOOLDIR/ranlib libbibledit.a
#if [ $? -ne 0 ]; then exit; fi
#
#popd
#if [ $? -ne 0 ]; then exit; fi
#
#
## Copy output to temporal location
#
#pushd webroot
#if [ $? -ne 0 ]; then exit; fi
#cp libbibledit.a /tmp/libbibledit-$ARCH.a
#if [ $? -ne 0 ]; then exit; fi
#rm libbibledit.a
#if [ $? -ne 0 ]; then exit; fi
#popd
#if [ $? -ne 0 ]; then exit; fi
#
#}


echo Succesfully refreshed the Bibledit kernel
