param(
    [string]$File,
    [String]$Time
)

[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

$ot = python -c "print(sum(int(p)*w for p,w in zip(map(int, '$Time'.replace(',',';').replace(';',':').split(':')[::-1]), [1,1000,60000,3600000])))"
$ot = $ot.Trim()
ffmpeg -y -i "$File" -ar 16000 temporary.wav
$ModelPath = "C:\Users\htp\Downloads\ggml-large-v3.bin"
whisper-cli --print-colors --output-srt --print-progress --suppress-nst `
    --output-file temporary -ot $ot --language ru --model $ModelPath temporary.wav
Remove-Item -Path temporary.wav