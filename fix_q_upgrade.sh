#!/bin/bash

# unzip Qumulo Core upgrade zip files
# delete PDFs
# run md5sums

MD5_SUFFIX='md5.txt'

if (( $# != 1 )); then
    echo "Usage: `basename $0` <zip dir>"
    exit 1
fi

# directory where the zip files are
zip_dir=$1

# change IFS to deal with spaces in filenames
oIFS=$IFS
IFS=$'\n'

# unzip all zipfiles in current directory
for zip in `\ls ${zip_dir}/*.zip`; do
    echo "Unzipping $zip"
    # -a and -L do nothing on these
    # -o overwrite without prompting
    # -j unzip into current directory
    # -q quiet
    unzip -o -j "$zip"
done

echo
# remove the Release Notes
echo "Deleting release note PDFs"
rm *.pdf

echo
# fix MD5 files
for md_file in `\ls *.$MD5_SUFFIX`; do
    echo "Fixing MD5 file: $md_file"
    # some of the files have newlines, some don't
    sum=$(cat $md_file)

    img=${md_file/\.$MD5_SUFFIX/}

    # overwrite with sanitized text
    echo "$sum $img" > $md_file
done

echo
# check the md5sums
echo "Checking MD5s"
md5sum -c *.$MD5_SUFFIX

echo
# show all image files in dir to call attention
# to images without MD5s
echo "Images"
\ls -1 *.qimg
