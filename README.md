# Me

Personal workflow shortcuts for coding agents. Four sub-commands for session lifecycle management.

| Command | What it does |
| :--- | :--- |
| `/me handoff` | Summarize session into a context block for new session continuation |
| `/me distill` | Extract learnings and persist to memory (project or user scope) |
| `/me status` | Quick snapshot: branch, uncommitted changes, recent commits, tasks |
| `/me recap` | What was accomplished this session, suitable for standup or work log |

## Install

**Claude Code**

```bash
npx skills add asyncguo/me -a claude-code -g -y
```

**Codex**

```bash
npx skills add asyncguo/me -a codex -g -y
```

**Update**

```bash
npx skills update -g -y
```

## Uninstall

```bash
npx skills remove asyncguo/me -g
```

## License

MIT
