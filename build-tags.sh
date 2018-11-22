#!/bin/bash

# Override basic drone tags.

# Drone 5+ docker plugin will read PLUGIN_TAGS from a .env file
# Tags:
#   Feature branch: $VERSION-$COMMIT_DATE.$BRANCH.$SHA
#   Master: $VERSION and "latest"
#
# Use --include-feature-tag to add a feature branch tag on a master branch commit

function join_by { local IFS="$1"; shift; echo "$*"; }

if [ "$1" == --include-feature-tag ]; then
  INCLUDE_FEATURE_TAG="true"
fi

if [ -f "./package.json" ]; then
  # Node
  VERSION=$(jq -r .version ./package.json )
  echo "Found package.json"
elif [ -f "./.version" ]; then
  # a version file
  VERSION=$(echo ./.version)
  echo "Found .version file"
elif [ -f "./Dockerfile" ]; then
  # from APPLICATION_VERSION in Docker file
  VERSION=$(grep 'ENV APPLICATION_VERSION' Dockerfile | awk '{print $3}')
  echo "Found version in Dockerfile file"
else
  echo "ERROR: Can't figure out version"
  exit 1
fi

# date is unix time stamp for commit
COMMIT_DATE=$(git --no-pager log -1 --format='%cI' | date +"%Y%m%d.%H%M%S" -f -)
COMMIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT_SHA=$(git --no-pager log -1 --format='%h')

echo "VERSION: ${VERSION}"
echo "COMMIT_DATE: ${COMMIT_DATE}"
echo "COMMIT_BRANCH: ${COMMIT_BRANCH}"
echo "COMMIT_SHA: ${COMMIT_SHA}"

if [ "${COMMIT_BRANCH}" != "master" ]; then
  INCLUDE_FEATURE_TAG="true"
fi

TAGS=()
if [ "${COMMIT_BRANCH}" == "master" ]; then
  echo "Writing master style tags"
  TAGS+=("${VERSION}")
  TAGS+=("latest")
fi

if [ "${INCLUDE_FEATURE_TAG}" == "true" ]; then
  echo "Writing feature style tag"
  TAGS+=("${VERSION}-${COMMIT_DATE}.${COMMIT_BRANCH}.${COMMIT_SHA}")
fi

echo "Writing tags to .env file:"
echo " - PLUGIN_TAGS=$(join_by , ${TAGS[*]})"
echo "PLUGIN_TAGS=$(join_by , ${TAGS[*]})" >> .env
