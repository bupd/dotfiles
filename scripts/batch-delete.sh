#!/bin/bash

# batch-delete.sh
# Deletes files listed in a text file (one file path per line)

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Check if input file argument is given
if [ $# -ne 1 ]; then
  echo "Usage: $0 <file-list.txt>"
  exit 1
fi

# Assign first argument as input file
FILE_LIST="$1"

# Check if file exists
if [ ! -f "$FILE_LIST" ]; then
  echo "Error: File '$FILE_LIST' not found!"
  exit 1
fi

# Read each line from file list
while IFS= read -r file; do
  # Skip empty lines and comments
  [ -z "$file" ] && continue
  [[ "$file" =~ ^# ]] && continue

  # Check if file exists before deleting
  if [ -e "$file" ]; then
    echo "Deleting: $file"
    rm -f "$file"
  else
    echo "Warning: '$file' not found, skipping."
  fi
done < "$FILE_LIST"

echo "Batch delete completed!"
