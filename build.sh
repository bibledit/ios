# Synchronize and build libbibledit on OS X for iOS.


# Clean the Bibledit library.
function clean
{
  pushd webroot
  if [ $? -ne 0 ]; then exit; fi
  echo Clean source.
  make clean > /dev/null
  if [ $? -ne 0 ]; then exit; fi
  find . -name "*.o" -delete
  if [ $? -ne 0 ]; then exit; fi
  popd
  if [ $? -ne 0 ]; then exit; fi
}


# Build libbibledit for one iOS architecure.
# This script runs on OS X.
function compile
{

ARCH=$1
PLATFORM=$2
BITS=$3
echo Compile for architecture $ARCH $BITS bits

export IPHONEOS_DEPLOYMENT_TARGET="10.0"
SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM.sdk
if [ $? -ne 0 ]; then exit; fi
TOOLDIR=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
if [ $? -ne 0 ]; then exit; fi
COMPILEFLAGS="-Wall -Wextra -pedantic -g -O2 -c -I.."
if [ $? -ne 0 ]; then exit; fi

pushd webroot
if [ $? -ne 0 ]; then exit; fi

# The following command saves all source files from Makefile.am to file.
# It uses several steps to obtain the result:
# * Obtain source files between the correct patterns.
# * Remove first line.
# * Remove last line.
# * Remove tabs.
# * Remove new lines.
# * Remove backslashes.
sed -n "/libbibledit_a_SOURCES/,/bin_PROGRAMS/p" Makefile.am | tail -n +2 | sed '$d' | strings | sed 's/\\//g' > sources.txt
if [ $? -ne 0 ]; then exit; fi

# Save the names of the C++ sources to file and load them.
grep .cpp sources.txt > cppfiles.txt
if [ $? -ne 0 ]; then exit; fi
grep .cxx sources.txt >> cppfiles.txt
if [ $? -ne 0 ]; then exit; fi
CPPFILES=(`cat cppfiles.txt`)
if [ $? -ne 0 ]; then exit; fi

# Save the name of the C sources to file and load them.
cat sources.txt | sed '/.cpp/d' | sed '/.cxx/d' > cfiles.txt
if [ $? -ne 0 ]; then exit; fi
CFILES=(`cat cfiles.txt`)
if [ $? -ne 0 ]; then exit; fi

for cpp in ${CPPFILES[@]}; do

extension="${cpp##*.}"
basepath="${cpp%.*}"
echo Compiling c++ $cpp

# For debugging, add --verbose
$TOOLDIR/clang++ -arch ${ARCH} -isysroot $SYSROOT -I. $COMPILEFLAGS -std=c++17 -stdlib=libc++ -o $basepath.o $cpp
if [ $? -ne 0 ]; then exit; fi

done

for c in ${CFILES[@]}; do

extension="${c##*.}"
basepath="${c%.*}"
echo Compiling c $c

$TOOLDIR/clang -arch ${ARCH} -isysroot $SYSROOT -I. $COMPILEFLAGS -o $basepath.o $c
if [ $? -ne 0 ]; then exit; fi

done

popd
if [ $? -ne 0 ]; then exit; fi


# Linking
echo Linking

pushd webroot
if [ $? -ne 0 ]; then exit; fi

$TOOLDIR/ar cru libbibledit.a `find . -name *.o`
if [ $? -ne 0 ]; then exit; fi

$TOOLDIR/ranlib libbibledit.a
if [ $? -ne 0 ]; then exit; fi

popd
if [ $? -ne 0 ]; then exit; fi


# Copy output to temporal location

pushd webroot
if [ $? -ne 0 ]; then exit; fi
cp libbibledit.a /tmp/libbibledit-$ARCH.a
if [ $? -ne 0 ]; then exit; fi
rm libbibledit.a
if [ $? -ne 0 ]; then exit; fi
popd
if [ $? -ne 0 ]; then exit; fi

}


# Above this point are the functions.
# Below this point starts the main script.


# Take the relevant source code for building Bibledit for iOS.
# Put it in a temporal location.
# The purpose is to put the build files in a temporal location,
# and to have no duplicated code for the bibledit library.
# This does not clutter the bibledit git repository with the built files.
IOSSOURCE=`dirname $0`
if [ $? -ne 0 ]; then exit; fi
cd $IOSSOURCE
if [ $? -ne 0 ]; then exit; fi
BIBLEDITIOS=/tmp/bibledit-ios
echo Synchronizing relevant source code to $BIBLEDITIOS
mkdir -p $BIBLEDITIOS
if [ $? -ne 0 ]; then exit; fi
rsync --archive --delete ../cloud $BIBLEDITIOS/
if [ $? -ne 0 ]; then exit; fi
rsync --archive --delete ../ios $BIBLEDITIOS/
if [ $? -ne 0 ]; then exit; fi

# From now on the working directory is the temporal location.
cd $BIBLEDITIOS/ios
if [ $? -ne 0 ]; then exit; fi

# Make the dummy bibledit.h/cpp files ineffective.
rm Bibledit\ iOS/bibledit.h
if [ $? -ne 0 ]; then exit; fi
echo // empty > Bibledit\ iOS/bibledit.cpp
if [ $? -ne 0 ]; then exit; fi


# Build several databases and other data for inclusion with the iOS package.
# The reason for this is that building them on iOS takes a lot of time during the setup phase.
# To include pre-built data, that speeds up the setup phase of Bibledit on iOS.
# At the end, it removes the journal entries that were logged in the process.
pushd ../cloud
if [ $? -ne 0 ]; then exit; fi
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
rm -f logbook/1*
if [ $? -ne 0 ]; then exit; fi
popd
if [ $? -ne 0 ]; then exit; fi

# Sychronizes the libbibledit data files in the source tree to iOS and cleans them up.
rsync -a --delete ../cloud/ webroot
if [ $? -ne 0 ]; then exit; fi
pushd webroot
if [ $? -ne 0 ]; then exit; fi
./configure
if [ $? -ne 0 ]; then exit; fi
make distclean
if [ $? -ne 0 ]; then exit; fi
rm -f bibledit
rm -r autom4te.cache
rm dev
rm reconfigure
rm -f server
rm -f unittest
rm valgrind
rm -r xcode
rm -r executable
rm -rf sources/hebrewlexicon
rm -rf sources/morphgnt
rm -rf sources/morphhb
rm -rf sources/sblgnt
rm sources/oshb.xml.gz
rm -rf unittests
popd
if [ $? -ne 0 ]; then exit; fi

pushd webroot
if [ $? -ne 0 ]; then exit; fi
# Configure Bibledit in client mode,
# Run only only one parallel task so the interface is more responsive.
# Enable the single-tab browser.
./configure --enable-ios
if [ $? -ne 0 ]; then exit; fi
# No longer set the network port manually.
# echo 8765 > config/network-port
# if [ $? -ne 0 ]; then exit; fi
# Update the Makefile.
sed -i.bak '/SWORD_CFLAGS =/d' Makefile
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/SWORD_LIBS =/d' Makefile
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/ICU_CFLAGS =/d' Makefile
if [ $? != 0 ]; then exit; fi
sed -i.bak '/ICU_LIBS =/d' Makefile
if [ $? != 0 ]; then exit; fi
sed -i.bak '/XML2_CFLAGS =/d' Makefile
if [ $? != 0 ]; then exit; fi
sed -i.bak '/XML2_LIBS =/d' Makefile
if [ $? != 0 ]; then exit; fi
# Update the configuration: No external SWORD / ICU / UTF8PROC / PUGIXML libraries.
sed -i.bak '/HAVE_SWORD/d' config.h
if [ $? -ne 0 ]; then exit; fi
sed -i.bak '/HAVE_ICU/d' config.h
if [ $? != 0 ]; then exit; fi
sed -i.bak '/HAVE_UTF8PROC/d' config.h
if [ $? != 0 ]; then exit; fi
sed -i.bak '/HAVE_PUGIXML/d' config.h
if [ $? != 0 ]; then exit; fi
# The embedded web view cannot upload files.
sed -i.bak '/CONFIG_ENABLE_FILE_UPLOAD/d' config/config.h
if [ $? -ne 0 ]; then exit; fi
# Done.
popd
if [ $? -ne 0 ]; then exit; fi

clean
compile armv7 iPhoneOS 32

clean
compile armv7s iPhoneOS 32

clean
compile arm64 iPhoneOS 64

clean
compile i386 iPhoneSimulator 32

clean
compile x86_64 iPhoneSimulator 64

mkdir -p include
if [ $? -ne 0 ]; then exit; fi
cp webroot/library/bibledit.h include
if [ $? -ne 0 ]; then exit; fi

echo Creating fat library file
lipo -create -output /tmp/libbibledit.a /tmp/libbibledit-armv7.a /tmp/libbibledit-armv7s.a /tmp/libbibledit-arm64.a /tmp/libbibledit-i386.a /tmp/libbibledit-x86_64.a
if [ $? -ne 0 ]; then exit; fi
lipo -info /tmp/libbibledit.a
if [ $? -ne 0 ]; then exit; fi

echo Copying library into place
mkdir -p lib
if [ $? -ne 0 ]; then exit; fi
mv /tmp/libbibledit.a lib
if [ $? -ne 0 ]; then exit; fi

echo Clean libraries
rm /tmp/libbibledit-armv7.a
if [ $? -ne 0 ]; then exit; fi
rm /tmp/libbibledit-armv7s.a
if [ $? -ne 0 ]; then exit; fi
rm /tmp/libbibledit-arm64.a
if [ $? -ne 0 ]; then exit; fi
rm /tmp/libbibledit-i386.a
if [ $? -ne 0 ]; then exit; fi
rm /tmp/libbibledit-x86_64.a
if [ $? -ne 0 ]; then exit; fi

echo Clean webroot
pushd webroot
if [ $? -ne 0 ]; then exit; fi
rm aclocal.m4
rm AUTHORS
rm ChangeLog
rm compile
rm config.guess
rm config.h.in
rm config.log
rm config.status
rm config.sub
rm configure
rm configure.ac
rm COPYING
rm depcomp
rm DEVELOP
rm INSTALL
rm install-sh
rm Makefile
rm Makefile.in
rm Makefile.am
rm missing
rm NEWS
rm README
rm stamp-h1
find . -name "*.h" -delete
find . -name "*.cpp" -delete
find . -name "*.c" -delete
find . -name "*.o" -delete
find . -name ".deps" -exec rm -r "{}" \; > /dev/null 2>&1
find . -name ".dirstamp" -delete
rm locale/README
rm sandbox/*
rm -rf unittests
rm -rf sources

popd
if [ $? -ne 0 ]; then exit; fi

# Remove scripts so they won't get included with the submitted package.
cd $BIBLEDITIOS/ios
if [ $? -ne 0 ]; then exit; fi
rm build.sh
if [ $? -ne 0 ]; then exit; fi

# say Compile for iOS is ready

# Build the app.
cd $BIBLEDITIOS/ios
if [ $? -ne 0 ]; then exit; fi
xcodebuild
if [ $? -ne 0 ]; then exit; fi

echo To graphically build the app for iOS open the project in Xcode:
echo open $BIBLEDITIOS/ios/Bibledit.xcodeproj
echo Then build it from within Xcode
