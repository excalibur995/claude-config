---
name: convert-spreadsheet
description: Use when reading, inspecting, or analyzing spreadsheet files (xlsx, xls, ods, csv with multiple sheets) to convert them into lightweight CSV before reading — avoids binary overhead and enables targeted, token-efficient access per sheet.
---

# Intent and Goals

Prevent reading raw binary spreadsheet formats directly into context. Convert to CSV first, then use targeted reads (head, grep, csvcut) to load only what is needed.

# Capabilities & Automation Steps

Whenever the user asks you to inspect, read, review, or analyze any spreadsheet file (`.xlsx`, `.xls`, `.ods`, `.numbers`, `.gnumeric`):

1. **Format Evaluation**: Identify file type. Never `cat` or Read raw binary spreadsheet files.

2. **List Sheets First** (always do this before converting):
   ```bash
   # xlsx / xls
   xlsx2csv --list-sheets "path/to/file.xlsx"
   # or via python (fallback)
   python3 -c "import openpyxl; wb=openpyxl.load_workbook('file.xlsx',read_only=True); print(wb.sheetnames)"
   # ods
   ssconvert --list-sheet-names "path/to/file.ods" 2>&1
   ```

3. **Convert Sheet(s) to CSV**:
   ```bash
   # Single sheet (by index, 1-based)
   xlsx2csv -s 1 "path/to/file.xlsx" > /tmp/sheet1_temp.csv

   # All sheets to separate files
   xlsx2csv -a "path/to/file.xlsx" /tmp/sheets/
   # produces: /tmp/sheets/sheet1.csv, /tmp/sheets/sheet2.csv ...

   # ODS / XLS fallback via ssconvert
   ssconvert "path/to/file.ods" "fd://1" > /tmp/sheet_temp.csv

   # in2csv (csvkit) — best for xls, ods, or unknown format
   in2csv "path/to/file.xls" > /tmp/sheet_temp.csv
   in2csv --sheet "SheetName" "path/to/file.xlsx" > /tmp/sheet_temp.csv
   ```

4. **Read Efficiently** — never read the whole CSV blindly:
   ```bash
   # Preview headers + first rows
   head -20 /tmp/sheet1_temp.csv

   # Target specific columns only
   csvcut -c col1,col2,status /tmp/sheet1_temp.csv | head -50

   # Filter rows
   csvgrep -c status -m active /tmp/sheet1_temp.csv

   # Summary stats without reading all rows
   csvstat /tmp/sheet1_temp.csv

   # Grep across all sheets
   grep -i "keyword" /tmp/sheets/*.csv
   ```

5. **Answer Prompt**: Fulfill the user's request from the extracted CSV content only.

6. **Session Cleanup**:
   ```bash
   rm -f /tmp/sheet1_temp.csv /tmp/sheet_temp.csv
   rm -rf /tmp/sheets/
   ```

# Dependency Check

Before converting, verify the required tool is installed:

```bash
which xlsx2csv    # primary for xlsx
which in2csv      # part of csvkit — handles xlsx, xls, ods, csv
which ssconvert   # Gnumeric suite — fallback for ods/xls
which csvcut      # part of csvkit — column targeting
```

**Tool priority:** `in2csv` (csvkit) > `xlsx2csv` > `ssconvert`

If none are installed, **stop and tell the user**:

---

**Missing `xlsx2csv`:**
> Install: `pip install xlsx2csv` or `brew install xlsx2csv`

**Missing `in2csv` / `csvcut` (csvkit):**
> Install: `pip install csvkit` or `brew install csvkit`

**Missing `ssconvert`:**
> Install: `brew install gnumeric` (Mac) or `sudo apt install gnumeric` (Ubuntu)

---

Do **not** attempt to read the raw file as a fallback. Wait for the user to confirm a tool is available.

# Multi-Sheet Strategy

| Scenario | Command |
|---|---|
| Unknown sheet names | List sheets first, then target by name |
| Single sheet needed | `xlsx2csv -s <index>` or `in2csv --sheet <name>` |
| All sheets, cross-search | `xlsx2csv -a file.xlsx /tmp/sheets/` then `grep` across all |
| Summary of all sheets | Convert all, run `csvstat` per file |
| Large sheet, few columns | Convert → `csvcut` immediately, discard rest |

# Guardrails

- Always list sheets before converting — never assume sheet count or names.
- Always run dependency check first.
- Always use targeted reads (`head`, `csvcut`, `csvgrep`) after conversion — never read the full CSV into context unless it is small.
- Delete temp files after the task is done.
