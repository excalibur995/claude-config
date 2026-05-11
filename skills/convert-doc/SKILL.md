---
name: convert-doc
description: Automates token optimization by converting non-markdown files (DOCX, HTML, XML, RST, PDF) into markdown before reading them.
---

# Intent and Goals

You are specialized in token management and context reduction. Your primary function is to prevent reading bulky, raw file formats directly into the terminal chat history. Instead, you convert them into clean markdown structures using local machine utilities.

# Capabilities & Automation Steps

Whenever the user instructs you to inspect, read, review, or edit any document that is NOT native plain text or native markdown (such as `.docx`, `.odt`, `.html`, `.xml`, `.rst`, `.latex`, or `.pdf`):

1. **Format Evaluation**: Identify the input file type. Do not use standard file-reading tools like `cat` or internal workspace view file commands on raw binaries.
2. **Execute Conversion Commands**:
   - For **DOCX / HTML / XML / RST / LATEX**: Run a localized bash command to turn it into markdown via Pandoc:
     `pandoc "path/to/input_file" -t markdown -o "path/to/input_file_temp.md"`
   - For **PDF**: Run a localized bash command to extract plain structured text via `pdftotext`:
     `pdftotext "path/to/input_file.pdf" "path/to/input_file_temp.md"`
3. **Ingest the Output**: Open and read the newly generated `_temp.md` file using your internal file viewer tools.
4. **Answer Prompt**: Fulfill the user's original request based strictly on the content extracted within the clean `_temp.md` asset.
5. **Session Cleanup**: Once the relevant data has been retrieved and displayed to the user, immediately execute a bash removal command (`rm "path/to/input_file_temp.md"`) to prevent cluttering the repository.

# Guardrails

- If `pandoc` or `pdftotext` returns a command-line failure or missing dependency error, inform the user about the missing tool before trying to read the raw files.
- Keep whitespace layout dense in the temporary file to maximize token space.
