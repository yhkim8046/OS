#!/bin/bash

# Verifying that exactly 2 arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Error: 2 arguments are required."
  echo "Usage: ./extract.sh <filename> <directory>"
  exit 1
fi

# Assigning arguments to variables
filename="$1"
directory="$2"

# Verifying if the file exists
if [ ! -e "$filename" ]; then
  echo "Error: File '$filename' does not exist."
  exit 1
fi

# Verifying if the directory exists, if not, create it
if [ ! -d "$directory" ]; then
  mkdir -p "$directory"
fi

# Extracting lines containing 'special' and saving them to a file
grep "special" "$filename" > "$directory/special.txt"

echo "Lines containing 'special' have been saved to '$directory/special.txt'."
