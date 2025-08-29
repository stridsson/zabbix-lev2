#!/usr/bin/env python3
from pathlib import Path

# ANSI escape codes
GREEN = "\033[32m"
RED_BOLD = "\033[1;31m"
RESET = "\033[0m"

def color_line(line: str) -> str:
    if "Выполнено" in line:
        return f"{GREEN}{line}{RESET}"
    elif "Ошибка" in line or "квалификация" in line:
        return f"{RED_BOLD}{line}{RESET}"
    return line

def main():
    report_path = Path("/tmp/report.txt")
    if not report_path.exists():
        print("Файл /tmp/report.txt не найден")
        return

    with report_path.open(encoding="utf-8") as f:
        for line in f:
            print(color_line(line.rstrip()))

if __name__ == "__main__":
    main()
