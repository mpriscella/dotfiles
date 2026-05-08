---
name: jj-describe
description: Describe jujutsu changes with a markdown-formatted message suitable for GitHub PRs. Use when the user asks to describe, commit, or summarize their current jj changes, or after a logical chunk of work is completed.
allowed-tools: Bash(jj *) Read Grep Glob
---

## Instructions

Analyze the current jujutsu change and write a description for it. The
description will be used as a GitHub PR where the first line becomes the PR
title and the rest becomes the PR body.

### Step 1: Gather context

Run these commands in parallel to understand the current change:

```!
jj status
```

```!
jj diff --stat
```

```!
jj log -r @ --no-graph -T 'concat(change_id, "\n", commit_id, "\n", description, "\n", bookmarks)'
```

```!
jj log --no-graph -r 'ancestors(@, 5)' -T 'concat(change_id.shortest(), " ", description.first_line(), "\n")'
```

### Step 2: Inspect the full diff

Run `jj diff` to see the complete diff for the current change. For large diffs,
read specific modified files as needed to understand the changes.

### Step 3: Write the description

Compose a description following this format:

```
<title line: conventional commit format, under 72 chars>

## Summary
<1-3 bullet points describing what changed and why>

## Changes
<bulleted list of specific changes, grouped by area if needed>
```

Guidelines:
- **Title**: Use Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`,
  `refactor:`, `test:`). Keep under 72 characters. Capitalize the first word
  after the prefix (e.g., `feat: Add new feature`). Focus on the "what" at a
  high level.
- **Summary**: Explain the motivation and impact. Focus on "why" over "what".
- **Changes**: List specific changes. Group by file or area for larger changes.
- Omit the Summary or Changes section if the change is trivial (e.g., a one-line
  fix).
- Do not include `Co-Authored-By` lines.

### Step 4: Apply the description

Use `jj describe -m` to set the description on the current change. Pass the
message via a HEREDOC:

```bash
jj describe -m "$(cat <<'EOF'
<description here>
EOF
)"
```

### Step 5: Confirm

Show the user the final description by running `jj log -r @ --no-graph`.
