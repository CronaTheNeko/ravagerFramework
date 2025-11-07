#!/bin/bash

# Archive name
name_p1="../builds/ravagerFramework"
name_core_p1="${name_p1}Core"
name_p2=".zip"
# Check for argument
if [[ -z $1 ]]; then
	>&2 echo "Version (such as V123) required!"
	exit 1
fi
# Put together the file name
filename="${name_p1}-$1${name_p2}"
filename_core="${name_core_p1}-$1${name_p2}"
# CD to script's directory to easily work with zip
cd $(dirname $0)
# Remove old archives if they exist
[ -e "${filename}" ] && rm "${filename}"
[ -e "${filename_core}" ] && rm "${filename_core}"
# Zip full version of mod
zip -qr "${filename}" * -x "*.sh" -x "Enemies/outfit-notes/*" -x "*.py"
# Zip core version of mod
zip -qr "${filename_core}" * -x "Enemies/*" -x "*.sh" -x "*.py"
