#!/bin/sh
# to get the list of folders to build without comments
# source .local-files/get-build-folders.sh

echo "============================="
echo "--- Finding build folders ---"
echo "============================="

git_root=$(git rev-parse --show-toplevel)

# Find all directories containing a Dockerfile
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
        echo "Checking subfolder $build_dir_name for build: $build_dir"
    fi

    # Get the list of changed files relative to the build directory
    relative_files=$( [ "$build_dir_name" == "." ] && echo "$changed_files" || echo "$changed_files" | grep "^$build_dir_name/" | sed "s|^$build_dir_name/||" )

    if [ -z "$relative_files" ]; then
        echo "No changes detected in $build_dir"
        continue
    fi

    # Check if there is a .dockerignore file
    if [ -f "$build_dir/.dockerignore" ]; then
        echo "Found .dockerignore file in $build_dir"

        # Create a temporary file with the list of relative changed files
        temp_changed_files=$(mktemp)
        echo "$relative_files" > "$temp_changed_files"

        # Create a temporary directory to simulate the context
        temp_context=$(mktemp -d)

        # Copy the .dockerignore file to the temporary context
        cp "$build_dir/.dockerignore" "$temp_context/"

        # Use Docker's dockerignore parser to check which files are ignored
        ignored_files=$(cd "$temp_context" && tar -cf - -T "$temp_changed_files" --exclude-from=.dockerignore 2>/dev/null | tar -tf -)

        # Clean up temporary files
        rm -rf "$temp_context"
        rm "$temp_changed_files"

        # Determine non-ignored files
        non_ignored_files=$(comm -23 <(echo "$relative_files" | sort) <(echo "$ignored_files" | sort))

        if [ -z "$non_ignored_files" ]; then
            echo "All changed files in $build_dir are ignored by .dockerignore"
            continue
        else
            echo "Non-ignored changed files in $build_dir:"
            echo "$non_ignored_files"
        fi
    fi

    # Existing .dockerbuild logic
    if [ -f "$build_dir/.dockerbuild" ]; then
        echo "Found .dockerbuild file, checking for relevant changes"
        # Read the patterns from the .dockerbuild file
        patterns=$(grep -v '^#' "$build_dir/.dockerbuild" | grep -v '^$')

        if [ -z "$relative_files" ]; then
            echo "No relevant changes in $build_dir"
            continue
        else
            echo "Found relevant files in folder $build_dir"
        fi

        # Check if any changed files match the patterns
        for pattern in $patterns; do
            echo "Checking pattern: $pattern"
            matched_files=$(echo "$relative_files" | grep -E "$pattern" || true)
            if [ -n "$matched_files" ]; then
                echo "Matched pattern in $build_dir:"
                echo "File(s): $matched_files"
                echo "Pattern: $pattern"
                echo "---"
                selected_build_dirs+=$([ "$build_dir" = "$git_root" ] && echo "."$'\n' || echo "$build_dir"$'\n')
                break
            fi
        done
    else
        echo "Adding $build_dir to build list"
        selected_build_dirs+=$([ "$build_dir" = "$git_root" ] && echo "."$'\n' || echo "$build_dir"$'\n')
        echo "---"
    fi
done

echo "ALL Build dirs [exported into ALL_BUILD_DIRS]:"

build_dirs=$( [ "$build_dirs" = "$git_root" ] && echo "." || echo "$build_dirs" )
for selected_build_dir in $build_dirs; do
    echo "$selected_build_dir"
done

echo "Build dirs [exported into BUILD_DIRS]:"
for selected_build_dir in $selected_build_dirs; do
    echo "$selected_build_dir"
done

export BUILD_DIRS=$selected_build_dirs
export ALL_BUILD_DIRS=$build_dirs

echo "===================================="
echo "--- End of finding build folders ---"
echo "===================================="
