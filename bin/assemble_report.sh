#!/bin/bash

current_dir=$(pwd)

target_dir="$1"
cd "$target_dir" || { echo "Error: Cannot access directory $target_dir"; exit 1; }

country_html="country_dist.html"
hours_html="hours_dist.html"
username_html="username_dist.html"
combined_temp_file="combined_temp.html"

cat "$country_html" "$hours_html" "$username_html" > "$combined_temp_file"

cd "${current_dir}" || { echo "Error: Cannot return to original directory"; exit 1; }

./bin/wrap_contents.sh "${target_dir}/$combined_temp_file" ./html_components/summary_plots "${target_dir}/failed_login_summary.html"

rm -f "${target_dir}/$combined_temp_file"
