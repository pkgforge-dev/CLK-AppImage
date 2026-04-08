#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	kvantum        \
    lxqt-qtplugin   \
	qt6-multimedia \
	qt6ct

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
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | awk -F'"' '/"tag_name":/ {print $4}')"
	#VERSION=2026-04-07
	git clone --branch "$VERSION" --single-branch "$REPO" ./CLK
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./CLK/OSBindings/Qt
qmake6
make -j$(nproc)
mv -v clksignal ../../../AppDir/bin
