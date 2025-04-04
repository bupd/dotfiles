#!/bin/bash

# This script recursively finds and deletes all node_modules directories from the current directory

echo "Searching for node_modules folders..."

# Use find to locate all node_modules directories
find . -type d -name "node_modules" -prune -print | while read dir; do
    echo "Deleting: $dir"
    rm -rf "$dir"
done

echo "All node_modules folders deleted."
