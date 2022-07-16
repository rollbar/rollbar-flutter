#!/usr/bin/env bash
set -e
set -o pipefail

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo cleaning rollbar_common
( cd $THIS_SCRIPT_DIR/../rollbar_common && flutter clean )

echo cleaning rollbar_dart
( cd $THIS_SCRIPT_DIR/../rollbar_dart && flutter clean )

echo cleaning rollbar_flutter
( cd $THIS_SCRIPT_DIR/../rollbar_flutter && flutter clean )
