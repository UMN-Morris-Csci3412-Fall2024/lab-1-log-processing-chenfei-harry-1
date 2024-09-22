#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

directory="$1"
output_file="country_dist.html"
header_file="../html_components/country_dist_header.html"
footer_file="../html_components/country_dist_footer.html"
ip_country_map="../etc/country_IP_map.txt"

if ! cd "$directory"; then
  echo "Error: Unable to access directory $directory"
  exit 1
fi

if [ ! -f "$ip_country_map" ]; then
  echo "Error: Country IP map not found: $ip_country_map"
  exit 1
fi

if [ -f "$header_file" ]; then
  cat "$header_file" > "$output_file"
else
  echo "Header file missing: $header_file"
  exit 1
fi

temp_ips=$(mktemp)

for dir in */; do
  failed_login_data="${dir%/}/failed_login_data.txt"
  if [ -f "$failed_login_data" ]; then
    awk '{print $5}' "$failed_login_data" >> "$temp_ips"
  fi
done

mapped_countries=$(mktemp)

sort "$temp_ips" | join -1 1 -2 1 -o 2.2 - "$ip_country_map" > "$mapped_countries"

sort "$mapped_countries" | uniq -c | while read -r count country_code; do
  printf "data.addRow([\x27%s\x27, %d]);\n" "$country_code" "$count" >> "$output_file"
done

if [ -f "$footer_file" ]; then
  cat "$footer_file" >> "$output_file"
else
  echo "Footer file missing: $footer_file"
  rm -f "$temp_ips" "$mapped_countries"
  exit 1
fi

rm -f "$temp_ips" "$mapped_countries"


