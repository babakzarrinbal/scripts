#!/bin/sh
# to get the list of folders to build without comments
# source .local-files/get-build-folders.sh

echo "============================="
echo "--- Finding build folders ---"
echo "============================="

git_root=$(git rev-parse --show-toplevel)

# Find all directories containing a .dockerbuild file
build_dirs=$(find "$git_root" -name "Dockerfile" -exec dirname {} \;)
echo "checking folders for build: "
for build_dir in $build_dirs; do
  echo "$build_dir"
done
echo "---"
# Get the list of files changed in the current commit
changed_files=$(git diff-tree --no-commit-id --name-only -r HEAD)
selected_build_dirs=""
# Iterate over each build directory
for build_dir in $build_dirs; do
    # Get the name of the build directory
    if [ -f "$build_dir/.dockerbuild" ]; then
      build_dir_name=$(basename "$build_dir")

      # Read the patterns from the .dockerbuild file
      patterns=$(grep -v '^#' "$build_dir/.dockerbuild" | grep -v '^$')

      # Adjust the paths to be relative to the build directory
      relative_files=$(echo "$changed_files" | grep "^$build_dir_name/" | sed "s|^$build_dir_name/||")
      # Check if any changed files match the patterns
      for pattern in $patterns; do
          matched_files=$(echo "$relative_files" | grep -E "$pattern")
          if  [ -n "$matched_files" ]; then
              echo "Matched pattern in $build_dir:"
              echo "file: $matched_files"
              echo "pattern: $pattern"
              echo "---"
              selected_build_dirs+="$build_dir"$'\n'
              break
          fi
      done
    else
      echo "No .dockerbuild file in $build_dir"
      selected_build_dirs+="$build_dir\n"
      echo "---"
    fi
done
echo "Build dirs[exported into BUILD_DIRS]:"
for selected_build_dir in $selected_build_dirs; do
  echo "$selected_build_dir"
done

export BUILD_DIRS=$selected_build_dirs

echo "===================================="
echo "--- End of finding build folders ---"
echo "===================================="
# for selected_build_dir in $selected_build_dirs; do
#   echo $selected_build_dir
# done
# echo "No matching files found."
# exit 1