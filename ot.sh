#!/usr/bin/env bash

FILE="$1"
TIME="$2"

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

ot=$(python3 -c "
t = '$TIME'.replace(',', ';').replace(';', ':').split(':')[::-1]
print(sum(int(p) * w for p, w in zip(map(int, t), [1, 1000, 60000, 3600000])))
")

ffmpeg -y -i "$FILE" -ar 16000 temporary.wav

MODEL_PATH="/home/htp/ggml-large-v3.bin"

whisper-cli \
  --print-colors \
  --output-srt \
  --print-progress \
  --suppress-nst \
  --output-file temporary \
  -ot "$ot" \
  --language ru \
  --model "$MODEL_PATH" \
  temporary.wav

rm -f temporary.wav
