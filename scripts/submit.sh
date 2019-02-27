#!/bin/sh
set -e
source $(dirname $0)/utils.sh

OSCRC_FILE=${OSCRC_FILE:=/root/.config/osc/oscrc}

# Mandatory parameters set using env varialbes
# OBS_USER, OBS user
# OBS_PASS, OBS user password
# OBS_PROJECT, OBS project where the package is stored
# PACKAGE_NAME, PACKAGE to submit in OBS project
# TARGET_PROJECT, target project to submit. If not set the job is skipped

function check_params {
  if [ -z $OBS_PROJECT -o -z $PACKAGE_NAME ]; then
    echo "OBS_PROJECT, PACKAGE_NAME or TARGET_PROJECT not set..."
    return 1
  else
    return 0
  fi
}

if [ -z $TARGET_PROJECT ]; then
  echo "TARGET_PROJECT not set. Skipping package submission."
  exit 0
fi

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

echo "Creating submit request to $TARGET_PROJECT from $OBS_PROJECT/$PACKAGE_NAME"
osc sr -m "New development version of $PACKAGE_NAME released" $OBS_PROJECT $PACKAGE_NAME $TARGET_PROJECT

rm $OSCRC_FILE
echo "Package correctly submitted!"
