#!/bin/bash

contents_file=$1
specifier=$2
output_file=$3

header_file="${specifier}_header.html"
footer_file="${specifier}_footer.html"

cat "$header_file" "$contents_file" "$footer_file" > "$output_file"

echo "Output written to $output_file"
