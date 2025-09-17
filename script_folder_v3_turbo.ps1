[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")
[Console]::InputEncoding = [System.Text.Encoding]::GetEncoding("utf-8")

$directoryPath = "."
$ModelPath = "C:\Users\htp\Downloads\ggml-large-v3-turbo.bin"
$allowedExtensions = @(".mp4", ".mp3", ".m4a", ".avi", ".ts",".aac",".ogg",".mkv")
Get-ChildItem -Path $directoryPath -Recurse -File | Where-Object {
    $allowedExtensions -contains $_.Extension.ToLower()
} | ForEach-Object {
    $inputFile = $_.FullName
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $currentFileDirectoryName = (($_.DirectoryName).Split("\")[-1])
    $outputWavFile = "$currentFileDirectoryName\\$baseName.wav"
    
    ffmpeg -i $inputFile -ar 16000 $outputWavFile

    whisper-cli --print-colors --output-srt --print-progress --suppress-nst --output-file $currentFileDirectoryName\\$baseName --language ru --model $ModelPath $outputWavFile
    
    if ($_.Extension.ToLower() -ne ".wav") {
        Remove-Item -Path $outputWavFile
    }
}