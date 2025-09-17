import pathlib
import subprocess
import os
import sys

CONST_PART = 10


def split_media_into_10_parts(input_file, output_dir="output_parts"):
    output_dir = pathlib.Path(input_file).stem
    if not os.path.exists(input_file):
        raise FileNotFoundError(f"Файл '{input_file}' не найден")

    # Создаём папку для частей
    os.makedirs(output_dir, exist_ok=True)

    # Узнаём длительность файла с помощью ffprobe
    result = subprocess.run(
        ["ffprobe", "-v", "error",
         "-show_entries", "format=duration",
         "-of", "default=noprint_wrappers=1:nokey=1",
         input_file],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    duration = float(result.stdout.strip())
    print(f"Длительность файла: {duration:.2f} секунд")

    # Длительность одного сегмента
    part_duration = duration / CONST_PART

    # Запускаем ffmpeg для каждого куска
    for i in range(CONST_PART):
        start_time = part_duration * i
        output_file = os.path.join(output_dir, f"part_{i + 1}.mp4")

        # ffmpeg команда
        subprocess.run([
            "ffmpeg",
            "-y",  # перезаписывать без запроса
            "-i", input_file,  # входной файл
            "-ss", str(start_time),  # начало куска
            "-t", str(part_duration),  # длительность куска
            "-c", "copy",  # копируем без перекодирования (быстро!)
            output_file
        ])

        print(f"Часть {i + 1} сохранена как {output_file}")


if __name__ == "__main__":
    split_media_into_10_parts(sys.argv[1])
