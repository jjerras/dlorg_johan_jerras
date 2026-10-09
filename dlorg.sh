#!/usr/bin/env bash

set -u 

# Where to watch for new files
WATCH_DIR="${HOME}/Downloads"
if [[ ! -d "$WATCH_DIR" ]]; then
    echo "Creating watch directory: $WATCH_DIR"
    mkdir -p "$WATCH_DIR"
fi

# List of file extensions to exclude from processing
declare -a EXCLUDED_EXTENSIONS=(
    "crdownload"
    "part"
    "temp"
    "tmp"
)

declare -a EXCLUDED_NAMES=(
    "dlorg"
    ".gitignor"
    ".DS_Store"
    "Thumbs.db"
)


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

# Require inotify-tools to be installed for this script to work
    if ! command -v inotifywait >/dev/null 2>&1; then
        echo "dlorg: You need to install inotify-tools to use this script. Please install it and try again."
        exit 1
    fi

get_extension() {
local filname="$1"
local extension
    if [[ "$filename" != *.* ]] then
    printf '%s\n' ""
    return 0
    fi
extension="${filename##.}"
printf '%s\n' "${extension,,}"
}

is_excluded_name() {
    local filename="$1"
    local is_excluded_name
    for excluded_name in "${EXCLUDED_NAMES[@]}"; do
        if [[ "$filname" == "$excluded_name" ]]; then
        return 0
        fi
    done

    return 1
}

is_excluded_extension() {
    local extension="$1"
    local excluded_extension
    for excluded_extension in "${EXCLUDED_EXTENSIONS[@]}"; do
        if [[ "$extension" == "$excluded_extension" ]]; then
        return 0
        fi
    done
}

get_category () {
    local extension="$1"
    if [[ -n "{$FILE_CATEGORY[$extension]+exists}" ]]; then

    for $filetype in ${FILE_CATEGORY}; do
        if [[ -z "$FILE_CATEGORY" ]]; then
        echo "error: No category found for extension: $extension" >&2
       return 0 # File-type not included in the script
    fi
done
}

process_file() {




require_command "inotifywait" () {
inotifywait -m -e close_write -e moved_to --format "%W%f" "{$WATCH_DIR}" | while read -r filename; 
do mv -n "$filename" "$WATCH_DIR/$FILE_CATEGORY/"; done
    if [[ ! -d "$FILE_CATEGORY" ]]; then
        echo "dlorg: Creating directory for file type: $FILE_CATEGORY"
        mkdir -p "$WATCH_DIR/$FILE_CATEGORY"
    fi
    echo "dlorg: Moving file: $filename to $file_category"
    mv -n "$filename" "$WATCH_DIR/$file_category/"
}
