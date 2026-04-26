#!/bin/bash
set -euo pipefail
export LANG=C.UTF-8

DIRECTORY_PATH="."
MODEL_PATH="/home/htp/ggml-large-v3.bin"
VAD_MODEL_PATH="/home/htp/ggml-silero-v6.2.0.bin"

EXTENSIONS='mp4|mp3|m4a|avi|ts|aac|ogg|mkv'
LOG_FILE="./transcribe.log"

process_file () {
    local input_file="$1"

    # Абсолютный путь к исходному файлу
    local abs_input
    abs_input=$(realpath "$input_file")

    local dir_path
    dir_path=$(dirname "$abs_input")

    local base_name
    base_name=$(basename "$abs_input")
    local base_name_no_ext="${base_name%.*}"

    local output_file="${dir_path}/${base_name_no_ext}.srt"

    # Пропускаем, если уже есть итоговый файл
    if [[ -f "$output_file" ]]; then
        echo "[SKIP] Exists: $output_file"
        return 0
    fi

    echo "[START] $input_file"
    echo "[OUT]   $output_file"

    {
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
            --output-file "${output_file%.srt}" \
            --language ru \
            --print-progress \
            -
    }

    echo "[DONE]  $input_file"
}

export -f process_file
export MODEL_PATH
export VAD_MODEL_PATH
export LOG_FILE

# Создаём лог-файл, если его нет
touch "$LOG_FILE"

# Обрабатываем только новые/изменённые файлы:
# - если рядом уже есть .srt и он новее или такой же как входной файл — пропускаем
find "$DIRECTORY_PATH" -type f \
    -regextype posix-extended \
    -iregex ".*\.(${EXTENSIONS})$" \
    -print0 | \
xargs -0 -I{} -P 1 bash -c '
    input_file="$1"
    abs_input=$(realpath "$input_file")
    out="${abs_input%.*}.srt"

    if [[ -f "$out" && "$out" -nt "$abs_input" ]]; then
        echo "[UP-TO-DATE] $input_file"
        exit 0
    fi

    process_file "$input_file"
' _ "{}"
