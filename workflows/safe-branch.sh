#!/bin/sh


echo "==============================="
echo "--- get branch name ---"
echo "==============================="


# Fetch all tags and commits
git fetch --tags > /dev/null 2>&1
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | sed 's|^HEAD[-/]*||')
SAFE_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD | sed 's|^HEAD[-/]*||; s|[^a-zA-Z0-9-]|-|g' | cut -c1-32)

echo "BRANCH_NAME: $BRANCH_NAME"
echo "SAFE_BRANCH_NAME: $SAFE_BRANCH_NAME"

export BRANCH_NAME
export SAFE_BRANCH_NAME

echo "==============================="
echo "--- End of  branch name ---"
echo "==============================="
# Define the pattern to match tags