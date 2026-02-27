#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    qt6-base       \
    qt5-multimedia

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Building CLK..."
echo "---------------------------------------------------------------"
REPO="https://github.com/TomHarte/CLK"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of CLK..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone "$REPO" ./CLK
else
	echo "Making stable build of CLK..."
	VERSION=$(git ls-remote --tags --sort="refname" "$REPO" | grep "\^{}$" | tail -n1 | awk '{print $1}')
	git clone --branch "$VERSION" --single-branch "$REPO" ./CLK
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./CLK/OSBindings/Qt
qmake
make
mv -v clksignal ../../../AppDir/bin
