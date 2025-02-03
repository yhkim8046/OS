#!/bin/bash

# Check if exactly one argument is passed
if [ "$#" -ne 1 ]; then
    echo "Error: You must provide exactly one argument."
    echo "Usage: $0 filename"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "Error: The file '$1' does not exist."
    exit 1
fi

# The rest of your script goes here
#! /bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: script3.sh parm1 parm2"
  echo "Please enter 2 arguments exactly"
  exit 255
fi

