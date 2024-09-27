#!/bin/bash

# Archive name
file="../00-ravagerFramework.zip"
# CD to script's directory to easily work with zip
cd $(dirname $0)
# Remove old archive
[ -f "${file}" ] && rm "${file}"
# Zip mod to ravagerFramework.zip in the parent directory
zip -qr "${file}" * -x "*.sh"
