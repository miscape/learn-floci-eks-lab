#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

source "${SCRIPT_DIR}/env.sh" >/dev/null

exec aws --endpoint-url "${AWS_ENDPOINT_URL}" "$@"
