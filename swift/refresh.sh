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
KERNELDEST=Bibledit/kernel
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


echo Copying Bibledit kernel files from $KERNELSOURCE to $WEBROOT
mkdir -p $WEBROOT
if [ $? -ne 0 ]; then exit; fi
rsync --archive --delete $KERNELSOURCE/  $WEBROOT/
if [ $? -ne 0 ]; then exit; fi


echo Prepare and clean the Bibledit kernel webroot
pushd $WEBROOT
if [ $? -ne 0 ]; then exit; fi
echo Build several databases and other data for inclusion with the iOS package
echo Building them on iOS would take a lot of time during the setup phase
echo Including pre-built data speeds up the setup phase of Bibledit on iOS
./configure
if [ $? -ne 0 ]; then exit; fi
make --jobs=`sysctl -n hw.ncpu`
if [ $? -ne 0 ]; then exit; fi
./generate . locale
if [ $? -ne 0 ]; then exit; fi
./generate . mappings
if [ $? -ne 0 ]; then exit; fi
./generate . versifications
if [ $? -ne 0 ]; then exit; fi
echo Remove the journal entries that were logged in the process
rm -f logbook/1*
if [ $? -ne 0 ]; then exit; fi
make distclean
if [ $? -ne 0 ]; then exit; fi
rm -rf .git*
if [ $? -ne 0 ]; then exit; fi
echo Remove the C and C++ source code
find . -name '*.h' -delete
if [ $? -ne 0 ]; then exit; fi
find . -name '*.hpp' -delete
if [ $? -ne 0 ]; then exit; fi
find . -name '*.c' -delete
if [ $? -ne 0 ]; then exit; fi
find . -name '*.cpp' -delete
if [ $? -ne 0 ]; then exit; fi
find . -name '*.cxx' -delete
if [ $? -ne 0 ]; then exit; fi
rm -f .DS_Store
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
rm -rf i18n
if [ $? -ne 0 ]; then exit; fi
find . -maxdepth 1 -type f -delete
if [ $? -ne 0 ]; then exit; fi
find . -name ".dirstamp" -delete
if [ $? -ne 0 ]; then exit; fi
rm locale/README
if [ $? -ne 0 ]; then exit; fi
find . -name '*.sh' -delete
if [ $? -ne 0 ]; then exit; fi
rm -rf mbedtls*
if [ $? -ne 0 ]; then exit; fi
find . -name .deps -ls -exec rm -rv {} +
if [ $? -ne 0 ]; then exit; fi
popd
if [ $? -ne 0 ]; then exit; fi


echo Convert the file hierarchy in the webroot to a flat structure

pushd $WEBROOT
if [ $? -ne 0 ]; then exit; fi

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
  if [ $? -ne 0 ]; then exit; fi
done

echo Remove the now empty original directories
for directory in ${directories[@]}
do
  rm -rf $directory
done

popd
if [ $? -ne 0 ]; then exit; fi

echo Succesfully refreshed the Bibledit kernel
