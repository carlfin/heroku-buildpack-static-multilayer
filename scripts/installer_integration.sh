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
. scripts/funcs.sh

# enable gsutil command (see funcs.sh)
install_and_activate_gcloud

# make storage url available from heroku env
STORAGE_URL=$(cat "$ENV_DIR/STORAGE_URL")

# we split the storage url because it has semantics inside it
INFO=( $(split_storage_url) )
GS=${INFO[0]}
# we don't use branch amd app name here… ( INFO[2] INFO[1] )

TOPLEVEL_APP=$(scripts/yield_toplevel_app.py)

DOCROOT="$BUILD_DIR/www"
mkdir $DOCROOT

# setup static.json template (no folders linked yet)
OUTPUT_STATIC="$BUILD_DIR/static.json"
cp "$ENV_DIR/STATIC_JSON" "$OUTPUT_STATIC"

gsutil cp "$GS/$TOPLEVEL_APP/staging.tar.gz" "staging.tar.gz"

tar -C $DOCROOT -xzf "staging.tar.gz"
rm "staging.tar.gz"

# the refresh of static.json must not have a prefix path
scripts/static_json_generator.py "" "$OUTPUT_STATIC"

# now we install the nested apps

# skip these tar url suffixes
SKIP_TAR_URLS="/(develop|staging|master)\.tar\.gz$"

for APP in $(scripts/yield_nested_apps.py); do
    for TAR_URL in $(gsutil ls "$GS/$APP/*.tar.gz"); do
        # skip some branches
        [[ $TAR_URL =~ $SKIP_TAR_URLS ]] && echo "skipping install: $TAR_URL" && continue
        # extract branch name
        BRANCH=$(echo $TAR_URL | sed 's/.*\(\/\)\(.*\)$/\2/' | sed 's/\.tar\.gz$//')
        APP_FOLDER=$(scripts/yield_folder_name.py "$APP")
        # copy the file to the localfilename from google cloud storage remove location
        gsutil cp $TAR_URL "nested_branch.tar.gz"
        # where to unpack the tar and setup this dir
        TAR_UNPACK_DIR="$DOCROOT/$APP_FOLDER/$BRANCH"
        mkdir -p $TAR_UNPACK_DIR
        # now unpack and clean
        tar -C $TAR_UNPACK_DIR -xzf "nested_branch.tar.gz"
        rm "nested_branch.tar.gz"
        # also add routing for this folder now
        scripts/static_json_generator.py "$APP_FOLDER/$BRANCH" "$OUTPUT_STATIC"
        scripts/debug_json_generator.py "$DOCROOT" "$APP" "$BRANCH"

        #if [ -f $DOCROOT/index.html ]; then
        #    sed -i "s/<body>/<body><a href=\"\/$APP_FOLDER\/$BRANCH\">$APP_FOLDER\/$BRANCH<\/a><\/br>/" $DOCROOT/index.html
        #fi
    done
done

uninstall_gcloud
