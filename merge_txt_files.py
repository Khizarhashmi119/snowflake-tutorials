"""
merge_txt_files.py
------------------
Recursively traverses a folder, finds all .txt files,
and merges their contents into a single output file.

Usage:
    python merge_txt_files.py <input_folder> <output_file>

Examples:
    python merge_txt_files.py ./documents merged_output.txt
    python merge_txt_files.py /home/user/notes all_notes.txt
"""

import argparse
import os
import sys
from datetime import datetime
from pathlib import Path


def find_txt_files(root_folder: str) -> list[Path]:
    """
    Recursively walk the directory tree and collect all .txt file paths,
    sorted alphabetically for deterministic output.
    """
    root = Path(root_folder)
    if not root.exists():
        raise FileNotFoundError(f"Folder not found: {root_folder}")
    if not root.is_dir():
        raise NotADirectoryError(f"Path is not a directory: {root_folder}")

    txt_files = sorted(
        root.rglob("*.txt"),
        key=lambda x: (
            int(str(x).split(" - ")[0].split("/")[-1].split(" ")[-1]),
            int(str(x).split("/")[-2].split(" ")[0]),
        ),
    )

    return txt_files


def merge_files(
    txt_files: list[Path],
    output_path: str,
    add_separator: bool = True,
    encoding: str = "utf-8",
) -> int:
    """
    Merge the contents of all txt_files into a single output file.

    Args:
        txt_files:     List of Path objects to merge.
        output_path:   Destination file path.
        add_separator: When True, insert a header banner between files.
        encoding:      Text encoding to use (default utf-8).

    Returns:
        Number of files successfully merged.
    """
    merged_count = 0
    errors = []

    with open(output_path, "w", encoding=encoding) as out_f:
        # Write a top-level header
        out_f.write(
            f"-- Merged TXT Files\n"
            f"-- Generated : {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
            f"-- Total files: {len(txt_files)}\n"
            f"--{'=' * 60}\n\n"
        )

        for file_path in txt_files:
            if add_separator:
                out_f.write(f"\n--{'=' * 60}\n")
                out_f.write(f"-- FILE: {file_path}\n")
                out_f.write(f"--{'=' * 60}\n\n")

            try:
                content = file_path.read_text(encoding=encoding, errors="replace")
                out_f.write(content)
                # Ensure every file ends with a newline before the next separator
                if content and not content.endswith("\n"):
                    out_f.write("\n")
                merged_count += 1
                print(f"  [OK]  {file_path}")
            except Exception as exc:
                error_msg = f"  [ERROR] {file_path}: {exc}"
                print(error_msg)
                errors.append(error_msg)
                out_f.write(f"-- [ERROR reading file: {exc}]\n")

    if errors:
        print(f"\nWarning: {len(errors)} file(s) could not be read:")
        for e in errors:
            print(e)

    return merged_count


def main():
    parser = argparse.ArgumentParser(
        description="Recursively merge all .txt files in a folder into one file."
    )

    parser.add_argument(
        "input_folder",
        help="Root folder to search for .txt files",
    )

    parser.add_argument(
        "output_file",
        nargs="?",
        default="merged_output.sql",
        help="Path for the merged output file (default: merged_output.sql)",
    )

    parser.add_argument(
        "--no-separator",
        action="store_true",
        help="Omit the file-name separator banners between files",
    )

    parser.add_argument(
        "--encoding",
        default="utf-8",
        help="Text encoding to use when reading/writing files (default: utf-8)",
    )

    args = parser.parse_args()

    print(f"\nSearching for .txt files in: {args.input_folder}")
    print("-" * 50)

    try:
        txt_files = find_txt_files(args.input_folder)
    except (FileNotFoundError, NotADirectoryError) as exc:
        print(f"Error: {exc}")
        sys.exit(1)

    if not txt_files:
        print("No .txt files found. Nothing to merge.")
        sys.exit(0)

    print(f"Found {len(txt_files)} .txt file(s):\n")
    for f in txt_files:
        print(f"  {f}")

    print(f"\nMerging into: {args.output_file}\n")

    merged = merge_files(
        txt_files,
        args.output_file,
        add_separator=not args.no_separator,
        encoding=args.encoding,
    )

    print(f"\nDone! {merged}/{len(txt_files)} files merged → {args.output_file}")


if __name__ == "__main__":
    main()
