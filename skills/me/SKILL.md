---
name: me
description: "Personal workflow shortcuts: session handoff, experience distillation, status snapshot, and session recap. Manual invocation only."
when_to_use: "handoff, distill, status, recap, 交接, 沉淀, 总结会话, 会话状态"
metadata:
  version: "1.0.0"
---

# Me: Personal Workflow Shortcuts

Quick operations for session lifecycle. Each sub-command does one thing fast, then stops.

## Mode Routing

Route by the first argument after `/me`:

| Argument | Mode |
|----------|------|
| `handoff` | Produce context block for new session continuation |
| `distill` | Extract learnings and persist to memory |
| `status` | Quick snapshot of current state |
| `recap` | What was accomplished this session |
| (none) | List available sub-commands with one-line descriptions |

If no argument is provided, list all sub-commands. Do not guess intent.

## Handoff Mode

Goal: a self-contained context block that a new agent session can consume cold.

### Process

1. Scan the full conversation. If parts have been compacted, note what might be missing.
2. Extract in this priority order (highest first):
   - Architecture decisions and their rationale — NEVER compress
   - Modified files and the key change in each
   - Current verification status (tests, build, lint — pass/fail/not run)
   - Open tasks with blockers and next steps
   - Rollback notes if any hard-to-reverse action was taken
3. Strip all tool output, intermediate exploration, and dead-end investigations.
4. Output the Handoff Block.

### Handoff Block Format

The output MUST use this exact structure:

```
## Session Handoff

### What We're Doing
[1-2 sentences: the goal and why]

### Decisions Made (DO NOT SKIP)
- [Decision]: [rationale]

### Files Changed
- `path/to/file` — [what changed and why]

### Verification
- tests: [pass / fail / not run]
- build: [pass / fail / not run]
- manual check: [done / not done]

### Remaining Work
1. [Task] — [blocker or next step]

### Watch Out
[Partial migrations, temp files, env requirements, anything dangerous]
```

### Rules

- The block must be copy-pasteable as the first message in a new session.
- No conversation references ("as we discussed", "earlier you said"). The new session has zero context.
- Every file path must be absolute or repo-relative. No "that file" or "the config."
- If the session was too short to have meaningful content, say so in one line. Do not output an empty template.

## Distill Mode

Goal: extract reusable learnings from this session and persist them.

### Process

1. Scan the conversation for:
   - **User corrections**: "no, don't do that", "stop doing X", approach rejections
   - **User confirmations**: "yes exactly", "perfect", accepting a non-obvious approach
   - **Surprising discoveries**: behavior contradicting expectations, undocumented constraints
   - **User profile signals**: role, expertise, preferences
   - **Project facts**: deadlines, stakeholders, decisions, external dependencies
   - **External resources**: URLs, dashboards, docs mentioned as authoritative

2. Classify each candidate:

   | Signal | Memory Type | Default Scope |
   |--------|-------------|---------------|
   | Correction / confirmation of approach | feedback | user (cross-project) |
   | Role, expertise, preference | user | user |
   | Project deadline, decision, stakeholder | project | project |
   | External URL, dashboard, tool | reference | depends on resource |
   | Code pattern, architecture | SKIP | derivable from code |
   | Git history, recent changes | SKIP | derivable from git |

3. Present candidates as a numbered list:

   ```
   Distill candidates:

   1. [feedback] "Don't mock the database in integration tests"
      → Scope: user | Reason: mock/prod divergence caused production failure

   2. [project] "Merge freeze after 2026-05-15 for mobile release"
      → Scope: project | Reason: mobile team cutting release branch

   3. [SKIP] "The auth module uses JWT"
      → Reason: derivable from code
   ```

4. Wait for user approval on each item. NEVER auto-write.

5. After approval, persist using the agent's memory system (see Memory Persistence below).

### Memory Persistence

**Claude Code** — write approved memories using this format:

Scope determines the target directory:
- User scope → `~/.claude/memory/`
- Project scope → `~/.claude/projects/{project-key}/memory/`

File: `{memory_dir}/{type}_{topic}.md`

```markdown
---
name: {descriptive name}
description: {one-line description for relevance matching}
type: {feedback | user | project | reference}
---

{memory content}

For feedback/project types, structure as:
{rule or fact}
**Why:** {reason}
**How to apply:** {when and where this applies}
```

After writing the memory file, add a one-line pointer to `{memory_dir}/MEMORY.md`:
```
- [Title](filename.md) — one-line description
```

**Other agents (Codex, etc.)** — if no built-in memory system is available:
- Project scope → write `.md` files to `.agent-memory/` in the project root
- User scope → print the memory content to stdout with copy instructions

### Rules

- Never distill code patterns, file structures, or architecture — derivable from codebase.
- Never distill git history — derivable from `git log`.
- Convert relative dates to absolute: "next Thursday" → "2026-05-15".
- If the session has nothing to distill, say so and stop. No empty lists.

## Status Mode

Goal: one-screen snapshot of current state. No analysis, no suggestions.

### Process

1. Gather:
   - Current git branch and tracking status
   - Uncommitted changes (staged + unstaged count)
   - Last 5 commits on current branch (oneline format)
   - Active tasks in this session (if task tracking is available)

2. Output:

   ```
   Branch: feature/auth-refactor (3 ahead of main)
   Uncommitted: 2 modified, 1 untracked
   Recent:
     a1b2c3d fix: token refresh race condition
     d4e5f6g feat: add session middleware
     g7h8i9j docs: update auth flow diagram
   Tasks:
     ✓ Add session middleware
     → Implement token refresh (in progress)
     ○ Write integration tests (pending)
   ```

3. Facts only. No opinions on what to do next.

## Recap Mode

Goal: what was accomplished, suitable for a standup or work log.

### Process

1. Scan conversation for completed actions:
   - Files created, modified, or deleted
   - Tests written or fixed
   - Bugs found and resolved
   - Decisions made

2. Output:

   ```
   ## Session Recap

   ### Done
   - Refactored auth middleware to use JWT (3 files)
   - Fixed token refresh race condition
   - Added integration tests for session flow (8 tests, all pass)

   ### Decisions
   - JWT over session cookies (stateless scaling)
   - Deferred refresh token rotation to next sprint

   ### Not Done
   - Integration tests for error paths
   - Update API docs
   ```

3. Keep it short. If the session was just exploration with no concrete output, describe what was investigated and learned — not what was "done."

## Gotchas

| What happened | Rule |
|---------------|------|
| Handoff missed a key decision because session was compacted | Warn user; suggest running handoff before long sessions hit context limits |
| Distill saved a code pattern as memory | Code patterns are derivable — always SKIP, even if user asks |
| Status showed stale git info | Always fetch fresh git state, never reuse earlier results |
| Recap inflated trivial changes | Only list changes with substance. "Read 3 files" is not an accomplishment |
| Handoff said "as we discussed earlier" | New session has zero context. Write as if briefing a stranger |
| Distill wrote memory without approval | NEVER auto-write. Present → confirm → write |
| No argument provided, agent guessed mode | List sub-commands and wait. Do not guess |
