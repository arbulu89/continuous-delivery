#!/bin/sh
set -e

function clean(){
  rm -rf /tmp/$OBS_PROJECT
  rm -rf /tmp/$PACKAGE.tar.gz
}

DEST_FOLDER=/tmp/osc_project
OSCRC_FILE=${OSCRC_FILE:=/root/.config/osc/oscrc}
FOLDER=${FOLDER:=.}
PACKAGE=$PACKAGE_NAME-`cat $FOLDER/${VERSION_FILE:=VERSION}`
OBS_PROJECT=$OBS_PROJECT/$PACKAGE_NAME
TARGET_PROJECT=${TARGET_PROJECT:=false}

sed -i "s/# user =/user = $OBS_USER/g" $OSCRC_FILE
sed -i "s/# pass =/pass = $OBS_PASS/g" $OSCRC_FILE

clean
mkdir /tmp/$PACKAGE
cp -R $FOLDER/* /tmp/$PACKAGE
tar -zcvf /tmp/$PACKAGE.tar.gz --exclude='.git' /tmp/$PACKAGE
osc checkout $OBS_PROJECT -o $DEST_FOLDER
cp /tmp/$PACKAGE.tar.gz $DEST_FOLDER
cp $FOLDER/$PACKAGE_NAME.spec $DEST_FOLDER
cp $FOLDER/$PACKAGE_NAME.changes $DEST_FOLDER

cd $DEST_FOLDER
#osc build
osc add *
osc commit -m "New development version of $PACKAGE released"

if [ "$TARGET_PROJECT" != false ]; then
  osc sr $OBS_PROJECT $TARGET_PROJECT
fi

rm $OSCRC_FILE
