#!/bin/bash

function fail {
    printf '%s\n' "$1" >&2
    exit 1
}

JSON=$(cat -)

VARS="$(echo "$JSON" | jq -r '. | to_entries | .[] |  .key |= ascii_upcase | .key + "=" + "\"" + .value + "\"" ')"
eval $VARS

[ -z $WORKING_DIR ] && fail "no working dir"
mkdir -p $WORKING_DIR
cd $WORKING_DIR
[ -z $PYTHON_VERSION ] && fail "no python version"

# Create temporary requirements file for Docker
echo "$REQUIREMENTS" | tr ' ' '\n' > temp_requirements.txt

# Docker-based installation for consistent environment
docker run --rm \
	-u "$(id -u):$(id -g)" \
	-v "$PWD:/work" \
	-w /work \
	"python:${PYTHON_VERSION}" \
	pip install \
		 -t ./python "$REQUIREMENTS" >/dev/null 2>&1

# Clean up temp file
#rm -f temp_requirements.txt

# Remove unneeded files
#find python \( -name '__pycache__' -o -name '*.dist-info' \) -type d -exec rm -rf {} +
#rm -rf python/bin

SIZE=$(du python -hs | cut -f 1)

GIT_LOG="$(git log --format=%h:%an -n 1)"
[ $? -gt 0 ] && GIT_LOG=""

jq -n \
	--arg gitlog "$GIT_LOG" \
	--arg platform "$PLATFORM" \
	--arg layersize "$SIZE" \
	--arg input "$VARS" \
	'{
		"input":$input,
		"platform":$platform,
		"gitlog":$gitlog,
		"layersize": $layersize
	}'
