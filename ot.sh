#!/usr/bin/env bash

# how to execute:  ./ot.sh  "name.mp4" "00:00:00:00,000"
FILE="$1"
TIME="$2"

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

if [ -z "$TIME" ]; then
  echo "Error: No time argument set!"
  exit 1
fi

export TIME
ot=$(python3 -c "
import os
t = os.environ['TIME'].replace(',', ';').replace(';', ':').split(':')[::-1]
weights = [1, 1000, 60000, 3600000]
print(sum(int(p) * w for p, w in zip(map(int, t), weights[:len(t)])))
")

echo "Time offset (ms): $ot"

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
