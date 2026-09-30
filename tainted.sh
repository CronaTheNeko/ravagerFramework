#!/bin/bash
file="00-ravagerFramework-tainted.zip"
cd $(dirname $0)/..
[ -f "${file}" ] && rm "${file}"
zip -qr "${file}" ravagerFramework/* -x "*.sh" -x "ravagerFramework/Enemies/outfit-notes/*" -x "*.py"
