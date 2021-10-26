#!/usr/bin/env bash

set -e
set -o pipefail

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SDK_VERSION="$(cat "$THIS_SCRIPT_DIR"/SDK_VERSION)"

"$THIS_SCRIPT_DIR"/build.sh --flutter-version "$SDK_VERSION" \
                  -d "$THIS_SCRIPT_DIR"/../rollbar_dart \
                  -d "$THIS_SCRIPT_DIR"/../rollbar_flutter
