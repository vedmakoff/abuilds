#!/bin/sh
# Checkout and patch aufs

# mmap: Regarding to aufs readme, it is optional,
#       but it won't compile if you miss it.
# loopback: Seems to be deprecated
AUFS_PATCHES=(kbuild base mmap loopback standalone)
AUFS_TREE=(Documentation fs include)

aufs_checkout() {
  local AUFS_REPO=$1 AUBRANCH=$2 AUFS_DIR=$3
  local AUFS_VER=${AUBRANCH%%.*}
  echo "Cloning AUFS, kernel branch: ${AUBRANCH}"
  set -x

  # Checking out AUFS patch. Note that we do it outside kernel tree.
  # Add AUBRANCH to it if you want to check out specific branch
  # instead of master tree
  git clone git://github.com/sfjro/${AUFS_REPO} ${AUFS_DIR}
  ( cd ${AUFS_DIR}; git checkout origin/aufs${AUBRANCH} )

  echo "Remove Kbuild, as it should never be copied (see aufs readme)"
  rm ${AUFS_DIR}/include/uapi/linux/Kbuild

  # Copy aufs tree
  for DIR in "${AUFS_TREE[@]}"; do
    cp -rv ${AUFS_DIR}/${DIR} .
  done

  # Applying AUFS patches
  for PATCH in "${AUFS_PATCHES[@]}"; do
    cat ${AUFS_DIR}/aufs${AUFS_VER}-${PATCH}.patch | \
      patch -p1 --verbose
  done

  # Clean up
  rm -rf ${AUFS_DIR}
}

aufs_git() {
  local KERNEL_BASE=$1 KERNEL_GROUP=$2
  local AUFS_REPO="aufs${KERNEL_GROUP}-standalone"
  local AUFS_DIR="../${AUFS_REPO}"
  local AUFS_BRANCH=${AUBRANCH:-$KERNEL_BASE}
  aufs_checkout $AUFS_REPO $AUFS_BRANCH $AUFS_DIR
}

