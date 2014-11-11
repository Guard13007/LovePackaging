#!/bin/bash

# get config
source ./config.txt

# remove old versions of package?
if [ $removeOld = true ]; then
	rm -f $outputDir/$packageName*
fi

# move to source dir
originalDir=$(pwd)
cd $sourceDir

# build .love file
echo "Building $packageName (version $version)... (.love file)"
zip -r $outputDir/$packageName-$version.love ./*

# check if executables (their directories) exist, if not, download them
if [ ! -d $wind32Dir ]; then
	mkdir -p $wind32Dir
	echo "Downloading wind32src..."
	wget -nv -O $wind32Dir/love32.zip https://bitbucket.org/rude/love/downloads/love-0.9.1-win32.zip
	unzip $wind32Dir/love32.zip -d $wind32Dir
fi

if [ ! -d $win64Dir ]; then
	mkdir -p $win64Dir
	echo "Downloading win64src..."
	wget -nv -O $win64Dir/love64.zip https://bitbucket.org/rude/love/downloads/love-0.9.1-win64.zip
	unzip $win64Dir/love64.zip -d $win64Dir
fi

if [ ! -d $osx10Dir ]; then
	mkdir -p $osx10Dir
	echo "Downloading osx10src..."
	wget -nv -O $osx10Dir/loveOSX.zip https://bitbucket.org/rude/love/downloads/love-0.9.1-macosx-x64.zip
	unzip $osx10Dir/loveOSX.zip -d $osx10Dir
	#delete Mac crap
	rm -rf $osx10Dir/__MACOSX
	#the Info.plist is overwritten each time the app is built, so it is not fixed here.
fi

# build executables and zip files for them

echo "Building $packageName (version $version)... (win32 zip)"
cat $wind32Dir/love-0.9.1-win32/love.exe $outputDir/$packageName-$version.love > $wind32Dir/$packageName.exe
zip -r $outputDir/$packageName-$version_win32.zip $wind32Dir/$packageName.exe $wind32Dir/love-0.9.1-win32/*.dll $wind32Dir/love-0.9.1-win32/license.txt $includes

echo "Building $packageName (version $version)... (win64 zip)"
cat $win64Dir/love-0.9.1-win64/love.exe $outputDir/$packageName-$version.love > $win64Dir/$packageName.exe
zip -r $outputDir/$packageName-$version_win64.zip $win64Dir/$packageName.exe $win64Dir/love-0.9.1-win64/*.dll $win64Dir/love-0.9.1-win64/license.txt $includes


if [ $macInfoPlistFixed = true ]; then
	echo "Building $packageName (version $version)... (OS X zip)"
	if [ -f $osx10Dir ]; then
		rm -f $osx10Dir/love.app/Contents/Resources/$packageName.love
	fi
	cp $outputDir/$packageName-$version.love $osx10Dir/love.app/Contents/Resources/$packageName.love
	cp $originalDir/Info.plist $osx10Dir/love.app/Contents/Info.plist
	zip -r $outputDir/$packageName-$version_osx.zip $osx10Dir/love.app $includes
else
	echo "WARN: Mac packaging disabled."
fi

echo "Build complete. Unless there are errors above. Check your files."
