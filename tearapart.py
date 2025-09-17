import pathlib
import subprocess
import os
import sys

def split_media_into_10_parts(input_file):
    output_dir = pathlib.Path(input_file).stem
    if not os.path.exists(input_file):
        raise FileNotFoundError(f"File '{input_file}' is not found")

    os.makedirs(output_dir, exist_ok=True)

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
    print(f"Duration: {duration:.2f} seconds")

    if duration > 120:
        CONST_PART = 10
        part_duration = duration / CONST_PART
    elif duration > 60 and duration < 120:
        CONST_PART = 5
        part_duration = duration / CONST_PART
    elif duration > 30 and duration < 60:
        CONST_PART = 3
        part_duration = duration / CONST_PART
    else:
        CONST_PART = 2
        part_duration = duration / CONST_PART


    for i in range(CONST_PART):
        start_time = part_duration * i
        output_file = os.path.join(output_dir, f"part_{i + 1}.mp4")

        # ffmpeg команда
        subprocess.run([
            "ffmpeg",
            "-y",
            "-i", input_file,
            "-ss", str(start_time),
            "-t", str(part_duration),
            "-c", "copy",
            output_file
        ])

        print(f"Part {i + 1} saved as {output_file}")


if __name__ == "__main__":
    if sys.argv[1] is None:
        for file in os.listdir("."):
            if file.endswith("mp4"):
                split_media_into_10_parts(file)
    else:
        split_media_into_10_parts(sys.argv[1])
