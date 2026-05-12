# Kata

Personal workflow shortcuts for coding agents. Four sub-commands for session lifecycle management.

Kata (型, かた) — a practiced form in martial arts, drilled until it becomes instinct. Part of the same lineage as [Waza](https://github.com/tw93/Waza) (技, technique).

| Command | What it does |
| :--- | :--- |
| `/kata handoff` | Summarize session into a context block for new session continuation |
| `/kata distill` | Extract learnings and persist to memory (project or user scope) |
| `/kata status` | Quick snapshot: branch, uncommitted changes, recent commits, tasks |
| `/kata recap` | What was accomplished this session, suitable for standup or work log |

## Install

**Claude Code**

```bash
npx skills add asyncguo/kata -a claude-code -g -y
```

**Codex**

```bash
npx skills add asyncguo/kata -a codex -g -y
```

**Update**

```bash
npx skills update -g -y
```

## Uninstall

```bash
npx skills remove asyncguo/kata -g
```

## License

MIT
