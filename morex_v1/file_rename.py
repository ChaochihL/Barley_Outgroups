#!/usr/bin/env python3
# Peter L. Morrell - St. Paul, MN 17 October 2016
"""A script to rename files, especially fastq files downloaded from the NCBI Sequence Read Archive."""

"""Known issues: 1) is only designed to work from the directory where files will be renamed and 2) will not except input files with a trailing newline!"""

import os
import sys

Usage = """
file_rename.py - version 1
The script reads in a file containing a list of old and new files in the first and second column. It then checks for presence of a file by the same name in the current working directory. If the file is present (and the user has permissions) the file name is replaced with the name in the second column. Both old and new file names listed should be unique. The list of file names can have a header after a comment "#" symbol.

Usage:
    file_rename.py [file_list.txt]
"""

#   Expects a filename as the only argument
if not sys.argv[1:]:
    print(Usage)
    exit(1)

#   Create a dictionary that will hold old and new file names
file_data = {}
#   Read the file in line-by-line
try:
    with open(sys.argv[1]) as f:
        for line in f:
            #   Skip the header lines
            if line.startswith('#'):
                continue
            #   Split the two columns, then write to key & value
            else:
                names = line.strip().split()
                file_data[names[0]] = names[1]
except IOError as ex:
    print("File open issue: " + ex.strerror)

#    Get the path to the current directory
cwd = os.getcwd()
files = []
#    List the files in the current directory
files = os.listdir(cwd)

#    Create a new dictionary with only the files in our list that \
#    match file names in the current direcoty
re_names = {k: file_data[k] for k in files if k in file_data}

#    Use keys and values to replace old file names with new
for i, j in re_names.items():
    os.rename(i, re_names[i])
