#!/bin/sh

echo "============================="
echo "--- Finding build folders ---"
echo "--- checking .dockerbuild ---"
echo "--- checking .dockerignore --"
echo "============================="

git_root=$(git rev-parse --show-toplevel)
build_dirs=$(find "$git_root" -name "Dockerfile" -exec dirname {} \;)
changed_files=$(git diff-tree --no-commit-id --name-only -r HEAD)
selected_build_dirs=""

for build_dir in $build_dirs; do
    [ -f "$build_dir/.gitignore" ] && cp "$build_dir/.gitignore" "$build_dir/.gitignore.bak"
    build_dir_name=$([ "$build_dir" = "$git_root" ] && echo "." || basename "$build_dir")
    echo "Checking $( [ "$build_dir" = "$git_root" ] && echo 'project root' || echo "subfolder $build_dir_name" ) for build: $build_dir"
    relative_files=$([ "$build_dir_name" = "." ] && echo "$changed_files" || echo "$changed_files" | grep "^$build_dir_name/" | sed "s|^$build_dir_name/||")

    [ -z "$relative_files" ] && echo "No changes detected in $build_dir" && continue

    if [ -f "$build_dir/.dockerbuild" ]; then
        cp "$build_dir/.dockerbuild" "$build_dir/.gitignore"
        git rm -r --cached .
        build_files=$(printf "%s\n" "$relative_files" | git check-ignore --stdin)
        [ -z "$build_files" ] && echo "No relevant changes due to .dockerbuild in $build_dir" || {
            echo "Found relevant files in $build_dir:"
            selected_build_dirs+=$([ "$build_dir" = "$git_root" ] && echo "."$'\n' || echo "$build_dir"$'\n')
        }
    elif [ -f "$build_dir/.dockerignore" ]; then
        cp "$build_dir/.dockerignore" "$build_dir/.gitignore"
        git rm -r --cached .
        ignored_files=$(printf "%s\n" "$relative_files" | git check-ignore --stdin)
        non_ignored_files=$( 
            if [ -n "$ignored_files" ]; then 
                printf "%s\n" "$relative_files" | grep -vFf <(printf "%s\n" "$ignored_files")
            else 
                printf "%s\n" "$relative_files"
            fi
        )
        [ -z "$non_ignored_files" ] && echo "No relevant changes due to .dockerignore in $build_dir" || {
            echo "Found relevant files in $build_dir:"
            selected_build_dirs+=$([ "$build_dir" = "$git_root" ] && echo "."$'\n' || echo "$build_dir"$'\n')
        }
    else
        echo "Adding $build_dir to build list"
        selected_build_dirs+=$([ "$build_dir" = "$git_root" ] && echo "."$'\n' || echo "$build_dir"$'\n')
    fi
    
    [ -f "$build_dir/.gitignore.bak" ] && cp "$build_dir/.gitignore.bak" "$build_dir/.gitignore" && rm "$build_dir/.gitignore.bak"
done

echo "============== ALL Build dirs [exported into ALL_BUILD_DIRS]: =============="
build_dirs=$( [ "$build_dirs" = "$git_root" ] && echo "." || echo "$build_dirs" )
echo "$build_dirs"
echo "============== Build dirs [exported into BUILD_DIRS]: ======================"
echo "$selected_build_dirs"

export BUILD_DIRS="$selected_build_dirs"
export ALL_BUILD_DIRS="$build_dirs"

echo "===================================="
echo "--- End of finding build folders ---"
echo "===================================="
