#!/usr/bin/env bash

set -e
set -o pipefail

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

declare -a DIRECTORIES=()
declare -a TASKS=()

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -d|--directory)
            DIRECTORIES+=("$2")
            shift
            shift
            ;;
        --flutter-version)
            FLUTTER_VERSION="$2"
            shift
            shift
            ;;
        *)
            TASKS+=("$1")
            shift
            ;;
    esac
done

function exec_task {
    local task="$1"
    echo "Running task $task"

    case "$task" in
        pub-get)
            flutter pub get
            ;;
        "test")
            flutter test
            ;;
        "analyze")
            "$THIS_SCRIPT_DIR"/run-flutter-analyze "$FLUTTER_VERSION"
            ;;
        "pana")
            "$THIS_SCRIPT_DIR"/run-pana "$FLUTTER_VERSION"
            ;;
        "gradle-check")
            export FLUTTER_SDK=$("$THIS_SCRIPT_DIR"/find-flutter-sdk)
            if [ -e "android" ]; then
                pushd android
                ./gradlew check
                popd
            else
                echo "Skipping gradle check, no android directory in ${PWD} package" >&2
            fi
            ;;
        "example-android")
            if [ -e "example/lib/main.dart" ]; then
                pushd example
                export FLUTTER_SDK=$("$THIS_SCRIPT_DIR"/find-flutter-sdk)
                flutter build apk
                popd
            else
                echo "Skipping Android example build, no Flutter example in ${PWD} package" >&2
            fi
            ;;
        "example-ios")
            if [ -e "example/lib/main.dart" ]; then
                pushd example
                export FLUTTER_SDK=$("$THIS_SCRIPT_DIR"/find-flutter-sdk)
                flutter build ios --no-codesign
                popd
            else
                echo "Skipping iOS example build, no Flutter example in ${PWD} package" >&2
            fi
            ;;
        *)
            echo "Unknown task $task" >&2
            return 1
            ;;
    esac
    echo ""
}

if [ "${#TASKS[@]}" -eq 0 ]; then
    TASKS=(pub-get test analyze pana gradle-check example-android)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        TASKS=("${TASKS[@]}" example-ios)
    fi
fi

if [ "${#DIRECTORIES[@]}" -eq 0 ]; then
    DIRECTORIES=("$PWD")
fi

for DIR in "${DIRECTORIES[@]}"; do
    pushd "$DIR"
    for TASK in "${TASKS[@]}"; do
        exec_task "$TASK"
    done
    popd
done
