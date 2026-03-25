#!/bin/bash
set -x
set -e
export LANG=C.UTF-8

DIRECTORY_PATH="."

MODEL_PATH="~/ggml-large-v3.bin"
VAD_MODEL_PATH="~/ggml-silero-v6.2.0.bin"

EXTENSIONS="mp4|mp3|m4a|avi|ts|aac|ogg|mkv"

process_file () {

    input_file="$1"

    base_name=$(basename "$input_file")
    base_name_no_ext="${base_name%.*}"

    dir_path=$(dirname "$input_file")
    current_dir_name=$(basename "$dir_path")

    mkdir -p "$current_dir_name"

    output_whisper_path="${current_dir_name}/${base_name_no_ext}"

    echo "Processing: $input_file"

    ffmpeg -nostdin -loglevel error -i "$input_file" \
        -ar 16000 \
        -ac 1 \
        -f wav - \
    | whisper-cli \
        --model "$MODEL_PATH" \
        --print-colors \
        --flash-attn \
        --vad \
        -vm "$VAD_MODEL_PATH" \
        --output-srt \
        --output-file "$output_whisper_path" \
        --language ru \
        --print-progress \
        -
}

export -f process_file
export MODEL_PATH
export VAD_MODEL_PATH

find "$DIRECTORY_PATH" -type f \
-regextype posix-extended \
-regex ".*\.($EXTENSIONS)$" \
-print0 | \
xargs -0 -I{} -P 2 bash -c 'process_file "$@"' _ {}
