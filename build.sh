#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

packer init .
packer build -force "$@" .
