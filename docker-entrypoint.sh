#!/bin/sh
# Docker entrypoint script for runtime environment variable injection

# Generate env-config.js from environment variables
ENV_CONFIG_FILE="/usr/share/nginx/html/env-config.js"

# Start building the config object
echo "window.__RUNTIME_CONFIG__ = {" > $ENV_CONFIG_FILE

# Add all environment variables that start with VITE_ or RUNTIME_
env | grep -E '^(VITE_|RUNTIME_)' | while IFS='=' read -r key value; do
  # Escape double quotes in the value
  escaped_value=$(echo "$value" | sed 's/"/\\"/g')
  echo "  \"$key\": \"$escaped_value\"," >> $ENV_CONFIG_FILE
done

# Close the config object
echo "};" >> $ENV_CONFIG_FILE

# Start nginx
exec "$@"
