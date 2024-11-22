#!/bin/bash

set -e

# Clone the repository if it doesn't exist
if [ ! -d "/app/sleepdbt" ]; then
  git clone https://github.com/JPoirier55/sleepdbt.git /app/sleepdbt
fi

cd /app/sleepdbt/sleep/

# Execute any additional commands
exec "$@"
