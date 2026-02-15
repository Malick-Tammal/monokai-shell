#!/bin/bash

WALLS_DIR="$HOME/Pictures/Wallpapers/"
CACHE_DIR="$HOME/.cache/walli_thumbs/"

mkdir -p "$CACHE_DIR"

generate_thumbs() {
    find "$WALLS_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" \) -print0 |
        while IFS= read -r -d '' img; do
            name=$(basename "$img")
            thumb="$CACHE_DIR/${name}.png"

            # Only generate if missing
            if [ ! -f "$thumb" ]; then
                nice -n 19 magick "${img}[0]" -strip -scale 400x450^ -gravity center -extent 400x450 "$thumb"
            fi
        done
}

generate_thumbs &
