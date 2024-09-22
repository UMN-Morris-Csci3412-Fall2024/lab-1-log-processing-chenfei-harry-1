#!/bin/bash

current_dir=$(pwd)

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

input_dir="$1"

if ! cd "$input_dir"; then
  echo "Error: Unable to access directory $input_dir"
  exit 1
fi

output_file="username_dist.html"
header_file="$current_dir/html_components/username_dist_header.html"
footer_file="$current_dir/html_components/username_dist_footer.html"

if [ -f "$header_file" ]; then
  cat "$header_file" > "$output_file"
else
  echo "Header file not found (current directory: $current_dir): $header_file"
  exit 1
fi

temp_file=$(mktemp)

find . -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
  failed_login_file="$dir/failed_login_data.txt"
  if [ -f "$failed_login_file" ]; then
    awk '{print $4}' "$failed_login_file" >> "$temp_file"
  fi
done

if [ -s "$temp_file" ]; then
  sort "$temp_file" | uniq -c | while read -r occurrences username; do
    printf "data.addRow([\x27%s\x27, %d]);\n" "$username" "$occurrences" >> "$output_file"
  done
else
  echo "No usernames found."
  exit 1
fi

if [ -f "$footer_file" ]; then
  cat "$footer_file" >> "$output_file"
else
  echo "Footer file not found: $footer_file"
  exit 1
fi

rm -f "$temp_file"
