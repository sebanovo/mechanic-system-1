from __future__ import annotations

from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
import argparse


EXCLUDED_DIRS = {
    "__pycache__",
    ".git",
    ".idea",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    ".venv",
    "node_modules",
    "venv",
}

EXCLUDED_FILES = {
    ".DS_Store",
}

LANGUAGE_BY_SUFFIX = {
    ".py": "python",
    ".md": "markdown",
    ".txt": "text",
    ".json": "json",
    ".toml": "toml",
    ".yaml": "yaml",
    ".yml": "yaml",
    ".ini": "ini",
    ".cfg": "ini",
    ".sh": "bash",
    ".sql": "sql",
    ".env": "dotenv",
}


def parse_args() -> argparse.Namespace:
    script_path = Path(__file__).resolve()
    backend_root = script_path.parents[1]
    default_output = backend_root.parent / "mechanic-api-backend.md"

    parser = argparse.ArgumentParser(
        description=(
            "Genera un archivo Markdown con la estructura y el contenido "
            "completo del backend mechanic-api."
        )
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=backend_root,
        help="Ruta de la carpeta backend a exportar.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=default_output,
        help="Ruta del archivo Markdown de salida.",
    )
    return parser.parse_args()


def should_skip(path: Path, output_path: Path) -> bool:
    if path.name in EXCLUDED_FILES:
        return True
    if path.resolve() == output_path.resolve():
        return True
    return any(part in EXCLUDED_DIRS for part in path.parts)


def iter_files(root: Path, output_path: Path) -> list[Path]:
    files: list[Path] = []
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if should_skip(path, output_path):
            continue
        files.append(path)
    return files


def build_tree_lines(root: Path, output_path: Path) -> list[str]:
    def walk(directory: Path, prefix: str = "") -> list[str]:
        entries = [
            entry
            for entry in sorted(directory.iterdir(), key=lambda item: (item.is_file(), item.name.lower()))
            if not should_skip(entry, output_path)
        ]

        lines: list[str] = []
        for index, entry in enumerate(entries):
            connector = "└── " if index == len(entries) - 1 else "├── "
            lines.append(f"{prefix}{connector}{entry.name}")
            if entry.is_dir():
                extension = "    " if index == len(entries) - 1 else "│   "
                lines.extend(walk(entry, prefix + extension))
        return lines

    return [root.name, *walk(root)]


def summarize_structure(files: list[Path], root: Path) -> list[str]:
    suffix_counter = Counter(path.suffix.lower() or "<sin_extension>" for path in files)
    top_level_counter = Counter(path.relative_to(root).parts[0] for path in files)

    summary = [
        f"- Carpeta exportada: `{root}`",
        f"- Total de archivos incluidos: `{len(files)}`",
        f"- Extensiones detectadas: `{len(suffix_counter)}`",
        "- Distribucion por extension:",
    ]

    for suffix, count in sorted(suffix_counter.items(), key=lambda item: (-item[1], item[0])):
        summary.append(f"  - `{suffix}`: {count}")

    summary.append("- Distribucion por area principal:")
    for area, count in sorted(top_level_counter.items(), key=lambda item: (-item[1], item[0])):
        summary.append(f"  - `{area}`: {count} archivos")

    return summary


def detect_language(path: Path) -> str:
    if path.name.startswith(".env"):
        return "dotenv"
    return LANGUAGE_BY_SUFFIX.get(path.suffix.lower(), "text")


def read_text_file(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def render_markdown(root: Path, files: list[Path], output_path: Path) -> str:
    generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    tree = "\n".join(build_tree_lines(root, output_path))
    summary_lines = "\n".join(summarize_structure(files, root))

    parts = [
        "# Export completo del backend `mechanic-api`",
        "",
        f"- Generado el: `{generated_at}`",
        f"- Archivo de salida: `{output_path}`",
        "",
        "## Infraestructura y organizacion",
        "",
        summary_lines,
        "",
        "## Arbol de directorios",
        "",
        "```text",
        tree,
        "```",
        "",
        "## Codigo completo por archivo",
        "",
    ]

    for file_path in files:
        relative_path = file_path.relative_to(root.parent).as_posix()
        language = detect_language(file_path)
        content = read_text_file(file_path)

        parts.extend(
            [
                f"### `{relative_path}`",
                "",
                f"- Ruta relativa: `{relative_path}`",
                f"- Nombre de archivo: `{file_path.name}`",
                "",
                f"```{language}",
                content.rstrip(),
                "```",
                "",
            ]
        )

    return "\n".join(parts).rstrip() + "\n"


def main() -> None:
    args = parse_args()
    root = args.root.resolve()
    output_path = args.output.resolve()

    if not root.exists() or not root.is_dir():
        raise SystemExit(f"La carpeta backend no existe o no es valida: {root}")

    files = iter_files(root, output_path)
    markdown = render_markdown(root, files, output_path)
    output_path.write_text(markdown, encoding="utf-8")

    print(f"Archivo Markdown generado en: {output_path}")
    print(f"Archivos exportados: {len(files)}")


if __name__ == "__main__":
    main()
