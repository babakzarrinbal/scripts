#!/bin/sh
# to get the list of folders to build without comments
# source .local-files/get-build-folders.sh

echo "============================="
echo "--- Finding build folders ---"
echo "============================="

git_root=$(git rev-parse --show-toplevel)

echo "---------------------------------"
echo "Project root: $git_root"
echo "---------------------------------"
# Find all directories containing a .dockerbuild file
build_dirs=$(find "$git_root" -name "Dockerfile" -exec dirname {} \;)

# Get the list of files changed in the current commit
changed_files=$(git diff-tree --no-commit-id --name-only -r HEAD)

selected_build_dirs=""
# Iterate over each build directory
for build_dir in $build_dirs; do

    build_dir_name=$([ "$build_dir" = "$git_root" ] && echo "." || basename "$build_dir")
if [ "$build_dir" = "$git_root" ]; then
        echo "Checking project root for build: $build_dir"
    else
        echo "Checking sub folder $build_dir_name for build: $build_dir"
    fi
    # Get the name of the build directory
    if [ -f "$build_dir/.dockerbuild" ]; then
      echo "Found .dockerbuild file, checking for relevant changes"
      # Read the patterns from the .dockerbuild file
      patterns=$(grep -v '^#' "$build_dir/.dockerbuild" | grep -v '^$')
      # Adjust the paths to be relative to the build directory

      relative_files=$( [ "$build_dir_name" == "." ] && echo "$changed_files" || echo "$changed_files" | grep "^$build_dir_name/" | sed "s|^$build_dir_name/||" )
      if [ -z "$relative_files" ]; then
          echo "No relevant changes in $build_dir"
          continue
      else
          echo "found relevant files in folder $build_dir"
      fi

      # Check if any changed files match the patterns
      for pattern in $patterns; do
          echo "Checking pattern: $pattern"
          matched_files=$(echo "$relative_files" | grep -E "$pattern" || true)
          if  [ -n "$matched_files" ]; then
              echo "Matched pattern in $build_dir:"
              echo "file: $matched_files"
              echo "pattern: $pattern"
              echo "---"
              selected_build_dirs+=$([ "$build_dir" = "$git_root" ] && echo "."$'\n' || echo "$build_dir"$'\n')
              break
          fi
      done
    else
      echo "No .dockerbuild file in $build_dir, adding to build list"
      selected_build_dirs+=$([ "$build_dir" = "$git_root" ] && echo "."$'\n' || echo "$build_dir"$'\n') 
      echo "---"
    fi
done
echo "ALL Build dirs[exported into ALL_BUILD_DIRS]:"

build_dirs=$( [ "$build_dirs" = "$git_root" ] && echo "." || echo "$build_dirs" )
for selected_build_dir in $build_dirs; do
  echo "$selected_build_dir"
done

echo "Build dirs[exported into BUILD_DIRS]:"
for selected_build_dir in $selected_build_dirs; do
  echo "$selected_build_dir"
done

export BUILD_DIRS=$selected_build_dirs
export ALL_BUILD_DIRS=$build_dirs

echo "===================================="
echo "--- End of finding build folders ---"
echo "===================================="
