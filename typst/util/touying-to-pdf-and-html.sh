#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TYPST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="out"

echo "Building dockerfile-touying-exporter container"
IMAGE_ID="$(docker build -f $SCRIPT_DIR/Dockerfile-touying-exporter -t dockerfile-touying-exporter -q .)" || exit 1
echo "Done with building dockerfile-touying-exporter container"

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
    echo "Error: '$USER_INPUT_PROJECT_NAME' is not a valid project in '$USER_INPUT_PROJECT_NAME'"
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
docker run --rm \
    -v "$TYPST_DIR:/files" \
    -v "$HOME/.cache/typst:/home/appuser/.cache/typst" \
    -v "$TYPST_DIR/util/template.html.j2:/usr/local/lib/python3.14/site-packages/touying/template.html.j2" \
    "$IMAGE_ID" \
    touying compile \
    "/files/touying/$USER_INPUT_PROJECT_NAME/main.typ" \
    --format "html" \
    --font-paths "/files/touying/$USER_INPUT_PROJECT_NAME/theme/fonts" \
    --output "/files/$OUT_DIR/touying-$USER_INPUT_PROJECT_NAME.html"
echo "Done: $OUT_DIR/$USER_INPUT_PROJECT_NAME.html"

echo "Making PDF for project $USER_INPUT_PROJECT_NAME..."
docker run --rm \
    -v "$TYPST_DIR:/files" \
    -v "$HOME/.cache/typst:/home/appuser/.cache/typst" \
    "$IMAGE_ID" \
    touying compile \
    "/files/touying/$USER_INPUT_PROJECT_NAME/main.typ" \
    --format "pdf" \
    --font-paths "/files/touying/$USER_INPUT_PROJECT_NAME/theme/fonts" \
    --output "/files/$OUT_DIR/touying-$USER_INPUT_PROJECT_NAME.pdf"
echo "Done: $OUT_DIR/$USER_INPUT_PROJECT_NAME.pdf"