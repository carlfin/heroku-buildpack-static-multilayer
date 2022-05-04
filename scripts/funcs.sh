# helper functions rely on environment infos:
# GCS_KEY_JSON   is a json formatted key from google cloud iam service accounts
# GCS_PROJECT  is the google cloud project working with
#                also GCS_KEY_JSON should be qualified to access the storage there

function install_and_activate_gcloud {
    CLOUD_SDK_VERSION="321.0.0"
    CLOUD_SDK_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$CLOUD_SDK_VERSION-linux-x86_64.tar.gz"

    # download install & auth google cloud sdk

    curl -s "$CLOUD_SDK_URL" | tar xz

    SDK_LOCATION="$(pwd)/google-cloud-sdk"

    export PATH=$PATH:$SDK_LOCATION/bin/

    gcloud auth activate-service-account --project="$(cat $ENV_DIR/GCS_PROJECT)" --key-file="$ENV_DIR/GCS_KEY_JSON"
}

function uninstall_gcloud {
    rm -rf "$(pwd)/google-cloud-sdk"
}
