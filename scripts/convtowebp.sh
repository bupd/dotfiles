#!/bin/bash

# Prompt the user for confirmation.
echo "This script will recursively convert all of the .png, .jpg, and .jpeg files in the current directory and all of its subdirectories to WebP format in the specified output directory."
echo "Do you want to continue? (y/n)"
read -r confirm

# If the user confirms, continue with the script.
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then

  # Prompt the user for the output directory.
  echo "Enter the output directory:"
  read -r output_dir

  # Create the output directory if it does not exist.
  mkdir -p "$output_dir"

  # Recursively search the current directory and all of its subdirectories for .png, .jpg, and .jpeg files.
  for file in $(find . -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \)); do

    # Convert the file to WebP format and save it to the output directory.
    cwebp -q 80 "$file" -o "$output_dir/${file%.*}.webp"

  done

  echo "All of the images have been converted to WebP format and saved to the '$output_dir' directory."

else

  echo "Conversion cancelled."

fi
