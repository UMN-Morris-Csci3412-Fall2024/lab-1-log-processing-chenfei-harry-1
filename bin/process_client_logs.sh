#!/bin/bash

cd "$1" || exit

find . -type f -exec file --mime {} + | grep 'charset=binary' -v | cut -d: -f1 | \
xargs cat | iconv -f UTF-8 -t UTF-8 -c | awk '

# Case 1: Handling invalid user log entries
/Failed password for invalid user/ {
    date = $1 " " $2
    time = substr($3, 1, 2)
    user = $(NF-5)
    ip = $(NF-3)
    print date, time, user, ip
}

# Case 2: Handling valid user log entries (excluding invalid users)
/Failed password for/ && !/invalid user/ {
    date = $1 " " $2
    time = substr($3, 1, 2)
    user = $(NF-5)
    ip = $(NF-3)
    print date, time, user, ip
}'  > failed_login_data.txt

