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
- If it doesn't exist → build it from these commands (no file reads):
  ```
  cat package.json | grep -A50 '"dependencies"' | head -30
  find src/ -maxdepth 2 -type d | sort
  grep -rn "axios.create" src/ --include="*.ts" -l
  grep -rn "create(" src/ --include="*.store.ts" -l
  ```
  Write a compact `CLAUDE_INDEX.md`: stack, module map, entry points, conventions, key config files. Keep it under 150 lines.
- After any structural change → update only the changed section, not the whole file

The index replaces all exploratory find/ls commands in future sessions.

## Refactor Map — Grep Before You Read

Before touching any file in a refactor:

1. Define the change in one line: "I am changing X from old to new"
2. Grep the full blast radius: `grep -rn "ThingBeingChanged" src/ --include="*.ts" --include="*.tsx" -l`
3. For TypeScript: read and change the type/interface first — let compiler errors guide the rest
4. Read files one at a time, only as you reach them in the change sequence — never read ahead
5. For simple renames, grep the specific line and change without reading the full file:
   `grep -n "oldName" src/path/to/file.ts` → read 10 lines around the match → change

Common blast-radius greps:
- Rename function: `grep -rn "oldName" src/ --include="*.ts" -l`
- Add field to type: `grep -rn "TypeName" src/ --include="*.ts" -l`
- Change hook return: `grep -rn "useHookName" src/ --include="*.tsx" -l`
- Move file: `grep -rn "from.*old/path" src/ --include="*.ts" -l`
- Change Zustand store: `grep -rn "useStoreName" src/ --include="*.tsx" -l`

Never read consumer files speculatively. Grep gives you the list; TypeScript errors tell you what to fix.
