[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

$directoryPath = "."
$ModelPath = "C:\Users\htp\Downloads\ggml-large-v3.bin"
$allowedExtensions = @(".mp4", ".mp3", ".m4a", ".avi", ".ts", ".aac", ".ogg", ".mkv", ".wav")



Get-ChildItem -Path $directoryPath -Recurse -File | Where-Object {
    $allowedExtensions -contains $_.Extension.ToLower()
} | ForEach-Object {
    $inputFile = $_.FullName
    $outputWavFile = ".\\$baseName.wav"
    if ($_.Extension.ToLower() -ne ".wav") {
        ffmpeg -y -i $inputFile -ar 16000 $outputWavFile
    }
    
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    
    # Разбиваем файл на 10-минутные отрезки
    $outputSegmentPattern = "$baseName-segment-%03d.wav"
    ffmpeg -y -i $outputWavFile -f segment -segment_time 600 $outputSegmentPattern

    # Получаем список сегментов
    $segments = Get-ChildItem -Path ".\" -Filter "$baseName-segment-*.wav"

    foreach ($segment in $segments) {
        $outputSrtFile = ".\\$($segment.BaseName).srt"
        
        # Транскрибируем каждый сегмент
        whisper-cli --print-colors --output-srt --print-progress --suppress-nst --output-file ".\\$($segment.BaseName)" --language ru --model $ModelPath $segment.FullName
        
        # Удаляем сегмент, если он не в формате WAV
        # if ($_.Extension.ToLower() -ne ".wav") {
        #     Remove-Item -Path $segment.FullName
        # }
    }
}
