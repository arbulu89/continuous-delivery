#!/bin/sh
set -e
source $(dirname $0)/utils.sh

TMP_FOLDER=/tmp
DEST_FOLDER=/tmp/osc_project
OSCRC_FILE=${OSCRC_FILE:=/root/.config/osc/oscrc}
FOLDER=${FOLDER:=.}

# Mandatory parameters set using env varialbes
# OBS_USER, OBS user
# OBS_PASS, OBS user password
# OBS_PROJECT, OBS project where the package is stored
# PACKAGE_NAME, PACKAGE to submit in OBS project

function check_params {
  if [ -z $OBS_PROJECT -o -z $PACKAGE_NAME ]; then
    echo "OBS_PROJECT or PACKAGE_NAME not set..."
    return 1
  else
    return 0
  fi
}

check_user
if [ $? -ne 0 ]; then
  rm $OSCRC_FILE
  exit 1
fi

check_params
if [ $? -ne 0 ]; then
  rm $OSCRC_FILE
  exit 1
fi

OBS_PACKAGE=$OBS_PROJECT/$PACKAGE_NAME

# Checkout obs package
echo "Downloading $OBS_PACKAGE ..."
osc checkout $OBS_PACKAGE -o $DEST_FOLDER

if [ -e *.spec ]; then
  VERSION=$(grep -Po '^Version:\s*\K(.*)' *.spec)
  echo "Version found in local spec file: $VERSION"
else
  VERSION=$(grep -Po '^Version:\s*\K(.*)' $DEST_FOLDER/*.spec)
  echo "Version found in obs project spec file: $VERSION"
fi

PACKAGE=$PACKAGE_NAME-$VERSION
echo "Package name: $PACKAGE"

# Create tar file and copy to obs folder
TAR_NAME=${TAR_NAME:=$PACKAGE_NAME}
echo "Creating tar file: $TAR_NAME..."
TAR_NAME=$TAR_NAME-$VERSION
mkdir $TMP_FOLDER/$TAR_NAME
cp -R $FOLDER/* $TMP_FOLDER/$TAR_NAME
tar -zcvf $TMP_FOLDER/$TAR_NAME.tar.gz --exclude='.git' -C $TMP_FOLDER $TAR_NAME
cp $TMP_FOLDER/$TAR_NAME.tar.gz $DEST_FOLDER
echo "tar file created: $TMP_FOLDER/$TAR_NAME.tar.gz"

# Copy .spec file from git project if exists
if [ -e $FOLDER/$PACKAGE_NAME.spec ]; then
  echo "Spec file found"
  cp $FOLDER/$PACKAGE_NAME.spec $DEST_FOLDER
fi

# Copy .changes file from git project if exists
if [ -e $FOLDER/$PACKAGE_NAME.changes ]; then
  echo "Changes file found"
  cp $FOLDER/$PACKAGE_NAME.changes $DEST_FOLDER
fi

# Update project
cd $DEST_FOLDER
#osc build
osc add *
osc commit -m "New development version of $PACKAGE released"

rm $OSCRC_FILE
echo "Package correctly updated!"
