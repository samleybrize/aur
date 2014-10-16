#!/bin/bash

ARCH=$(uname -m)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# create/recreate build directory
if [ -d build ]; then
    rm -rf build
fi

mkdir build

# download files
cd build

echo "Downloading dartium-linux-ia32-release.zip..."
curl -o dartium-linux-ia32-release.zip http://storage.googleapis.com/dart-archive/channels/stable/release/latest/dartium/dartium-linux-ia32-release.zip
echo ""
echo "Downloading dartium-linux-x64-release.zip..."
curl -o dartium-linux-x64-release.zip http://storage.googleapis.com/dart-archive/channels/stable/release/latest/dartium/dartium-linux-x64-release.zip

echo ""
echo "Extracting dartium-linux-ia32-release.zip..."
unzip -q dartium-linux-ia32-release.zip
echo "Extracting dartium-linux-x64-release.zip..."
unzip -q dartium-linux-x64-release.zip

# retrieve dartium version
dir32=$(ls -d dartium-lucid32*)
dir64=$(ls -d dartium-lucid64*)

if [[ ${ARCH} = x86_64 ]]; then
    version=$(./$dir64/chrome -version)
else
    version=$(./$dir32/chrome -version)
fi

version=$(echo "$version" | sed 's/.* \([0-9.]\{5,\}\).*/\1/')

# calculate checksums
sum32=$(md5sum dartium-linux-ia32-release.zip)
sum32=${sum32:0:32}
sum64=$(md5sum dartium-linux-x64-release.zip)
sum64=${sum64:0:32}
sumdesktop=$(md5sum ../dartium.desktop)
sumdesktop=${sumdesktop:0:32}

# copy package files
mkdir pkg
cd pkg
cp ../../PKGBUILD .
cp ../../dartium.desktop .

# insert computed values
sed -i "s/%pkgver%/${version}/g" PKGBUILD
sed -i "s/%dir32%/${dir32}/g" PKGBUILD
sed -i "s/%dir64%/${dir64}/g" PKGBUILD
sed -i "s/%sum32%/${sum32}/g" PKGBUILD
sed -i "s/%sum64%/${sum64}/g" PKGBUILD
sed -i "s/%sumdesktop%/${sumdesktop}/g" PKGBUILD

# make aur package
echo ""
echo "Building AUR package..."
mkaurball .

echo ""
echo "Generated $DIR/build/pkg/$(ls dartium-*.src.tar.gz)"

