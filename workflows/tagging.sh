#!/bin/sh


echo "==============================="
echo "--- Finding new version tag ---"
echo "==============================="


# Fetch all tags and commits
git fetch --tags
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | sed 's|^HEAD[-/]*||')
# Define the pattern to match tags
TAG_PATTERN='^v([0-9]+)\.([0-9]+)\.([0-9]+)$'


# Get the latest tag by version that matches the pattern
CURRENT_TAG=$(git tag --list --merged | grep -E "$TAG_PATTERN" | sort -V | tail -n 1)
echo "CURRENT_TAG: $CURRENT_TAG"
# Get the latest commit hash
LATEST_COMMIT=$(git rev-parse HEAD)

# Check if the latest commit is already tagged
LAST_COMMIT_TAG=$(git describe --tags --exact-match ${LATEST_COMMIT} 2>/dev/null || echo "none")
if [ "$LAST_COMMIT_TAG" != "none" ]; then
  echo "Found tag attached to latest commit: $LAST_COMMIT_TAG"
fi
# Function to generate a new tag
generate_new_tag() {
  if [[ $CURRENT_TAG =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    NEW_VERSION="v${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.$((BASH_REMATCH[3] + 1))"
  else
    NEW_VERSION="v1.0.0"
  fi
}

# Function to find an unused tag
find_unused_tag() {
  generate_new_tag
  while git rev-parse "$NEW_VERSION" >/dev/null 2>&1; do
    echo "Tag $NEW_VERSION already exists"
    CURRENT_TAG=$NEW_VERSION
    generate_new_tag
  done
}

if [ "$LAST_COMMIT_TAG" != "none" ]; then
  NEW_VERSION=$LAST_COMMIT_TAG
else
  find_unused_tag
fi

# Export the new version to the GitHub environment
echo "BRANCH_NAME[exported]: $BRANCH_NAME"
echo "CURRENT_VERSION[exported]: $CURRENT_TAG"
echo "NEW_VERSION[exported]: $NEW_VERSION"

export BRANCH_NAME
export CURRENT_VERSION=$CURRENT_TAG
export NEW_VERSION

echo "====================================="
echo "--- End of Finding new version tag---"
echo "====================================="