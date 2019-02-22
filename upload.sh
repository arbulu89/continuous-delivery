#!/bin/sh
set -e

TMP_FOLDER=/tmp
DEST_FOLDER=/tmp/osc_project
OSCRC_FILE=${OSCRC_FILE:=/root/.config/osc/oscrc}
FOLDER=${FOLDER:=.}
OBS_PROJECT=$OBS_PROJECT/$PACKAGE_NAME
TARGET_PROJECT=${TARGET_PROJECT:=false}

sed -i "s/# user =/user = $OBS_USER/g" $OSCRC_FILE
sed -i "s/# pass =/pass = $OBS_PASS/g" $OSCRC_FILE

# Checkout obs package
echo "Downloading $OBS_PROJECT ..."
osc checkout $OBS_PROJECT -o $DEST_FOLDER

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
echo "Creating tar file..."
mkdir $TMP_FOLDER/$PACKAGE
cp -R $FOLDER/* $TMP_FOLDER/$PACKAGE
tar -zcvf $TMP_FOLDER/$PACKAGE.tar.gz --exclude='.git' -C $TMP_FOLDER $PACKAGE
cp $TMP_FOLDER/$PACKAGE.tar.gz $DEST_FOLDER
echo "tar file created: $TMP_FOLDER/$PACKAGE.tar.gz"

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

if [ "$TARGET_PROJECT" != false ]; then
  echo "Submit request created to $TARGET_PROJECT"
  osc sr $OBS_PROJECT $TARGET_PROJECT
fi

rm $OSCRC_FILE
echo "Package correctly updated!"
