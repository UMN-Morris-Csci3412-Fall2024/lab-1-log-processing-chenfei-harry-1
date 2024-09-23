#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <logfile1.tgz> <logfile2.tgz> ..."
  exit 1
fi

cleanup() {
  echo "Cleaning up..."
  rm -rf "$TEMP_DIR"
}

TEMP_DIR=$(mktemp -dp .)
trap cleanup EXIT

extract_logs() {
  local LOG_ARCHIVE="$1"
  local MACHINE="$2"
  local MACHINE_LOGS="$TEMP_DIR/$MACHINE"
  mkdir -p "$MACHINE_LOGS"

  if tar -xzf "$LOG_ARCHIVE" -C "$MACHINE_LOGS"; then
    echo "Extracted $LOG_ARCHIVE successfully."
  else
    echo "Failed to extract $LOG_ARCHIVE."
    return 1
  fi
}

process_logs() {
  local MACHINE_LOGS="$1"
  
  if bin/process_client_logs.sh "$MACHINE_LOGS"; then
    echo "Processed logs for $MACHINE."
  else
    echo "Error processing logs for $MACHINE."
    return 1
  fi
}

generate_username_dist() {
  if bin/create_username_dist.sh "$TEMP_DIR"; then
    echo "Username distribution generated."
  else
    echo "Failed to generate username distribution."
    return 1
  fi
}

generate_hours_dist() {
  if bin/create_hours_dist.sh "$TEMP_DIR"; then
    echo "Hours distribution generated."
  else
    echo "Failed to generate hours distribution."
    return 1
  fi
}

generate_country_dist() {
  if bin/create_country_dist.sh "$TEMP_DIR"; then
    echo "Country distribution generated."
  else
    echo "Failed to generate country distribution."
    return 1
  fi
}

assemble_report() {
  if bin/assemble_report.sh "$TEMP_DIR"; then
    echo "Final report assembled."
  else
    echo "Failed to assemble the report."
    return 1
  fi
}

for LOG_ARCHIVE in "$@"; do
  MACHINE=$(basename "$LOG_ARCHIVE" _secure.tgz)

  extract_logs "$LOG_ARCHIVE" "$MACHINE" || exit 1
  process_logs "$TEMP_DIR/$MACHINE" || exit 1
done

generate_username_dist || exit 1
generate_hours_dist || exit 1
generate_country_dist || exit 1
assemble_report || exit 1

if mv "$TEMP_DIR/failed_login_summary.html" .; then
  echo "Report generated: failed_login_summary.html"
else
  echo "Error moving the report."
  exit 1
fi

exit 0
