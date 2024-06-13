#!/bin/bash

DEV_API_URL="https://dev-api.smartbuddy.toyota/api/mobile"
STG_API_URL="https://stg-api.smartbuddy.toyota/api/mobile"

TEMP_FOLDER=$(mktemp -d)
mkdir -p "$TEMP_FOLDER"

ENV_FILE=".env"

# Check if .env file exists
# TODO: Find a way to build apk without .env file
if [ -f "$ENV_FILE" ]; then
    # Cache the existing .env file
    cp "$ENV_FILE" "$TEMP_FOLDER/$ENV_FILE"
fi

# Generate a new .env file
echo "API_URL=$DEV_API_URL" > "$ENV_FILE"

flutter build apk

COMMIT_HASH=$(git rev-parse --short HEAD)

mv "build/app/outputs/flutter-apk/app-release.apk" "$TEMP_FOLDER/app-release-dev-$COMMIT_HASH.apk"

# Restore previous .env file
# TODO: Find a way to build apk without .env file
if [ -f "$TEMP_FOLDER/$ENV_FILE" ]; then
    cp "$TEMP_FOLDER/$ENV_FILE" "$ENV_FILE"
fi

# Set API_URL to STG_API_URL
echo "API_URL=$STG_API_URL" > "$ENV_FILE"

flutter build apk

mv "build/app/outputs/flutter-apk/app-release.apk" "$TEMP_FOLDER/app-release-stg-$COMMIT_HASH.apk"

# Restore previous .env file
if [ -f "$TEMP_FOLDER/$ENV_FILE" ]; then
    cp "$TEMP_FOLDER/$ENV_FILE" "$ENV_FILE"
fi

echo "APKs built and moved to $TEMP_FOLDER"