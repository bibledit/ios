#!/bin/bash


# Exit script on error.
set -e


echo Refresh / clean / build the Bibledit kernel source for iOS.


IOSSOURCE=`dirname $0`
cd $IOSSOURCE
IOSSOURCE=`pwd`
echo The source path is $IOSSOURCE


KERNELSOURCE=../cloud
KERNELDEST=Bibledit/kernel
WEBROOT=Bibledit/webroot


echo Copying Bibledit kernel files from $KERNELSOURCE to $KERNELDEST
mkdir -p $KERNELDEST
rsync --archive --delete --exclude bridging_header.h --exclude cpp_file.* $KERNELSOURCE/ $KERNELDEST/


# List distinct file suffixes:
# find . -name '*.?*' -type f | rev | cut -d. -f1 | rev | sort | uniq


echo Prepare and clean the Bibledit kernel code
pushd $KERNELDEST
rm -rf .git
echo Configure Bibledit in client mode
echo Run only one parallel task so the interface is more responsive
echo Enable the single-tab browser
./configure --enable-ios
make clean
echo Switch to MbedTLS 2.x
rm -rf mbedtls
mv mbedtls2 mbedtls
echo Remove all files except C and C++ source code
find . -type f ! -name '*.h' ! -name '*.hpp' ! -name '*.c' ! -name '*.cpp' ! -name '*.cxx' -delete
rm -f .DS_Store
rm -rf .github
rm -rf autom4te.cache
rm -rf xcode.xcodeproj
rm -rf unittests
rm -rf sources
rm -rf executable
find . -name .deps -type d -delete
find . -name exampleProgram.cpp -delete
find . -name shell.c -delete
rm -rf i18n
echo Update the configuration: No external SWORD / ICU / UTF8PROC / PUGIXML libraries
sed -i.bak '/HAVE_SWORD/d' config.h
sed -i.bak '/HAVE_ICU/d' config.h
if [ $? != 0 ]; then exit; fi
sed -i.bak '/HAVE_UTF8PROC/d' config.h
if [ $? != 0 ]; then exit; fi
sed -i.bak '/HAVE_PUGIXML/d' config.h
if [ $? != 0 ]; then exit; fi
echo The embedded web view cannot upload files
sed -i.bak '/CONFIG_ENABLE_FILE_UPLOAD/d' config/config.h
find . -name '*.bak' -delete
popd


echo Copying Bibledit kernel files from $KERNELSOURCE to $WEBROOT
mkdir -p $WEBROOT
rsync --archive --delete $KERNELSOURCE/  $WEBROOT/


echo Prepare and clean the Bibledit kernel webroot
pushd $WEBROOT
echo Build several databases and other data for inclusion with the iOS package
echo Building them on iOS would take a lot of time during the setup phase
echo Including pre-built data speeds up the setup phase of Bibledit on iOS
./configure
make --jobs=`sysctl -n hw.ncpu`
./generate . locale
./generate . mappings
./generate . versifications
echo Remove the journal entries that were logged in the process
rm -f logbook/1*
make distclean
rm -rf .git*
echo Remove the C and C++ source code
find . -name '*.h' -delete
find . -name '*.hpp' -delete
find . -name '*.c' -delete
find . -name '*.cpp' -delete
find . -name '*.cxx' -delete
rm -f .DS_Store
rm -rf autom4te.cache
rm -rf xcode.xcodeproj
rm -rf unittests
rm -rf sources
rm -rf executable
find . -name .deps -type d -delete
rm -rf i18n
find . -maxdepth 1 -type f -delete
find . -name ".dirstamp" -delete
rm locale/README
find . -name '*.sh' -delete
rm -rf mbedtls*
find . -name .deps -ls -exec rm -rv {} +
popd


echo Convert the file hierarchy in the webroot to a flat structure

pushd $WEBROOT

echo Creating array of directories in webroot
directories=($(find . -type d))

echo Creating array of files in webroot
files=($(find . -type f))

echo Iterate over the directories
echo Convert them to marked files
echo Always end with .res to ensure Xcode sees them as resources
echo Example:
echo Directory \"database/config\" becomes file \"dir#database#config.res\"
for directory in ${directories[@]}
do
  # Remove the initial dot slash, e.g. change './help' to 'help'.
  directory=${directory#./}
  # Replace the slashes with '#', e.g. change 'mimetic098/rfc822' tp 'mimetic098#rfc822'.
  directory=${directory//\//#}
  # Create a filename like 'dir#help' or 'dir#mimetic098#ref822.res'.
  file=dir#${directory}.res
  echo folder > $file
done

echo Iterate over the files
echo Convert them to marked files
echo Always end with .res to ensure Xcode sees them as resources
echo Example:
echo Directory \"help/changelog.html\" becomes file \"file#help#changelog.html.res\"
for file in ${files[@]}
do
  # Remove the initial dot slash, e.g. change './help/changelog.html' to 'help/changelog.html'.
  file2=${file#./}
  # Replace the slashes with '#', e.g. change 'help/changelog.html' tp 'help#changelog.html'.
  file2=${file2//\//#}
  # Move the original file to a new file like 'file#help#changelog.html.res'.
  file2=file#${file2}.res
  mv $file $file2
  done

echo Remove the now empty original directories
for directory in ${directories[@]}
do
  rm -rf $directory
done

popd

echo Succesfully refreshed the Bibledit kernel
