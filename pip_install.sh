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

PIP_OUT=$(pip install \
	${PLATFORM:+--platform} $PLATFORM \
	--target python \
	${IMPLEMENTATION+--implementation} $IMPLEMENTATION \
	--python-version $PYTHON_VERSION \
	--only-binary=:all: \
	$REQUIREMENTS 2>&1)
[ $? -gt 0 ] && fail "$PIP_OUT"

SIZE=$(du python -hs | cut -f 1)

GIT_LOG="$(git log --format=%h:%an -n 1)"
[ $? -gt 0 ] && GIT_LOG=""

jq -n \
	--arg gitlog "$GIT_LOG" \
	--arg platform "$PLATFORM" \
	--arg layersize "$SIZE" \
	--arg pipout "$PIP_OUT" \
	--arg input "$VARS" \
	'{
		"input":$input,
		"pip_out":$pipout,
		"platform":$platform,
		"gitlog":$gitlog,
		"layersize": $layersize
	}'
