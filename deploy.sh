#!/bin/bash

set -euo pipefail

PLUGIN_ID="smart-connections"
BUILD_DIR="obsidian-smart-connections"
DIST_DIR="$BUILD_DIR/dist"
RESOLVED_DEST=""

usage() {
    echo "Usage: ./deploy.sh <vault_path|.obsidian_path|plugins_path|plugin_path>"
    echo "Examples:"
    echo "  ./deploy.sh /path/to/Vault"
    echo "  ./deploy.sh /path/to/Vault/.obsidian.desktop"
    echo "  ./deploy.sh /path/to/Vault/.obsidian.desktop/plugins"
    echo "  ./deploy.sh /path/to/Vault/.obsidian.desktop/plugins/$PLUGIN_ID"
}

resolve_destination() {
    local input_path="$1"
    local base_name
    base_name="$(basename "$input_path")"

    if [ ! -d "$input_path" ]; then
        echo "Error: Path '$input_path' not found" >&2
        exit 1
    fi

    if [ "$base_name" = "$PLUGIN_ID" ]; then
        RESOLVED_DEST="$input_path"
        return
    fi

    if [ "$base_name" = "plugins" ]; then
        RESOLVED_DEST="$input_path/$PLUGIN_ID"
        return
    fi

    if [[ "$base_name" == .obsidian* ]]; then
        RESOLVED_DEST="$input_path/plugins/$PLUGIN_ID"
        return
    fi

    local obsidian_dirs=()
    while IFS= read -r dir; do
        obsidian_dirs+=("$dir")
    done < <(find "$input_path" -maxdepth 1 -mindepth 1 -type d -name ".obsidian*" | sort)

    if [ ${#obsidian_dirs[@]} -eq 0 ]; then
        echo "Error: No .obsidian* folder found in '$input_path'" >&2
        echo "Pass the vault root, an .obsidian folder, a plugins folder, or the plugin folder directly." >&2
        exit 1
    fi

    if [ ${#obsidian_dirs[@]} -eq 1 ]; then
        RESOLVED_DEST="${obsidian_dirs[0]}/plugins/$PLUGIN_ID"
        return
    fi

    echo ""
    echo "Select an Obsidian config folder:"
    echo "--------------------------------"
    local i=1
    for dir in "${obsidian_dirs[@]}"; do
        echo "  $i) $(basename "$dir")"
        ((i++))
    done
    echo ""

    local choice
    read -r -p "Enter number: " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#obsidian_dirs[@]} ]; then
        echo "Invalid choice" >&2
        exit 1
    fi

    RESOLVED_DEST="${obsidian_dirs[$((choice-1))]}/plugins/$PLUGIN_ID"
}

ensure_build_dependencies() {
    local build_dir="$1"
    local needs_install=0

    if [ ! -d "$build_dir/node_modules" ]; then
        needs_install=1
    elif [ ! -d "$build_dir/node_modules/esbuild" ]; then
        needs_install=1
    fi

    if [ "$needs_install" -eq 0 ]; then
        return
    fi

    echo ""
    echo "Installing build dependencies in $build_dir..."
    if [ -f "$build_dir/package-lock.json" ]; then
        (cd "$build_dir" && npm ci)
    else
        (cd "$build_dir" && npm install)
    fi
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

TARGET_PATH="${1%/}"
resolve_destination "$TARGET_PATH"
ensure_build_dependencies "$BUILD_DIR"

echo ""
echo "Building plugin..."
(cd "$BUILD_DIR" && npm run build)

echo ""
echo "Deploying to: $RESOLVED_DEST"

mkdir -p "$RESOLVED_DEST"

cp "$DIST_DIR/main.js" "$RESOLVED_DEST/"
cp "$DIST_DIR/manifest.json" "$RESOLVED_DEST/"
cp "$DIST_DIR/styles.css" "$RESOLVED_DEST/" 2>/dev/null || true

if [ ! -f "$RESOLVED_DEST/.hotreload" ]; then
    : > "$RESOLVED_DEST/.hotreload"
fi

echo "Done! Plugin deployed to $RESOLVED_DEST"
