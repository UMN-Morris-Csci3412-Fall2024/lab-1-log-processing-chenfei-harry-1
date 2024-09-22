#!/bin/bash

input_dir="$1"

output_file="$input_dir/username_dist.html"

declare -A username_counts

for subdir in "$input_dir"/*; do
  if [ -d "$subdir" ]; then
    failed_login_file="$subdir/failed_login_data.txt"
    
    if [ -f "$failed_login_file" ]; then
      while read -r line; do
        username=$(echo "$line" | awk '{print $4}')
        ((username_counts["$username"]++))
      done < "$failed_login_file"
    fi
  fi
done


temp_data_file=$(mktemp)
{
  for username in "${!username_counts[@]}"; do
    echo "data.addRow(['$username', ${username_counts[$username]}]);"
  done
} > "$temp_data_file"

./bin/wrap_contents.sh "$temp_data_file" html_components/username_dist "$output_file"

rm "$temp_data_file"



