#!/bin/bash

function check_user {
  if [ -z $OBS_USER -o -z $OBS_PASS ]; then
    echo "OBS_USER or OBS_PASS not set..."
    return 1
  else
    sed -i "s/# user =/user = $OBS_USER/g" $OSCRC_FILE
    sed -i "s/# pass =/pass = $OBS_PASS/g" $OSCRC_FILE    
  fi

  # Check if the OSC_API_URL is set
  if [ -z $OSC_API_URL ]; then    
    return 0
  else
    sed -i "s|https://api.opensuse.org|$OSC_API_URL|g" $OSCRC_FILE
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
