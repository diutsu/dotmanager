#!/bin/zsh
#
# Dotmanager
#
# Author: Goncalo Sousa
# License: MIT
# Version: 0.1
# GitHub: https://github.com/diutsu/dotmanager
# License: This project is licensed under the MIT License - see the LICENSE file for details.
#
# Dotmanager is a simple script for managing your dotfiles, allowing you to install, update, add,
# check status, or view differences with ease.
#
# Usage:
#   ./dotmanager.sh [-iua:hsD:] [file]
#
# Options:
#   -i: Install mode
#   -u: Update mode
#   -a <file>: Add mode. Add a new file to the managed files folder.
#   -h: Print this help message.
#   -s: Status mode. Print the status between the source and destination directories.
#   -D <file>: Diff mode. Print the difference with the specified file.
#
# This software is provided "as is," without warranty of any kind, express or implied. 
# The authors or contributors of this software shall not be held liable for any claims, damages, 
# or other liabilities arising from the use of this software.

src_dir="${DOTFILES:-./files}"
dest_dir="$HOME"

print_help() {
    echo "Usage: $0 [-iua:hsd:] [file]"
    echo "Options:"
    echo "  -i: Install mode"
    echo "  -u: Update mode"
    echo "  -a <file>: Add mode. Add a new file to the managed files folder."
    echo "  -h: Print this help message."
    echo "  -s: Status mode. Print the status between the source and destination directories."
    echo "  -D <file>: Diff mode. Print the difference with the specified file."
    exit 0
}

print_status() {
    echo "Status between '$src_dir' and '$dest_dir':"
    
    # Check status for each managed file
    for file in "${managed_files[@]}"; do
        rel_path=$(echo "$file" | sed "s|$src_dir/||")
        dest_file="$dest_dir/$rel_path"

        if [ -e "$dest_file" ]; then
            if cmp -s "$file" "$dest_file"; then
                echo "Up to date: $rel_path"
            else
                echo "Needs update: $rel_path"
            fi
        else
            echo "Missing in local system: $rel_path"
        fi
    done
}

# Parse command-line options
while getopts "iua:hsD:" opt; do
    case $opt in
        i) mode="install" ;;
        u) mode="update" ;;
        a) mode="add"; new_file="$OPTARG" ;;
        h) print_help ;;
        s) mode="status" ;;
        D) mode="diff" ; diff_file="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG" >&2 ; print_help ;;
    esac
done

# Check if no mode is specified
if [[ -z "$mode" ]]; then
    echo "Error: No mode specified. Use -i (install), -u (update), -a (add), or -h (help). Exiting."
    exit 1
fi

# Check if the destination directory exists
if [[ ! -d "$dest_dir" ]]; then
    echo "Destination directory '$dest_dir' does not exist. Exiting."
    exit 1
fi

# Create a list of excluded files
excluded_files=("dotmanager.sh" "README.md" "LICENSE")

# Find managed files excluding excluded files
managed_files=($(find "$src_dir" -type f ! -name "${excluded_files[1]}" ! -name "${excluded_files[2]}" ! -name "${excluded_files[3]}"))

if [[ "$mode" == "add" ]]; then
    # Check if a new file is provided
    if [ -z "$OPTARG" ]; then
        echo "Option -a requires a file path. Exiting."
        exit 1
    fi

    # Get the absolute path of the new file
    new_file=$(realpath "$OPTARG")

    # Get the relative path to the home directory
    rel_path=$(realpath --relative-to="$HOME" "$new_file")

    # Check if the new file is under the home directory
    if [[ "$rel_path" == ".."* ]]; then
        echo "Error: The new file must be under the home directory ('$HOME'). Exiting."
        exit 1
    fi

    # Check if the file already exists in the files folder
    if [ -e "$dest_path" ]; then
        # Update the existing file
        cp "$new_file" "$dest_path"
        echo "Updated $dest_path with $new_file"
    else
        # Copy the new file to the files folder
        cp "$new_file" "$dest_path"
        echo "Added $new_file to $dest_path"
    fi
elif [[ "$mode" == "status" ]]; then
    print_status
    exit 0

elif [[ "$mode" == "diff" ]]; then
    # Check if a diff file is provided
    if [ -z "$diff_file" ]; then
        echo "Error: Option -D requires a file path. Exiting."
        exit 1
    fi

    # Get the absolute path of the diff file
    diff_file=$(realpath "$diff_file")

    # Check if the diff file is one of the managed files
    rel_path=$(realpath --relative-to="$HOME" "$diff_file")
    if [ ! -e "$src_dir/$rel_path" ]; then
        echo "Error: The specified file is not managed. Exiting."
        exit 1
    fi

    # Print the difference with the specified file
    diff -u "$src_dir/$rel_path" "$diff_file"

    exit 0
fi

# Process the list of files
for file in "${managed_files[@]}"; do
    # Remove common prefix from file names
    file_name=$(echo "$file" | sed "s|$src_dir/||")
    dest_file="$dest_dir/$file_name"

    if [[ "$mode" == "install" ]]; then
        if [ -e "$dest_file" ]; then
            if diff -r "$file" "$dest_file" > /dev/null; then
                echo "No change between $file and $dest_file"
            else
                cp -r "$file" "$dest_dir"
                echo "Updated $file with $dest_file"
            fi
        else
            cp -r a"$file" "$dest_dir"
            echo "Created: $dest_file"
        fi
    elif [[ "$mode" == "update" ]]; then
        if [ -e "$dest_file" ]; then
            if diff -r "$file" "$dest_file" > /dev/null; then
                echo "No change between $file and $dest_file"
            else
                cp -r "$dest_file" "$file"
                echo "Updated: $file with $dest_file"
            fi
        else
            echo "File not found in local filesystem: $dest_file. Skipping..."
        fi
    fi
done
