#!/bin/bash


DIR="$1"
temp_data_file=$(mktemp)

for dir in "$DIR"/*; do
    if [ -d "$dir" ]; then
        failed_login_file="$dir/failed_login_data.txt"
        if [ -f "$failed_login_file" ]; then
            awk '{print $3}' "$failed_login_file" | sort | uniq -c | \
            awk '{printf "data.addRow([\x27%s\x27, %d]);\n", $2, $1}' >> "$temp_data_file"
        fi
    fi
done


./bin/wrap_contents.sh "$temp_data_file" html_components/username_dist_header.html html_components/username_dist_footer.html > "$input_dir/username_dist.html"

rm "$temp_data_file"

