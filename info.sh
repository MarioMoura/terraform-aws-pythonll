#!/bin/bash

function fail {
    printf '%s\n' "$1" >&2
    exit 1
}

# Read JSON input from stdin
JSON=$(cat -)

# Parse JSON input and set environment variables
VARS="$(echo "$JSON" | jq -r '. | to_entries | .[] | .key |= ascii_upcase | .key + "=" + "\"" + .value + "\""')"
eval $VARS

# Validate required inputs
[ -z "$WORKING_DIR" ] && fail "no working dir provided in JSON input"

# Change to working directory to collect information
cd "$WORKING_DIR" || fail "cannot access working directory: $WORKING_DIR"

# Check if python directory exists (should have been created by install.sh)
[ ! -d "python" ] && fail "python directory not found - installation may not have completed"

# Calculate layer size
SIZE=$(du python -hs | cut -f 1 2>/dev/null)
[ -z "$SIZE" ] && SIZE="unknown"

# Get git log information (if in a git repository)
GIT_LOG="$(git log --format=%h:%an -n 1 2>/dev/null)"
[ $? -gt 0 ] && GIT_LOG=""

# Output JSON result for Terraform
jq -n -r \
    --arg gitlog "$GIT_LOG" \
    --arg layersize "$SIZE" \
    '{
        "gitlog": $gitlog,
        "layersize": $layersize
    }'
