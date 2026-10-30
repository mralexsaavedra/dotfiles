# Claude Code consumer package

Claude Code is the only AI agent configured here.

- `.claude/CLAUDE.md`: copy of `~/.claude/CLAUDE.md`, managed by `gentle-ai sync`; refresh it with `make sync-ai`.
- `.claude/skills/`: all skills (gentle-ai managed plus personal ones such as `vacaciones`); `~/.claude/skills` is a symlink to this folder.

## Status line

`.claude/statusline.sh` is the Claude Code status line (`~/.claude/settings.json` → `statusLine.command: ~/.claude/statusline.sh`, a symlink to this file).

- Line 1: model and effort level (grey `low`/`medium`, highlighted from `high`), folder, branch with changed files and unpushed/unpulled commits (`main *80 ↑7 ↓2`; never-pushed branches count against `origin/HEAD`; `LK-*` branches link to Jira), lines changed in the session, context usage, prompt cache time left (`⏱ 42m`, yellow under 10 min, `⏱ fría` when cold), Engram Cloud (`🧠 ✓` synced, `↑N` pending, red when stuck for 30 min or `degraded`; from `~/.engram/engram.db` `sync_state`).
- Line 2 (kept short so Claude Code's own right-hand info still fits): Jira ticket `🎫 LK-XXXXX <status>` (key from the branch, else from the session name, e.g. a session on `master` named `LK-46147: …`; needs `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN` from `~/.zshenv.local`, cached 2 min, token passed to curl on stdin), PR of that branch with its checks (`gh`, cached 2 min), next calendar event `📅 lun 09:30 Retro` (macOS Calendar via `icalBuddy`, today or the next 3 days, cached 1 min), unread Dock badges `💬 Slack 3 · WA 5` (Slack, WhatsApp, Telegram, Mail; only running apps, cached 15 s), Spotify `▶` playing / grey `⏸` paused (cached 10 s, never launches Spotify).
- Slow sources refresh in the background into `~/.cache/claude-statusline/`; delete that folder to force a refresh.
