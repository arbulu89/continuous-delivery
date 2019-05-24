#!/bin/bash

function check_user {
  if [ -z $OBS_USER -o -z $OBS_PASS ]; then
    echo "OBS_USER or OBS_PASS not set..."
    return 1
  else
    sed -i "s/# user =/user = $OBS_USER/g" $OSCRC_FILE
    sed -i "s/# pass =/pass = $OBS_PASS/g" $OSCRC_FILE
    return 0
  fi
}

function check_params {
  if [ -z $OBS_PROJECT -o -z $PACKAGE_NAME ]; then
    echo "OBS_PROJECT or PACKAGE_NAME not set..."
    return 1
  else
    return 0
  fi
}
