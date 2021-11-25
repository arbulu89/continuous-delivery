#!/bin/bash
set -e
source $(dirname $0)/utils.sh

TMP_FOLDER=/tmp
DEST_FOLDER=/tmp/osc_project
OSCRC_FILE=${OSCRC_FILE:=/root/.config/osc/oscrc}
FOLDER=${FOLDER:=.}
CHANGESAUTHOR=${CHANGESAUTHOR:=$(git -C $FOLDER log -1 --format='%ae')}

# Get spec file
SPEC_FILE=$(find $FOLDER -name "$PACKAGE_NAME.spec" -o -name "$PACKAGE_NAME.spec.in")
SPEC_FILE=${SPEC_FILE:='not found'}

# Mandatory parameters set using env varialbes
# OBS_USER, OBS user
# OBS_PASS, OBS user password
# OBS_PROJECT, OBS project where the package is stored
# PACKAGE_NAME, PACKAGE to submit in OBS project

function update_obs_service {

  cd $DEST_FOLDER

  echo "Removing old tarball: $tarball ..."
  osc rm -f ./*.tar.*

  echo "Updating the package using obs service..."
  # Workaround because:
  # https://github.com/openSUSE/obs-service-tar_scm/issues/296
  VC_MAILADDR="$CHANGESAUTHOR" osc service dr
}

function create_tarball {
  # Remove old tarball
  rm -f $DEST_FOLDER/*.tar.*
  # Create tar file and copy to obs folder
  TAR_NAME=${TAR_NAME:=$PACKAGE_NAME}
  echo "Creating tar file: $TAR_NAME..."
  TAR_NAME=$TAR_NAME-$VERSION
  mkdir $TMP_FOLDER/$TAR_NAME
  cp -R $FOLDER/* $TMP_FOLDER/$TAR_NAME
  tar -zcvf $TMP_FOLDER/$TAR_NAME.tar.gz --exclude='.git' -C $TMP_FOLDER $TAR_NAME
  cp $TMP_FOLDER/$TAR_NAME.tar.gz $DEST_FOLDER
  echo "tar file created: $DEST_FOLDER/$TAR_NAME.tar.gz"
}

function copy_spec_from_git {
  # Copy .spec file from git project if exists
  if [ -e $SPEC_FILE ]; then
    echo "Spec file found"
    cp $SPEC_FILE $DEST_FOLDER/$PACKAGE_NAME.spec
  fi
}

function copy_changes_from_git {
  # Copy .changes file from git project if exists
  if [ -e $FOLDER/$PACKAGE_NAME.changes ]; then
    echo "Changes file found"
    cp $FOLDER/$PACKAGE_NAME.changes $DEST_FOLDER
  fi
}

function copy_service_from_git {
  # Copy _service file from git project if exists
  if [ -e _service ]; then
    echo "_service file found"
    cp $FOLDER/_service $DEST_FOLDER
  fi
}

function copy_servicedata_from_git {
  # Copy _servicedata file from git project if exists
  if [ -e _servicedata ]; then
    echo "_servicedata file found"
    cp $FOLDER/_servicedata $DEST_FOLDER
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

if [ -e $SPEC_FILE ]; then
  VERSION=$(grep -Po '^Version:\s*\K(.*)' $SPEC_FILE)
  echo "Version found in local spec file: $VERSION"
else
  VERSION=$(grep -Po '^Version:\s*\K(.*)' $DEST_FOLDER/$PACKAGE_NAME.spec)
  echo "Version found in obs project spec file: $VERSION"
fi

if [ -e "$DEST_FOLDER/_service" ] || [ -e "$FOLDER/_service" ]; then
  echo "_service file identified. Updating via service..."
  # Copy the .spec file in case it is maintained on git.
  # Don't copy the changes file as it could overwrite the
  # entry created by obs services.
  copy_spec_from_git
  copy_changes_from_git
  copy_service_from_git
  copy_servicedata_from_git
  update_obs_service
  VERSION=$(grep -Po '^Version:\s*\K(.*)' $PACKAGE_NAME.spec)
  echo "Version updated after _service execution: $VERSION"
else
  create_tarball
  copy_spec_from_git
  copy_changes_from_git
fi

PACKAGE=$PACKAGE_NAME-$VERSION
echo "Package name: $PACKAGE"

# Update project
cd $DEST_FOLDER
osc ar
osc commit -m "New development version of $PACKAGE released"

rm $OSCRC_FILE
echo "Package correctly updated!"
