#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TYPST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="out"

mkdir -p "$TYPST_DIR/$OUT_DIR"

# Discover available packages from subdirectories (exclude OUT_DIR + util folder)
AVAILABLE_PACKAGES=()
for d in "$TYPST_DIR"/*/; do
    [[ -d "$d" ]] || continue
    folder_name=$(basename "$d")
    [[ "$folder_name" == "$OUT_DIR" || "$folder_name" == "util" ]] && continue
    AVAILABLE_PACKAGES+=("$folder_name")
done

# User should provide 2 args
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 [package] [project-name]"
    echo "Available packages: ${AVAILABLE_PACKAGES[*]}"
    exit 1
fi

USER_INPUT_PACKAGE=$1
USER_INPUT_PROJECT_NAME=$2
MAIN_FILE="$TYPST_DIR/$USER_INPUT_PACKAGE/$USER_INPUT_PROJECT_NAME/main.typ"

# Discover available projects in the selected package
AVAILABLE_PROJECTS=()
for d in "$TYPST_DIR/$USER_INPUT_PACKAGE"/*/; do
    [[ -d "$d" ]] || continue
    AVAILABLE_PROJECTS+=("$(basename "$d")")
done

# User should provide valid package
if [[ ! " ${AVAILABLE_PACKAGES[*]} " =~ " $USER_INPUT_PACKAGE " ]]; then
    echo "Error: '$USER_INPUT_PACKAGE' is not a valid package"
    echo "Available packages: ${AVAILABLE_PACKAGES[*]}"
    exit 1
fi

# User should provide valid project name
if [[ ! " ${AVAILABLE_PROJECTS[*]} " =~ " $USER_INPUT_PROJECT_NAME " ]]; then
    echo "Error: '$USER_INPUT_PROJECT_NAME' is not a valid project in '$USER_INPUT_PACKAGE'"
    echo "Available projects: ${AVAILABLE_PROJECTS[*]}"
    exit 1
fi

# User should provide main file in project folder
if [[ ! -f "$MAIN_FILE" ]]; then
    echo "Error: '$MAIN_FILE' does not exist"
    exit 1
fi

echo "Compiling $USER_INPUT_PROJECT_NAME..."

docker run --rm \
    -v "$TYPST_DIR:/files" \
    -v "$HOME/.cache/typst:/home/appuser/.cache/typst" \
    ghcr.io/typst/typst:0.15.1 \
    compile \
    "/files/$USER_INPUT_PACKAGE/$USER_INPUT_PROJECT_NAME/main.typ" \
    "/files/$OUT_DIR/$USER_INPUT_PACKAGE-$USER_INPUT_PROJECT_NAME.pdf"

echo "Done: $TYPST_DIR/$OUT_DIR/$USER_INPUT_PROJECT_NAME.pdf"
