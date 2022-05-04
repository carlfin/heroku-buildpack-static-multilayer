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
# STATIC_JSON    json formatted template for the heroku-buildpack-static support

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

# make storage url available from heroku env
STORAGE_URL=$(cat "$ENV_DIR/STORAGE_URL")

# provide variables need on script
# -> static_json_generator.py
export TEASER_HOST=$(cat "$ENV_DIR/TEASER_HOST")

TAR_LOCAL=$(echo $STORAGE_URL | rev | cut -d "/" -f1 | rev)

gsutil cp $STORAGE_URL $TAR_LOCAL

tar -C $DOCROOT -xzf $TAR_LOCAL

# the refresh of static.json must not have a prefix path
$(pwd)/scripts/static_json_generator.py "" "$OUTPUT_STATIC"

# cleanup
rm -rf *.tar.gz
uninstall_gcloud()
