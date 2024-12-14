#!/bin/bash

# Function to convert bytes to MB/GB
convert_size() {
    local size=$1
    if [ "$size" -lt 1048576 ]; then
        echo "$((size / 1024)) KB"
    elif [ "$size" -lt 1073741824 ]; then
        echo "$((size / 1048576)) MB"
    else
        echo "$((size / 1073741824)) GB"
    fi
}

# Check if any arguments are provided
if [ "$#" -eq 0 ]; then
    echo "No files or directories provided."
    exit 1
fi

# Create a temporary file to store the properties
temp_file=$(mktemp)

# Loop through each provided file or directory
for item in "$@"; do
    if [ -d "$item" ]; then
        # If it's a directory
        num_files=$(find "$item" -type f | wc -l)
        num_dirs=$(find "$item" -type d | wc -l)
        total_size=$(du -sb "$item" | cut -f1)
        size=$(convert_size "$total_size")
        echo "Directory: $item" >> "$temp_file"
        echo "Contains: $num_files files and $((num_dirs - 1)) folders" >> "$temp_file"
        echo "Total Size: $size" >> "$temp_file"
    elif [ -f "$item" ]; then
        # If it's a file
        file_type=$(file --mime-type -b "$item")
        file_size=$(stat -c%s "$item")
        size=$(convert_size "$file_size")
        echo "File: $item" >> "$temp_file"
        echo "Type: $file_type" >> "$temp_file"
        echo "Size: $size" >> "$temp_file"
    else
        echo "$item is not a valid file or directory." >> "$temp_file"
    fi
    echo >> "$temp_file"
done

# Display the properties using `rofi`
rofi -dmenu -p "File Properties" < "$temp_file"

# Clean up the temporary file
rm "$temp_file"
