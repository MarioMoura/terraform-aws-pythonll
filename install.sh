#!/bin/bash

function log {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

function fail {
    log "ERROR: $1"
    exit 1
}

log "Starting Lambda layer installation"

# Environment validation with logging
[ -z "$WORKING_DIR" ] && fail "WORKING_DIR environment variable not set"
[ -z "$PYTHON_VERSION" ] && fail "PYTHON_VERSION environment variable not set"
[ -z "$REQUIREMENTS" ] && fail "REQUIREMENTS environment variable not set"

log "Configuration:"
log "  Python version: $PYTHON_VERSION"
log "  Working directory: $WORKING_DIR"
log "  Platform: ${PLATFORM:-default}"
log "  Implementation: ${IMPLEMENTATION:-default}"
log "  Requirements: $REQUIREMENTS"

# Create working directory
log "Creating working directory: $WORKING_DIR"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR" || fail "Failed to change to working directory: $WORKING_DIR"

# Create temporary requirements file for Docker
log "Preparing requirements for installation"
echo "$REQUIREMENTS" | tr ' ' '\n' > temp_requirements.txt

# Docker-based installation for consistent environment
log "Starting Docker container for pip install..."
log "Docker command: docker run --rm -u \"$(id -u):$(id -g)\" -v \"$PWD:/work\" -w /work \"python:${PYTHON_VERSION}\" pip install -t ./python $REQUIREMENTS"

docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD:/work" \
    -w /work \
    "python:${PYTHON_VERSION}" \
    pip install -t ./python $REQUIREMENTS

if [ $? -eq 0 ]; then
    log "Docker pip install completed successfully"

    # Clean up temp file
    rm -f temp_requirements.txt
    log "Cleaned up temporary requirements file"

    # Calculate and log the installation size
    if [ -d "python" ]; then
        SIZE=$(du python -hs | cut -f 1 2>/dev/null || echo "unknown")
        log "Installation completed successfully"
        log "Layer directory created: $WORKING_DIR/python"
        log "Layer size: $SIZE"

        # Optional: Log package count
        PACKAGE_COUNT=$(find python -name "*.dist-info" -type d | wc -l 2>/dev/null || echo "unknown")
        log "Packages installed: $PACKAGE_COUNT"
    else
        fail "Installation completed but python directory not found"
    fi
else
    fail "Docker pip install failed with exit code $?"
fi

log "Installation phase completed successfully"