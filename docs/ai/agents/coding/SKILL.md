---
name: coding
description: "Implement, fix, or refactor code end to end: prepare the repository, create a ticket-named feature branch, make small coherent commits, validate until green, refactor, review the diff, push the branch, and open a pull request. Use when the user asks Codex to implement, fix, or refactor code and wants the full development loop handled automatically."
---

# Coding

Run the full development loop for implement/fix/refactor requests: prepare → branch → commits → green checks → refactor → review → push → PR.

## Core Loop

1. **Prepare**
   - Follow repository instructions first, including `AGENTS.md` and RTK command usage.
   - Run `git status --short`. Never overwrite or stash uncommitted changes you did not make without user approval.
   - Check out the repo's main branch and pull the latest.

2. **Create the feature branch**
   - Use the ticket/card id when provided (e.g. Jira): `LLF-1234-fix-validation`.
   - Otherwise derive `[ticket-id]-[summary]` from the task; summary lowercase, hyphen-separated, at most 50 chars.
   - Ask the user only when neither a ticket id nor a derivable summary exists.
   - Check out the new branch from updated main.

3. **Implement in small commits**
   - Split the request into behaviorally coherent tasks.
   - Use `/ponytail` for the simplest correct implementation that fits existing patterns. If ponytail is unavailable, apply its ladder directly: YAGNI → stdlib → native feature → one line → minimum code.
   - For each task: inspect the relevant flow, make the smallest coherent change, run focused checks, commit with a clear message.
   - Keep commits coherent; never mix unrelated cleanup into feature or bug-fix commits.

4. **Verify until green**
   - Discover validation commands from package scripts, build files, Makefiles, CI config, or docs.
   - Run the relevant tests, type checks, lint, and build for the changed area.
   - On failure, fix the root cause and rerun until all relevant checks pass and the behavior matches the request.

5. **Refactor after green**
   - Refactor only after the feature works and tests pass; use `/refactor` when available.
   - Improve readability, duplication, naming, or structure without changing behavior; commit separately.
   - Rerun the full relevant validation set, fix, and retest until green.

6. **Review until clean**
   - Start a Review Agent subagent with only the task summary, changed-file list, relevant diff, and latest validation results.
   - Fix actionable findings in new commits, then return to **Verify until green** and **Refactor**; repeat until Review Agent reports no actionable findings.

7. **Push the branch**
   - Confirm the working tree is clean, then push the feature branch to the remote.

8. **Create the pull request**
   - Open a PR from the pushed feature branch into the repo's main branch.
   - Use the supplied ticket or git-issue link. If the link is required but missing, ask for it.
   - First line: Markdown link with text `git issue` pointing to the supplied URL.
   - `## What`: list of changes from commits and final diff summary; leave `## Screenshots` empty unless supplied or naturally produced.

```markdown
Git issue: supplied git issue URL

## What
- list what changes

## Screenshots
```

9. **Report completion**
   - Report the branch name, commits made, checks run, push result, and PR link.

## Operating Rules

- Prefer repo-local patterns, helpers, test utilities, and existing dependencies.
- Never discard, overwrite, or rebase user changes without explicit approval.
- If a required command needs network or elevated permissions, request approval and continue after it is granted.
- If no reliable test command exists, run the narrowest available build or static check and state the remaining risk.
- If push or PR creation fails (remote branch exists, auth, permissions, missing metadata), report the exact blocker and the failing command.
