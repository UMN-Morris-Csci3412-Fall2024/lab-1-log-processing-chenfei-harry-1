#!/bin/bash

# Change to the specified directory
cd "$1" || { echo "Directory not found: $1"; exit 1; }

# Process the log files
cat * | awk '
    # Pattern for invalid users
    /Failed password for invalid user/ {
        # Example: Aug 14 06:00:36 computer_name sshd[26795]: Failed password for invalid user admin from 218.2.129.13 port 59638 ssh2
        # Extract fields: $1 (Month), $2 (Day), $3 (Time), $9 (Username), $11 (IP)
        split($3, time, ":");  # Remove minutes and seconds from time
        print $1, $2, time[1], $9, $11;
    }
    # Pattern for valid users
    /Failed password for / && !/invalid user/ {
        # Example: Aug 14 06:00:41 computer_name sshd[26798]: Failed password for root from 218.2.129.13 port 62901 ssh2
        # Extract fields: $1 (Month), $2 (Day), $3 (Time), $9 (Username), $11 (IP)
        split($3, time, ":");  # Remove minutes and seconds from time
        print $1, $2, time[1], $9, $11;
    }
' > failed_login_data.txt

echo "Processing complete. Output saved to failed_login_data.txt"
