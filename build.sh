#!/usr/bin/env bash
set -e

error() {
	echo "Error: $1" >/dev/stderr
	exit 1
}

# Options
version=$(grep MARKETING_VERSION WattSec.xcodeproj/project.pbxproj 2>/dev/null | head -n1 | awk '{print $3}' | tr -d ';')
[ -z $version ] && error "Unable to find version"
dest_dir=dist
create_dmg=false
sign_app=false
version_provided=false

# Signing info
developer_id=
bundle_identifier=$(grep PRODUCT_BUNDLE_IDENTIFIER WattSec.xcodeproj/project.pbxproj 2>/dev/null | head -n 1 | awk '{print $3}' | tr -d ';')
keychain_profile=
entitlements_file=WattSec/WattSec.entitlements

usage() {
	cat << EOF
Usage: $0 [OPTIONS]
Build WattSec.app and optionally package it in a DMG file

Options:
  -h, --help             Show help and exit
  -v, --version VERSION  Set the version (default: $version)
  -d, --create-dmg       Package the app in a DMG file
  -s, --sign ID          Code sign the app with a developer ID
  -k, --keychain PROFILE Keychain profile for notarization (required with --sign)
EOF
	exit $1
}

while [ $# -gt 0 ]; do
	case $1 in
		-h|--help)
			usage 0
			;;
		-v|--version)
			if [ -z $2 ]; then
				error "--version requires an argument"
			fi
			version=$2
			version_provided=true
			shift 2
			;;
		-d|--create-dmg)
			create_dmg=true
			shift
			;;
		-s|--sign)
			if [ -z $2 ]; then
				error "--sign requires a developer ID"
			fi
			sign_app=true
			developer_id=$2
			shift 2
			;;
		-k|--keychain)
			if [ -z $2 ]; then
				error "--keychain requires a profile name"
			fi
			keychain_profile=$2
			shift 2
			;;
		*)
			echo "Unknown option: $1"
			usage 1
			;;
	esac
done

echo "Building WattSec v$version..."

for cmd in xcodebuild; do
	if ! command -v $cmd >/dev/null; then
		error "$cmd not found"
	fi
done

if [ $create_dmg = true ]; then
	for cmd in iconutil create-dmg; do
		if ! command -v $cmd >/dev/null; then
			error "$cmd not found (required to create DMG)"
		fi
	done
fi

if [ $sign_app = true ]; then
	for cmd in codesign xcrun; do
		if ! command -v $cmd >/dev/null; then
			error "$cmd not found (required to sign)"
		fi
	done
fi

if [ -d $dest_dir ]; then
	read -p "Destination directory \"$dest_dir\" already exists. Confirm deletion? (Y/n): " response
	case $response in
		[Nn]* )
			echo "Exiting"; exit 1 ;;
		* )
			rm -rf $dest_dir ;;
	esac
else
	sleep 0.5 # Give time to show version number being built
fi

if cc --version | grep ^InstalledDir | grep -q CommandLineTools; then
	echo "Incorrect active directory directory, try running 'sudo xcode-select -s /Applications/Xcode.app'"
	exit 1
fi

xcodebuild \
	-scheme WattSec \
	-configuration Release \
	-sdk macosx \
	CONFIGURATION_BUILD_DIR=$dest_dir \
	CURRENT_PROJECT_VERSION=$version \
	MARKETING_VERSION=$version \
	clean build

echo "Cleaning up build files..."
find $dest_dir -maxdepth 1 ! -name WattSec.app ! -path $dest_dir -exec rm -rf {} +

app_path="$dest_dir/WattSec.app"
if [ $sign_app = true ]; then
	echo "Code signing WattSec.app..."
	[ ! -f $entitlements_file ] && error "Entitlements file not found: $entitlements_file"
	[ -z $bundle_identifier ] && error "Bundle identifier not found"
	codesign -s $developer_id -f --timestamp -o runtime -i $bundle_identifier --entitlements $entitlements_file $app_path
fi

if [ $create_dmg = false ]; then
	echo "Build v$version complete: $dest_dir/WattSec.app"
	exit 0
fi

pushd $dest_dir >/dev/null

echo "Converting app icons..."
cp -r ../WattSec/Assets.xcassets/AppIcon.appiconset/ AppIcon.iconset
iconutil -c icns AppIcon.iconset

echo "Creating DMG..."
mkdir tmp_dmg
mv WattSec.app tmp_dmg/
create-dmg \
	--volname WattSec \
	--volicon AppIcon.icns \
	--window-pos 200 120 \
	--window-size 800 400 \
	--icon-size 100 \
	--icon WattSec.app 200 190 \
	--hide-extension WattSec.app \
	--app-drop-link 600 185 \
	WattSec.dmg \
	tmp_dmg/
rm -rf tmp_dmg AppIcon.iconset AppIcon.icns

popd >/dev/null

if [ $sign_app = true ]; then
	echo "Notarizing WattSec.dmg..."
	xcrun notarytool submit $dest_dir/WattSec.dmg --keychain-profile "$keychain_profile" --wait
	echo "Stapling ticket to WattSec.dmg..."
	xcrun stapler staple $dest_dir/WattSec.dmg
fi

echo "Build v$version complete: $dest_dir/WattSec.dmg"