#!/usr/bin/env bash

set -e
set -o pipefail

PACKAGE_DIR="$1"
THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# This is the Flutter SDK version we expect for publishing
SDK_VERSION="$(cat "$THIS_SCRIPT_DIR"/SDK_VERSION)"

if [ ! -d "$PACKAGE_DIR" ]; then
    echo "Path ${PACKAGE_DIR} is not a directory" >&2
    exit 1
fi

pushd "$PACKAGE_DIR"

if ! flutter --version | head -n 1 | grep 'Flutter '"$SDK_VERSION"' '; then
    echo "Publishing requires Flutter version ${SDK_VERSION}" >&2
    echo "SDK version: "$(flutter --version | head -n 1) >&2
    exit 1
fi

function getfilename {
    while read l; do
        echo "${l:2}"
    done
}

# When present, .pubignore replaces .gitignore, which can be useful in some scenarios but doesn't 
# suit us, we want .pubignore entries to be applied on top of .gitignore, otherwise we have to
# manually keep both ignore files in sync. So we manually create a .pubignore based on both
# .gitignore and our own .pubignore.extra
if [ -f .pubignore.extra ]; then
    touch .pubignore
    git status --porcelain=2 --ignored -- . | grep '^\! ' | getfilename > .pubignore
    cat .pubignore.extra >> .pubignore
fi

# Report issues with our package without attempting to publish
flutter pub publish --dry-run

# Flutter will show a confirmation prompt before publishing
flutter pub publish

popd
