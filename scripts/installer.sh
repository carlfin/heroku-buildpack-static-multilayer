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
# STORAGE_URL is an url of the form 'gs://<bucketname>/<app_name>/<branch_name>'
#             where tarballs are located (suffixed with '.tar.gz')
# STATIC_JSON json formatted template for the heroku-buildpack-static support

# source helper functions
. scripts/funcs.sh

# enable gsutil command (see funcs.sh)
install_and_activate_gcloud

# make storage url available from heroku env
STORAGE_URL=$(cat "$ENV_DIR/STORAGE_URL")

# we split the storage url because it has semantics inside it
INFO=( $(split_storage_url) )
GS=${INFO[0]}
BRANCH=${INFO[2]}
# we don't use app name here… ( INFO[1] )

TOPLEVEL_APP=$(scripts/yield_toplevel_app.py)

# setup static.json template (no folders linked yet)
OUTPUT_STATIC="$BUILD_DIR/static.json"
cp "$ENV_DIR/STATIC_JSON" "$OUTPUT_STATIC"

# install all tarballs from google cloud storage
# inside the loop it downloads and unpacks to www/<branchfolder>/
DOCROOT="$BUILD_DIR/www"
mkdir $DOCROOT

gsutil cp "$GS/$TOPLEVEL_APP/$BRANCH.tar.gz" "toplevel_app.tar.gz"

tar -C $DOCROOT -xzf "toplevel_app.tar.gz"

rm "toplevel_app.tar.gz"

# install each nested app from here (branch is fixed!)
for APP in $(scripts/yield_nested_apps.py); do
    APP_FOLDER=$(scripts/yield_folder_name.py "$APP")
    # set exact download location
    TAR_URL="$GS/$APP/$BRANCH.tar.gz"
    # copy the file to the localfilename from google cloud storage remote location
    gsutil cp $TAR_URL "nested.tar.gz"
    # where to unpack the tar and setup this dir
    TAR_UNPACK_DIR="$DOCROOT/$APP_FOLDER"
    mkdir -p $TAR_UNPACK_DIR
    # now unpack and clean
    tar -C $TAR_UNPACK_DIR -xzf "nested.tar.gz"
    rm "nested.tar.gz"
    # also add routing for this folder now
    scripts/static_json_generator.py "$APP_FOLDER" "$OUTPUT_STATIC"
done

# top level final statement to insert statement as last key on json
scripts/static_json_generator.py "" "$OUTPUT_STATIC"

# cleanup
uninstall_gcloud
