#!/bin/bash
netstat -natp | grep 5432
if [ "$?" -eq 0 ]; then
    echo "PostgreSQL is now listening on port 5432"
fi
