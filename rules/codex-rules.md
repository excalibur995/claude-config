# Token Optimization Rules

## File Reading — Lean Read

Never read a file in full when you only need part of it.

- Run `wc -l path/to/file` before reading
- Under 80 lines → read freely
- 80–300 lines → grep first, then read only the relevant section
- Over 300 lines → grep is mandatory; use offset+limit only
- Grep for the target symbol first: `grep -n "functionName" path/to/file`
- Read only 40–60 lines around the match, not from line 1
- Do NOT read a file just to "get familiar" with it
- Do NOT read the same file twice — use already-loaded content

## Codebase Exploration — Lean Explore

Use grep and find before opening any file.

- To understand structure: `find src/ -name "*.ts" | head -40` — never read index files to discover what exists
- To find a function/type: `grep -rn "functionName" src/ --include="*.ts"`
- Use `-l` first to get filenames only, then grep the specific file for line numbers
- Read only the confirmed file at the confirmed line (40–60 lines max)
- Stop when you have enough — unexplored files cost zero tokens
- Do NOT read multiple files to "build a mental model"
- Do NOT explore "just in case"

## No Re-Reading

Before reading any file, check if it was already loaded in context this session.

- If file content was shown in a previous tool result → do NOT re-read
- If you edited the file → re-read only the edited section (grep + offset, not full read)
- If no edits were made → the previously loaded version is still valid
- Never re-read a file to "confirm" a value already seen in context

## Command Output — Output Filter

Before running any command that could return more than 50 lines, apply a cap or filter.

Hard cap:
```
git log --oneline | head -20
find . -name "*.ts" | head -30
npm list --depth=0
```

Filter:
```
git log --oneline --grep="fix|feat" | head -20
find . -type f | grep -v "node_modules|dist|.git"
```

High-risk commands — always use safe versions:
- `git log` → `git log --oneline -15`
- `git diff` → `git diff --stat` or diff a specific file
- `find .` → `find src/ -name "*.ts" | head -30`
- `npm list` → `npm list --depth=0`
- `ls -la` recursively → `find . -maxdepth 2 -type f`

Absolute prohibitions:
- Never `cat` or read `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Never run `find .` without `-maxdepth` or `| head`
- Never run `git log` without `-n` or `| head`
- Never run `npm list` without `--depth=0`

## Document Conversion — Convert Doc

When asked to read `.docx`, `.odt`, `.html`, `.xml`, `.rst`, `.latex`, or `.pdf`:

1. Check dependency first:
   - `which pandoc` (for DOCX/HTML/XML/RST/LATEX)
   - `which pdftotext` (for PDF)
2. If missing — stop and tell the user to install it. Do NOT read the raw file as fallback.
3. Convert to markdown:
   - DOCX/HTML/XML/RST/LATEX: `pandoc "input" -t markdown -o "input_temp.md"`
   - PDF: `pdftotext "input.pdf" "input_temp.md"`
4. Read the `_temp.md` file
5. After answering, delete: `rm "input_temp.md"`

Install instructions if missing:
- pandoc: `brew install pandoc` / `sudo apt install pandoc`
- pdftotext: `brew install poppler` / `sudo apt install poppler-utils`

## Subagent / Tool Use Discipline — Agent Brief

When spawning any subagent or parallel tool call:

- Specify exact files or directories — not "explore the codebase"
- Ask a specific question — not "understand how X works"
- Always cap response length: "report under 150 words" or "return only: [format]"
- Pass known context — do NOT make agents rediscover what you already know
- Do NOT spawn agents for tasks solvable with one tool call (grep, single file read, known command)

Prompt template:
```
Context: [1-2 sentences of what you already know]
Task: [specific question or action]
Scope: look only at [specific files/dirs]
Return: [exact format], under [N] words. Nothing else.
```

## Repo Index — Build Once, Read Always

At the start of any session in a large or unfamiliar repo, check for `CLAUDE_INDEX.md` at the repo root first.

- If it exists → read it instead of running find/ls to orient yourself
- If it does not exist → build it from these commands only (no file reads):
  ```
  ls -1
  find . -maxdepth 2 -type d | grep -v "node_modules|\.git|dist|build|vendor|__pycache__" | sort
  find . -name "main.*" -o -name "index.*" -o -name "app.*" -o -name "server.*" | grep -v "node_modules|dist|build" | head -15
  find . -maxdepth 2 -name "*.config.*" -o -name ".env*" | grep -v "node_modules" | head -10
  ```
  Write a compact `CLAUDE_INDEX.md` (under 150 lines): stack, module map, entry points, conventions, key config files.

**After completing any task that causes a structural change, update `CLAUDE_INDEX.md` immediately — do not wait for the user to ask.**

What requires an update:
- Created a new file in a new directory → add to module map
- Created a new module/feature → add row to module map with path and key files
- Moved or renamed a file → update path in module map / entry points
- Deleted a module → remove from module map
- Added a new config file → add to key config files
- Established a new convention → add to conventions section

What does NOT require an update:
- Editing existing files without moving them
- Bug fixes within an existing module
- Adding a function inside an existing file

When updating: edit only the affected section + update the `_last updated` date. Never rewrite the whole file.

## Refactor Map — Grep Before You Read

Before touching any file in a refactor:

1. Define the change in one line: "I am changing X from old to new"
2. Grep the full blast radius (exclude noise):
   `grep -rln "thingBeingChanged" . | grep -v "node_modules\|dist\|build\|vendor\|\.git"`
3. Find and change the contract definition first (type/interface/struct/schema/class) — let the compiler or linter surface everything else
4. Read files one at a time, only as you reach them — never read ahead
5. For simple renames, do not read the whole file:
   `grep -n "oldName" path/to/file` → read 10–15 lines around the match → change

Common blast-radius greps (works for any language):
- Rename function/method: `grep -rln "oldFuncName" .`
- Add field to model/type: `grep -rln "ModelName" .`
- Change function signature: `grep -rln "funcName(" .`
- Move file: `grep -rln "from.*old/path\|import.*old/path\|require.*old/path" .`
- Rename env var: `grep -rln "OLD_VAR_NAME" .`
- Change API path: `grep -rln /old/endpoint .`

Never read consumer files speculatively. Grep gives you the list; compiler/test errors tell you what to fix.

## Spreadsheet Conversion — Convert Spreadsheet

When asked to read `.xlsx`, `.xls`, `.ods`, `.numbers`, or `.gnumeric`:

1. Check dependencies first:
   - `which xlsx2csv` (primary for xlsx)
   - `which in2csv` (part of csvkit — handles xlsx, xls, ods)
   - `which ssconvert` (fallback for ods/xls)
2. If none available — stop and tell the user to install. Do NOT read the raw binary file.
3. List sheets first — never assume sheet count or names:
   - `xlsx2csv --list-sheets "file.xlsx"`
   - `in2csv --names "file.xlsx"`
4. Convert target sheet to CSV:
   - Single sheet: `xlsx2csv -s 1 "file.xlsx" > /tmp/sheet_temp.csv`
   - By name: `in2csv --sheet "SheetName" "file.xlsx" > /tmp/sheet_temp.csv`
   - All sheets: `xlsx2csv -a "file.xlsx" /tmp/sheets/`
   - ODS/XLS fallback: `ssconvert "file.ods" "fd://1" > /tmp/sheet_temp.csv`
5. Read efficiently — never dump the full CSV into context:
   - `head -20 /tmp/sheet_temp.csv` — preview
   - `csvcut -c col1,col2 /tmp/sheet_temp.csv` — targeted columns
   - `csvgrep -c status -m active /tmp/sheet_temp.csv` — filter rows
   - `csvstat /tmp/sheet_temp.csv` — summary without full read
6. After answering, delete: `rm -f /tmp/sheet_temp.csv && rm -rf /tmp/sheets/`

Install instructions if missing:
- csvkit (in2csv/csvcut/csvgrep/csvstat): `brew install csvkit` / `pip install csvkit`
- xlsx2csv: `pipx install xlsx2csv` / `pip install xlsx2csv`
- ssconvert: `brew install gnumeric` / `sudo apt install gnumeric`
