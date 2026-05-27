#!/bin/bash
set -e

HUGO_VERSION="0.162.0"
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"

echo ">>> Downloading Hugo Extended ${HUGO_VERSION}..."
curl -fsSL "$HUGO_URL" | tar -xz hugo

echo ">>> Hugo version:"
./hugo version

echo ">>> Building site..."
./hugo --gc --minify
