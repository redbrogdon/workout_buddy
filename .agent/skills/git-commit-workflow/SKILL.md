---
name: git-commit-workflow
description: Standardized workflow for examining changes and committing them to the local git repository with concise, formatted messages.
---

# Git Commit Workflow

## Goal
To maintain a clean and informative local git history by following a consistent process for reviewing changes and drafting commit messages.

## Instructions
When tasked with committing changes to the main branch, follow these steps:

1. **Examine Changes**:
   - Run `git status` to identify modified, new, or deleted files.
   - Run `git diff` (and `git diff --staged` if applicable) to review the actual code changes.
   - For untracked files, use `view_file` or `cat` to understand their content if they are new.

2. **Draft the Commit Message**:
   - **Length**: Keep the single-line summary under 60 characters.
   - **Format**: Use parataxis (short, pithy phrases separated by commas or semicolons) rather than complete sentences.
   - **Capitalization**: ALWAYS capitalize the first word of the commit message.
   - **Tone**: Professional and descriptive of the "what" and "why" where space permits.

3. **Execute the Commit**:
   - Stage all relevant changes using `git add .` (or specific files if requested).
   - Commit using the drafted message: `git commit -m "Your Message Here"`.

4. **Summarize**:
   - Provide a brief, bulleted summary of what was committed to the user.

## Examples
- `Add logging dependency, log agent messages`
- `Refine workout UI, live timer, update prompts`
- `Use mock storage, expand seed data`
- `Cleanup: remove unused imports and variables`

## Constraints
- Do NOT include long descriptions unless explicitly requested.
- Ensure the first word is capitalized.
- Stay under the 60-character limit for the first line.
