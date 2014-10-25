#!/bin/sh
echo "Cloning AUFS, kernel branch: ${AUBRANCH}"
git clone git://git.code.sf.net/p/aufs/aufs3-standalone \
	aufs3-standalone
cd aufs3-standalone

git checkout origin/aufs${AUBRANCH}

