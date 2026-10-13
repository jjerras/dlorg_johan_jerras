#!/usr/bin/env bash

set -u 

# Where to watch for new files
WATCH_DIR="${HOME}/Downloads"
FALLBACK_CATEGORY="07_other"
if [[ ! -d "$WATCH_DIR" ]]; then
    echo "Creating watch directory: $WATCH_DIR"
    mkdir -p "$WATCH_DIR"
fi
# Require inotify-tools to be installed for this script to work
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "dlorg: You need to install inotify-tools to use this script. Please install it and try again."
    exit 1
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
    ".gitignore"
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

get_extension() {
    local filename="$1"
    local extension
        if [[ "$filename" != *.* ]]; then
    return 0 # File has no extension
        fi
    extension="${filename##*.}"
    printf '%s\n' "${extension,,}"
        fi
}

is_excluded_name() {
    local filename="$1"
    local excluded_name
    for excluded_name in "${EXCLUDED_NAMES[@]}"; do
        if [[ "$filename" == "$excluded_name" ]]; then
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
    return 1
}

get_category () {
    local extension="$1"
        if [[ -n  "$extension" && -n "${FILE_CATEGORY[$extension]+exists}" ]]; then
    printf '%s\n' "${FILE_CATEGORY[$extension]}"
        else 
    printf '%s\n' "$FAllBACK_CATEGORY"
        fi
}

process_file() {
    local $file_path="$1"
    local filename extension category destination_dir
        
        if [[ ! -f "$file_path" && ! -L "$file_path" ]]; then
    return 0
        fi   

filename="$(basename -- "$file_path")"
        if is_excluded_name "$filename"; then 
    return 0
        fi

extension="$(get_extension "$filename")"
        if is_excluded_extension "$extension"; then
    return 0
        fi

category="$(get_category "$extension")"
destination_dir="$WATCH_DIR/$category"
        if [[ ! -d $destination_dir ]]; then
echo "dlorg: Creating directory for file type: $category"
mkdir -p "$destination_dir"
        fi
echo "dlorg: Moving $filename -> @category"
mv -n -- "$file_path" "$destination_dir/"
}

main () {
find "$WATCH_DIR" -maxdepth 1 -type f -print0 |
    while IFS= read -r -d '' path; do 
process_file "$path"
done

echo "dlorg: Watching $WATCH_DIR (Ctrl+C to stop)"
inotifywait -m -e close_write -e moved_to --format '%w%f' "$WATCH_DIR" |
    while IFS= read -r path; do 
process_file "$path"
done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
