#!/bin/bash

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <logfile1.tgz> <logfile2.tgz> ..."
  exit 1
fi

TEMP_DIR=$(mktemp -dp .)

trap 'rm -rf "$TEMP_DIR"' EXIT

for LOG_ARCHIVE in "$@"; do
  MACHINE=$(basename "$LOG_ARCHIVE" _secure.tgz)

  MACHINE_LOGS="$TEMP_DIR/$MACHINE"
  mkdir -p "$MACHINE_LOGS"

  if tar -xzf "$LOG_ARCHIVE" -C "$MACHINE_LOGS"; then
    echo "$LOG_ARCHIVE extracted successfully."
  else
    echo "Failed to extract $LOG_ARCHIVE."
    exit 1
  fi

  if bin/process_client_logs.sh "$MACHINE_LOGS"; then
    echo "Processed logs for $MACHINE."
  else
    echo "Error processing logs for $MACHINE."
    exit 1
  fi
done

if bin/create_username_dist.sh "$TEMP_DIR"; then
  echo "Username distribution generated."
else
  echo "Failed to generate username distribution."
  exit 1
fi

if bin/create_hours_dist.sh "$TEMP_DIR"; then
  echo "Hours distribution generated."
else
  echo "Failed to generate hours distribution."
  exit 1
fi

if bin/create_country_dist.sh "$TEMP_DIR"; then
  echo "Country distribution generated."
else
  echo "Failed to generate country distribution."
  exit 1
fi

if bin/assemble_report.sh "$TEMP_DIR"; then
  echo "Final report assembled."
else
  echo "Failed to assemble the report."
  exit 1
fi

if mv "$TEMP_DIR/failed_login_summary.html" .; then
  echo "Report generated: failed_login_summary.html"
else
  echo "Error moving the report."
  exit 1
fi

exit 0
