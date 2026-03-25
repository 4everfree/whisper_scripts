import re
import os
from pathlib import Path
from dataclasses import dataclass

TIMECODE_RE = re.compile(
    r"^\d{2}:\d{2}:\d{2},\d{3}\s+-->\s+\d{2}:\d{2}:\d{2},\d{3}$"
)


@dataclass
class SrtBlock:
    index: int
    timecode: str
    text: str


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip().lower())


def parse_srt(path: str) -> list[SrtBlock]:
    with open(path, "r", encoding="utf-8") as file:
        content = file.read()

    raw_blocks = re.split(r"\n\s*\n", content.strip(), flags=re.MULTILINE)
    blocks = []

    for raw_block in raw_blocks:
        lines = [line.rstrip() for line in raw_block.splitlines() if line.strip()]
        if len(lines) < 3:
            continue

        if not lines[0].isdigit():
            continue

        if not TIMECODE_RE.match(lines[1]):
            continue

        index = int(lines[0])
        timecode = lines[1]
        text = " ".join(lines[2:]).strip()

        blocks.append(SrtBlock(index=index, timecode=timecode, text=text))

    return blocks


def is_prefix(short_text: str, long_text: str) -> bool:
    short_norm = normalize_text(short_text)
    long_norm = normalize_text(long_text)
    return short_norm != long_norm and long_norm.startswith(short_norm)


def is_suffix(short_text: str, long_text: str) -> bool:
    short_norm = normalize_text(short_text)
    long_norm = normalize_text(long_text)
    return short_norm != long_norm and long_norm.endswith(short_norm)


def should_drop(blocks: list[SrtBlock], index: int) -> bool:
    current = blocks[index]
    prev_block = blocks[index - 1] if index > 0 else None
    next_block = blocks[index + 1] if index < len(blocks) - 1 else None

    current_text = normalize_text(current.text)
    if not current_text:
        return True

    if prev_block and is_suffix(current.text, prev_block.text):
        return True

    if next_block and is_prefix(current.text, next_block.text):
        return True

    return False


def clean_srt_blocks(blocks: list[SrtBlock]) -> list[SrtBlock]:
    cleaned = []

    for i, block in enumerate(blocks):
        if not should_drop(blocks, i):
            cleaned.append(block)

    return cleaned


def write_srt(path: str, blocks: list[SrtBlock]) -> None:
    with open(path, "w", encoding="utf-8") as file:
        for new_index, block in enumerate(blocks, start=1):
            file.write(f"{new_index}\n")
            file.write(f"{block.timecode}\n")
            file.write(f"{block.text}\n\n")


def main(name) -> None:
    input_path = f"{name}.srt"
    output_path = f"{name}_cleaned.srt"

    blocks = parse_srt(input_path)
    cleaned = clean_srt_blocks(blocks)
    write_srt(output_path, cleaned)

    print(f"Original blocks: {len(blocks)}")
    print(f"Blocks after cleanup: {len(cleaned)}")
    print(f"Saved result to: {output_path}")


if __name__ == "__main__":
    for filename in list(Path(".").glob("*.srt")):
        main(filename.stem)