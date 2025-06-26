#!/bin/bash

set -e
set -o pipefail

SUPERBLOCKS_CLI_VERSION="${SUPERBLOCKS_CLI_VERSION:-^1.14.0}"

SUPERBLOCKS_COMMIT_SHA="${SUPERBLOCKS_COMMIT_SHA:-HEAD}"
SUPERBLOCKS_DOMAIN="${SUPERBLOCKS_DOMAIN:-app.superblocks.com}"
SUPERBLOCKS_PATH="${SUPERBLOCKS_PATH:-.}"

SUPERBLOCKS_CONFIG_RELATIVE_PATH=".superblocks/superblocks.json"

# Ensure that a Superblocks token is provided
if [ -z "$SUPERBLOCKS_TOKEN" ]; then
  echo "The 'SUPERBLOCKS_TOKEN' environment variable is unset or empty. Exiting..."
  exit 1
fi

if [ -z "$REPO_DIR" ]; then
  REPO_DIR="$(pwd)"
else
  cd "$REPO_DIR"
fi

git config --global --add safe.directory "$REPO_DIR"

# Get the list of changed files in the last commit
changed_files=$(git diff "${SUPERBLOCKS_COMMIT_SHA}"^ --name-only -- "$SUPERBLOCKS_PATH")

# Change the working directory to the Superblocks path
pushd "$REPO_DIR/$SUPERBLOCKS_PATH"

if [ -n "$changed_files" ]; then
    # Install Superblocks CLI
    npm install -g @superblocksteam/cli@"${SUPERBLOCKS_CLI_VERSION}"

    superblocks --version

    # Login to Superblocks
    printf "\nLogging in to Superblocks...\n"
    superblocks config set domain "$SUPERBLOCKS_DOMAIN"
    superblocks login -t "$SUPERBLOCKS_TOKEN"
else
    echo "No files changed since the last commit. Skipping deploy..."
    exit 0
fi

# Function to push a resource to Superblocks if it has changed
deploy_resource() {
    local location="$1"

    # Escape any special characters in the resource subdir
    escaped_location="${location%%/*}/$(printf '%s\n' "${location#*/}" | sed 's/[][\\^$.|?*+(){}/]/\\&/g')"

    # Deploy only if there are changes to one or more of the following files/folders under the resource location:
    #   application.yaml
    #   page.yaml
    #   pages/*
    #   apis/*
    #   api.yaml
    #   *.js
    #   *.py
    # This specificity ensures that we avoid deploying when only the components subdir has changes.
    if echo "$changed_files" | grep -qP "${escaped_location}/((application|page|api).yaml|.*\.js|.*\.py|apis/|pages/)" ; then
        printf "\nChange detected. Deploying...\n"
        if [ -n "$SUPERBLOCKS_COMMIT_SHA" ] && [ "$SUPERBLOCKS_COMMIT_SHA" != "HEAD" ]; then
            printf "\nDeploying with deploy command: superblocks deploy $location --commit-id $SUPERBLOCKS_COMMIT_SHA\n"
            superblocks deploy "$location" --commit-id "$SUPERBLOCKS_COMMIT_SHA"
        else
            printf "\nDeploying with deploy command: superblocks deploy $location\n"
            superblocks deploy "$location"
        fi
    else
        printf "\nNo change detected. Skipping deploy...\n"
    fi
}

# Check if any deploy-compatible resources have changed
jq -r '.resources[] | .location' "$SUPERBLOCKS_CONFIG_RELATIVE_PATH" | while read -r location; do
    printf "\nChecking %s for changes...\n" "$location"
    deploy_resource "$location"
done

printf "\nChecking complete. Exiting...\n"