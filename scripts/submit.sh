#!/bin/bash
source $(dirname $0)/utils.sh

OSCRC_FILE=${OSCRC_FILE:=/root/.config/osc/oscrc}

# Mandatory parameters set using env varialbes
# OBS_USER, OBS user
# OBS_PASS, OBS user password
# OBS_PROJECT, OBS project where the package is stored
# PACKAGE_NAME, PACKAGE to submit in OBS project
# TARGET_PROJECT, target project to submit. If not set the job is skipped

function version_gt() {
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

function version_upgraded {
  current_version=$(osc cat $TARGET_PROJECT $PACKAGE_NAME $PACKAGE_NAME.spec | grep -Po '^Version:\s*\K(.*)')
  if [ $? -ne 0 ]; then
    echo "Package does not exist in $TARGET_PROJECT, Submitting first time"
    return 0
  fi
  echo "Current version of $PACKAGE_NAME in $TARGET_PROJECT: $current_version"

  new_version=$(osc cat $OBS_PROJECT $PACKAGE_NAME $PACKAGE_NAME.spec | grep -Po '^Version:\s*\K(.*)')
  echo "New version of $PACKAGE_NAME in $OBS_PROJECT: $new_version"
  if version_gt $new_version $current_version; then
    return 0
  else
    return 1
  fi
}

function changelog_changed {
  current_changelog=$(osc cat $TARGET_PROJECT $PACKAGE_NAME $PACKAGE_NAME.changes)
  if [ $? -ne 0 ]; then
    echo "Package does not exist in $TARGET_PROJECT, Submitting first time"
    return 0
  fi
  new_changelog=$(osc cat $OBS_PROJECT $PACKAGE_NAME $PACKAGE_NAME.changes)
  diff <( echo "$current_changelog" ) <( echo "$new_changelog" )
  if [ $? -ne 0 ]; then
    return 0
  else
    return 1
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

version_upgraded
if [ $? -ne 0 ]; then
  echo "Version of the package not upgraded. Skipping submit request"
  rm $OSCRC_FILE
  exit 0
fi

changelog_changed
if [ $? -ne 0 ]; then
  echo "Changelog not updated. Skipping submit request"
  rm $OSCRC_FILE
  exit 1
fi

echo "Creating submit request to $TARGET_PROJECT from $OBS_PROJECT/$PACKAGE_NAME"
osc sr -m "New version of $PACKAGE_NAME released" --yes $OBS_PROJECT $PACKAGE_NAME $TARGET_PROJECT

rm $OSCRC_FILE
echo "Package correctly submitted!"
