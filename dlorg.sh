#!/usr/bin/env bash

set -u 

# Where to watch for new files
WATCH_DIR="${HOME}/Downloads"
if [[ ! -d "$WATCH_DIR" ]]; then
    echo "Creating watch directory: $WATCH_DIR"
    mkdir -p "$WATCH_DIR"
fi

declare -A FILE_CATEGORY=(
    ["docx"]="01_document"
    ["doc"]="01_document"
    ["txt"]="01_document"
    ["odt"]="01_document"
    ["rtf"]="01_document"
    ["md"]="01_document"

    ["pdf"]="02_pdf_presentation"
    ["ppt"]="02_pdf_presentation"
    ["pptx"]="02_pdf_presentation"

    ["jpg"]="03_image"
    ["jpeg"]="03_image"
    ["png"]="03_image"
    ["gif"]="03_image"
    ["bmp"]="03_image"
    ["tiff"]="03_image"

    ["mp3"]="04_audio"
    ["wav"]="04_audio"
    ["flac"]="04_audio"
    ["aac"]="04_audio"
    ["ogg"]="04_audio"
    ["m4a"]="04_audio"
    ["aiff"]="04_audio"

    ["mp4"]="05_video"
    ["mkv"]="05_video"
    ["avi"]="05_video"
    ["mov"]="05_video"
    ["flv"]="05_video"
    ["wmv"]="05_video"
    ["webm"]="05_video"

    ["csv"]="06_data"
    ["json"]="06_data"
    ["xml"]="06_data"
    ["yaml"]="06_data"
    ["yml"]="06_data"
    ["sql"]="06_data"
    ["db"]="06_data"
    ["sqlite"]="06_data"
)

# List of file extensions to exclude from processing
declare -a EXCLUDED_EXTENSION=(
    "dlorg"
    "*.crdownload"
    "*.part"
    "*.temp"
    "*.tmp"
    "*.!ut"
    "*.gitignore"
    "*.DS_Store"
    "*Thumbs.db"
)

# Require inotify-tools to be installed for this script to work
command -v inotifywait >/dev/null 2>&1; echo $?     # 0 = exists, 1 = not found
command -v find >/dev/null 2>&1; echo $?    # 1
    if ! command -v inotifywait >/dev/null 2>&1; then
        echo "dlorg: You need to install inotify-tools to use this script. Please install it and try again."
        exit 1
    fi

get_extension() {
    local filename="$1"
    extension="${filename##*/.}"
    echo "$extension"
    if [[ "$extension" != *.* ]]; then
        echo "error: No extension found for file: $filename" >&2
        return
    fi
}

is_excluded_extension() {
    local filename="$1"
    local excluded_extension
    for excluded_extension in "${EXCLUDED_EXTENSION[@]}"; do
        if [[ "$filename" == $excluded_extension ]]; then
            return 0  # Extension is excluded
        fi
done

return 1  # Extension is not excluded
}


get_file_category() {
    local extension="$1"
    local file_category="${FILE_CATEGORY[$extension]}"
    if [[ -z "$file_category" ]]; then
        echo "error: No category found for extension: $extension" >&2
        return
    fi
    echo "$file_category"
}

file_category="${FILE_CATEGORY[$extension]}"
    if [[ ! -d "$file_category" ]]; then
        echo "dlorg: Creating directory for file type: $file_category"
        mkdir -p "$WATCH_DIR/$file_category"
    fi
    echo "dlorg: Moving file: $filename to $file_category"
    mv "$filename" "$WATCH_DIR/$file_category/"
    ls -R "$WATCH_DIR"
done

find  "$WATCH_DIR" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
    filename="$file"
    if is_excluded_extension "$file"; then
        echo "dlorg: Skipping excluded file: $filename"
        continue
    fi
while IFS= read -r -d '' file; do
    filename="$file"
    extension="${filename##*.}"
    file_category="${FILE_CATEGORY[$extension]}"

require_command "inotifywait"
inotifywait -m -e close_write -e moved_to --format "%f"│"$~/hoe/{WATCH_DIR}" | while read -r filename; 
do mv "$filename" "$WATCH_DIR/$file_category/"; done



