#!/bin/bash

WALLS_DIR="$HOME/Pictures/Wallpapers/"
CACHE_DIR="$HOME/.cache/walli_thumbs/"

mkdir -p "$CACHE_DIR"

generate_thumbs() {
    # Clean up old thumbnails
    for thumb in "$CACHE_DIR"/*; do
        [ -e "$thumb" ] || continue

        name=$(basename "$thumb")

        if [ ! -f "$WALLS_DIR/$name" ]; then
            rm -f "$thumb"
        fi
    done

    # Find missing thumbnails
    local missing_thumbs=()
    while IFS= read -r -d '' img; do
        name=$(basename "$img")
        thumb="$CACHE_DIR/$name"

        if [ ! -f "$thumb" ]; then
            missing_thumbs+=("$img")
        fi
    done < <(find "$WALLS_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) -print0)

    # Check if we have anything to do
    local total=${#missing_thumbs[@]}

    if [ "$total" -eq 0 ]; then
        exit 0
    fi

    # We found new wallpapers, tell UI to show overlay
    echo "STATUS:DETECTED"

    # Generate missing thumbnails and output progress
    local current=1
    for img in "${missing_thumbs[@]}"; do
        echo "STATUS:GENERATING:$current:$total"

        name=$(basename "$img")
        thumb="$CACHE_DIR/$name"

        nice -n 19 magick "${img}[0]" -strip -scale 800x500^ -gravity center -extent 800x500 "$thumb"
        touch -r "$img" "$thumb"

        ((current++))
    done
}

generate_thumbs
