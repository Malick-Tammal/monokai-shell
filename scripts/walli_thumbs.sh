#!/bin/bash

WALLS_DIR="$HOME/Pictures/Wallpapers/"
CACHE_DIR="$HOME/.cache/monokai_shell/walli_thumbs/"

mkdir -p "$CACHE_DIR"

generate_thumbs() {
    for thumb in "$CACHE_DIR"/*; do
        [ -e "$thumb" ] || continue

        name=$(basename "$thumb")

        if [ ! -f "$WALLS_DIR/$name" ]; then
            rm -f "$thumb"
        fi
    done

    local missing_thumbs=()
    while IFS= read -r -d '' img; do
        name=$(basename "$img")
        thumb="$CACHE_DIR/$name"

        if [ ! -f "$thumb" ]; then
            missing_thumbs+=("$img")
        fi
    done < <(find "$WALLS_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) -print0)

    local total=${#missing_thumbs[@]}

    if [ "$total" -eq 0 ]; then
        exit 0
    fi

    echo "STATUS:DETECTED"

    local count_file
    local lock_file
    count_file=$(mktemp)
    lock_file=$(mktemp)
    echo 0 >"$count_file"

    gen_one() {
        local img=$1
        local name
        local thumb

        name=$(basename "$img")
        thumb="$CACHE_DIR/$name"

        nice -n 19 magick "${img}[0]" -strip -scale 800x500^ -gravity center -extent 800x500 "$thumb"
        touch -r "$img" "$thumb"

        flock "$lock_file" sh -c '
            count=$(cat "$count_file")
            count=$((count + 1))
            echo "$count" > "$count_file"
            echo "STATUS:GENERATING:$count:$total"
        '
    }

    export -f gen_one
    export CACHE_DIR count_file lock_file total

    printf '%s\0' "${missing_thumbs[@]}" | xargs -0 -P "$(nproc)" -I{} bash -c 'gen_one "$@"' _ {}

    rm -f "$count_file" "$lock_file"
}

generate_thumbs
