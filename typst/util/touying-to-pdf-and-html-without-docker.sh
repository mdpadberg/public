#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TYPST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="out"
CUSTOM_HTML_TEMPLATE="$SCRIPT_DIR/template.html.j2"

for command_name in typst touying; do
    if ! command -v "$command_name" > /dev/null 2>&1; then
        echo "Error: '$command_name' is not installed or is not on PATH" >&2
        exit 1
    fi
done

TOUYING_BIN="$(command -v touying)"
TOUYING_PYTHON="$(sed -n '1s/^#!//p' "$TOUYING_BIN")"
TOUYING_TEMPLATE="$($TOUYING_PYTHON -c 'from importlib.resources import files; print(files("touying").joinpath("template.html.j2"))')"
if [[ ! -f "$TOUYING_TEMPLATE" || ! -w "$TOUYING_TEMPLATE" ]]; then
    echo "Error: Touying HTML template '$TOUYING_TEMPLATE' is not a writable file" >&2
    exit 1
fi

mkdir -p "$TYPST_DIR/$OUT_DIR"

# Discover available projects in touying (exclude theme)
AVAILABLE_PROJECTS=()
for d in "$TYPST_DIR/touying"/*/; do
    [[ -d "$d" ]] || continue
    folder_name=$(basename "$d")
    [[ "$folder_name" == "theme" ]] && continue
    AVAILABLE_PROJECTS+=("$folder_name")
done

# User should provide 1 arg
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 [project-name]"
    echo "Available project name: ${AVAILABLE_PROJECTS[*]}"
    exit 1
fi

USER_INPUT_PROJECT_NAME=$1
MAIN_FILE="$TYPST_DIR/touying/$USER_INPUT_PROJECT_NAME/main.typ"

# User should provide valid project name
if [[ ! " ${AVAILABLE_PROJECTS[*]} " =~ " $USER_INPUT_PROJECT_NAME " ]]; then
    echo "Error: '$USER_INPUT_PROJECT_NAME' is not a valid project in '$TYPST_DIR/touying'"
    echo "Available projects: ${AVAILABLE_PROJECTS[*]}"
    exit 1
fi

# User should provide main file in project folder
if [[ ! -f "$MAIN_FILE" ]]; then
    echo "Error: '$MAIN_FILE' does not exist"
    exit 1
fi

THEME_LINK="$TYPST_DIR/touying/$USER_INPUT_PROJECT_NAME/theme"

# Make theme link if it doesn't exist already
[[ ! -e "$THEME_LINK" ]] && { 
    echo "Making symlink for theme"
    cd "$TYPST_DIR/touying/$USER_INPUT_PROJECT_NAME" && ln -sf ../theme/ theme && cd - > /dev/null; 
}

echo "Making Html for project $USER_INPUT_PROJECT_NAME..."
cp "$CUSTOM_HTML_TEMPLATE" "$TOUYING_TEMPLATE"
touying compile \
    "$TYPST_DIR/touying/$USER_INPUT_PROJECT_NAME/main.typ" \
    --format "html" \
    --font-paths "$TYPST_DIR/touying/$USER_INPUT_PROJECT_NAME/theme/fonts" \
    --output "$TYPST_DIR/$OUT_DIR/touying-$USER_INPUT_PROJECT_NAME.html"
echo "Done: $OUT_DIR/touying-$USER_INPUT_PROJECT_NAME.html"

echo "Making PDF for project $USER_INPUT_PROJECT_NAME..."
touying compile \
    "$TYPST_DIR/touying/$USER_INPUT_PROJECT_NAME/main.typ" \
    --format "pdf" \
    --font-paths "$TYPST_DIR/touying/$USER_INPUT_PROJECT_NAME/theme/fonts" \
    --output "$TYPST_DIR/$OUT_DIR/touying-$USER_INPUT_PROJECT_NAME.pdf"
echo "Done: $OUT_DIR/touying-$USER_INPUT_PROJECT_NAME.pdf"