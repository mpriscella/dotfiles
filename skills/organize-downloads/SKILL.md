---
name: organize-downloads
description: Organize ~/Downloads into content-aware category subfolders, flagging deletion candidates and sensitive files along the way. Use when the user asks to organize, clean up, tidy, or sort their Downloads directory.
allowed-tools: Bash Read Glob AskUserQuestion
---

## Instructions

Organize the files in `~/Downloads` into category subfolders based on what
each file actually is (content and context), not just its extension. Always
present the full plan and get confirmation before moving anything, and get a
separate explicit confirmation before deleting anything.

### Step 1: Inventory

List everything with sizes and modification times. `ls -la` is portable
across GNU and BSD; `--time-style=long-iso` (GNU coreutils) yields clean,
parseable dates and is silently ignored on BSD:

```!
ls -la --time-style=long-iso ~/Downloads 2>/dev/null || ls -la ~/Downloads
```

Rules for the inventory:

- **Skip** hidden files (`.DS_Store`, `.localized`, `.claude`, etc.).
- **Skip** the category folders this skill creates (see Step 2) — but note
  them so files can be moved into them.
- **Leave existing directories in place** (e.g. project folders someone
  created intentionally). List them in the plan under "left as-is" unless one
  is obviously a category candidate the user should decide about.

### Step 2: Categorize

Assign each file to one of these categories. Judge by filename first; when a
filename is ambiguous (hash-named PDFs, generic names like `table.tsv`), peek
at the content with `Read` (PDFs can be read directly) or `file`/`head`
before guessing.

| Folder        | What goes in it                                                                                                                     |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `Work`        | Client/work documents: RFPs, SOWs, proposals, audits, technical approaches, presentations, brand assets, work reports               |
| `Finance`     | Bank/credit-card statements, invoices, pay stubs, tax docs, compensation docs, real-estate/mortgage paperwork                       |
| `Personal`    | Personal documents that aren't financial: recipes, meal plans, letters, personal projects                                           |
| `Screenshots` | `Screenshot *.png`, `SCR-*.png`, and other screen captures                                                                          |
| `Media`       | Images, video, and audio that aren't screenshots                                                                                    |
| `Installers`  | `.dmg`, `.pkg`, `.iso`, `.PUP`, app archives whose only purpose is installation                                                     |
| `Data`        | Exports and datasets: `.csv`, `.tsv`, `.json` exports, log dumps                                                                    |
| `Dev`         | Source files, configs, markdown docs, SVGs/diagrams that are clearly development artifacts                                          |
| `Archives`    | `.zip`/`.tar.gz`/`.7z` whose contents are unknown or mixed (an archive that clearly belongs to another category goes there instead) |

Only create a folder if at least one file lands in it. If a file genuinely
fits nothing, leave it in place and say so rather than inventing a new
category.

**Subfolders:** when several files within a category clearly share a theme,
group them into a subfolder instead of leaving them loose — e.g. multiple
documents for the same client go in `Work/<Client>`, home-purchase paperwork
in `Finance/Home Purchase`. Use a subfolder only when it earns its keep
(roughly 3+ related files); one level deep, never nested further. If a
matching subfolder already exists (including pre-existing directories like a
client folder), move files into it rather than creating a parallel one.

### Step 3: Flag deletion candidates

Do **not** delete anything in this step — just build a list:

- Office lock/temp files (`~$*.docx` and similar).
- Exact duplicates: `foo (1).pdf` next to `foo.pdf` — confirm they are
  actually identical with `shasum` before calling them duplicates. If
  checksums differ, treat them as distinct files and keep both.
- Installers older than ~30 days (the app is presumably installed by now).
- Zero-byte files.

### Step 4: Flag sensitive files

Build a second list of files that should not be sitting in Downloads:
recovery codes, OAuth client secrets, API keys, exported credentials —
anything matching patterns like `recovery-codes*`, `client_secret*`,
`*credentials*`, `*.pem`, `*.key`, or whose content clearly contains
secrets. Recommend the user move them somewhere safer (password manager,
then delete) — do not move or delete them yourself unless asked.

### Step 5: Present the plan and confirm

Show a concise summary: per-category counts with a few example filenames,
the full deletion-candidate list, the sensitive-file list, and anything
left as-is. Then use AskUserQuestion to confirm, as two separate decisions:

1. Proceed with the moves?
2. Delete the deletion candidates? (Offer all / none; the user can reply
   with specific exclusions via "Other".)

### Step 6: Execute

- Create folders with `mkdir -p` only for categories that have files.
- Move with `mv -n` so nothing is ever overwritten. If a name collision
  prevents a move, rename the incoming file with a ` (2)` style suffix and
  retry.
- Quote paths — many filenames contain spaces.
- Only run `rm` on files the user explicitly approved in Step 5.

### Step 7: Report

Summarize what happened: files moved per category, files deleted, sensitive
files awaiting the user's action, and anything skipped or left in place.
