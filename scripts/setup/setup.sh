#!/bin/bash
set -euo pipefail

# Install pipeline package
pip install -e .

# Pull pinned TMalign / TMscore container by digest from the bv registry.
# No source build, no zhanggroup.org downloads. The image's sha256 is in
# bv.lock and is verified before any run.
#
# Requires bv 0.1.15+: https://github.com/mlberkeley/bv
if ! command -v bv >/dev/null 2>&1; then
	echo "error: bv is not installed. See https://github.com/mlberkeley/bv for install instructions." >&2
	exit 1
fi
bv sync
