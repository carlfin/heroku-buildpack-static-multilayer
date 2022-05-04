#!/bin/bash
#
# script to install prebuilt webpack projects on a per folder basis into heroku app environment
#
# support multiple bundles on one heroku app url are generated from folder names
# uses the google cloud sdk (see buildpacks required) to make use of the gcloud auth/gsutil commands
#
# passed variables from outside context (bin/compile):
# BUILD_DIR
# CACHE_DIR
# ENV_DIR
#
# heroku env requirements:
# STORAGE_URL    is an url of the form 'gs://<bucketname>/<foldername>' where tarballs are located
# GCS_KEY_JSON   is a json formatted key from google cloud iam service accounts
# GCS_PROJECT  is the google cloud project working with
#                also GCS_KEY_JSON should be qualified to access the storage there
# STATIC_JSON    json formatted template for the heroku-buildpack-static support

# disable history expansion to safe write '!'
set +H

# source helper functions
. funcs.sh

# enable gsutil command (see funcs.sh)
install_and_activate_gcloud()

# setup static.json template (no folders linked yet)
OUTPUT_STATIC="$BUILD_DIR/static.json"
cp "$ENV_DIR/STATIC_JSON" "$OUTPUT_STATIC"

# install all tarballs from google cloud storage
# inside the loop it downloads and unpacks to www/<branchfolder>/
DOCROOT="$BUILD_DIR/www"
mkdir $DOCROOT

TOPLEVEL_INDEX="$DOCROOT/index.html"

# make storage url available from heroku env
STORAGE_URL=$(cat "$ENV_DIR/STORAGE_URL")

# global index page to all installed branches (template)
echo "<!DOCTYPE html><html><head><title>
  Carl Integration environment : $(echo $STORAGE_URL | grep -Eo '[a-z]+$')
  </title></head>" > $TOPLEVEL_INDEX
echo "<body style='text-align: center;'><img
  src='https://$LOGO_URL'
  style='width: 200px;'/><table>" >> $TOPLEVEL_INDEX

# skip these tar url suffixes
SKIP_TAR_URLS="/(develop|staging|master)\.tar\.gz$"

for TAR_URL in $(gsutil ls "$STORAGE_URL/*.tar.gz"); do
  # skip some branches
  [[ $TAR_URL =~ $SKIP_TAR_URLS ]] && echo "skipping install: $TAR_URL" && continue
  # local filename for tarfile
  TAR_LOCAL=$(echo $TAR_URL | rev | cut -d "/" -f1 | rev)
  # dirname from tarfile name (basically branch name)
  TAR_TO_DIR=$(echo $TAR_LOCAL | rev | cut -b 8- | rev)
  # copy the file to the localfilename from google cloud storage remove location
  gsutil cp $TAR_URL $TAR_LOCAL
  # where to unpack the tar and setup this dir
  TAR_UNPACK_DIR="$DOCROOT/$TAR_TO_DIR"
  mkdir $TAR_UNPACK_DIR
  # now unpack
  tar -C $TAR_UNPACK_DIR -xzf $TAR_LOCAL
  # also add routing for this folder now
  $(pwd)/static_json_generator.py "$TAR_TO_DIR" "$OUTPUT_STATIC"
  # add link to global template
  if [ -f "$TAR_UNPACK_DIR/manifest.txt" ]; then
    MANIFEST=$(cat "$TAR_UNPACK_DIR/manifest.txt" | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/\&lt;br\/\&gt;/<br\/>/g')
  fi
  echo "<tr><td style='padding: 30px;'><a href='$TAR_TO_DIR'>$TAR_TO_DIR</a></td><td>$MANIFEST</td></tr>" >> www/index.html
done

# write end of global template
echo "</table></body></html>" >> $TOPLEVEL_INDEX

# cleanup
rm -rf *.tar.gz
uninstall_gcloud()
