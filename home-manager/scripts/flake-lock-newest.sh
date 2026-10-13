#!/usr/bin/env bash
# Reads a flake.lock from stdin and prints the newest input lastModified
# timestamp (UTC). Usage: git show HEAD~1:flake.lock | flake-lock-newest
set -euo pipefail

ts=$(@JQ@ -r '[.nodes[].locked.lastModified | select(. != null)] | max')
date -u -d "@$ts" '+%Y-%m-%d %H:%M:%S UTC'
