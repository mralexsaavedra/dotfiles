#!/bin/bash
# Claude Code status line. Linked from ~/.claude/statusline.sh.
# Line 1: model and effort level, folder, branch with changed files and unpushed/unpulled commits (Jira link on
#         LK-* branches), lines changed, context, prompt cache time left, Engram Cloud sync.
# Line 2: Jira ticket (from the branch, else the session name), its PR, next calendar event,
#         unread badges (Slack, WhatsApp, Telegram, Mail), Spotify. Kept short so Claude Code's
#         own right-hand info still fits.
# Slow sources (gh, osascript) refresh in the background into a cache; the line never waits for them.

# Gentleman theme colors (ANSI 256)
PRIMARY='\033[38;5;110m'      # #7FB4CA azul claro
ACCENT='\033[38;5;179m'       # #E0C15A dorado
SECONDARY='\033[38;5;146m'    # #A3B5D6 azul gris
MUTED='\033[38;5;242m'        # #5C6170 gris
SUCCESS='\033[38;5;150m'      # #B7CC85 verde
ERROR='\033[38;5;174m'        # #CB7C94 rosa/rojo
PURPLE='\033[38;5;183m'       # #C99AD6 púrpura
BOLD='\033[1m'
NC='\033[0m'

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
mkdir -p "$CACHE_DIR"
ENGRAM_DB="$HOME/.engram/engram.db"
JIRA_BROWSE="https://lookiero.atlassian.net/browse"

input=$(cat)

# Unit separator, not tab: tabs are IFS whitespace, so an empty field would shift the rest.
IFS=$'\x1f' read -r MODEL DIR ADDED REMOVED CTX_PERCENT SESSION_NAME CACHE_EXPIRES CACHE_WARM EFFORT < <(echo "$input" | jq -r '[
  .model.display_name // "Claude", .workspace.current_dir // "~",
  .cost.total_lines_added // 0, .cost.total_lines_removed // 0,
  (.context_window.used_percentage // 0 | floor), .session_name // "",
  (.prompt_cache.expires_at // 0 | floor), (.prompt_cache.warm // false), .effort.level // ""] | map(tostring) | join("\u001f")')
[ "$CTX_PERCENT" -gt 100 ] 2>/dev/null && CTX_PERCENT=100

# Seconds since a cache file was written (huge when missing).
age() { [ -f "$1" ] && echo $(($(date +%s) - $(stat -f %m "$1"))) || echo 999999; }

# Refresh a cache file in the background when older than $2 seconds; print the current value.
# Usage: cached <file> <ttl> <command...>
cached() {
  local file=$1 ttl=$2; shift 2
  if [ "$(age "$file")" -ge "$ttl" ] && [ ! -e "$file.lock" ]; then
    # Detached from our stdout, or Claude Code would wait for it. Empty results are cached too.
    (touch "$file.lock"; "$@" > "$file.tmp" 2>/dev/null; mv -f "$file.tmp" "$file"; rm -f "$file.lock") </dev/null >/dev/null 2>&1 &
    disown 2>/dev/null
  fi
  [ -f "$file" ] && cat "$file"
}

# ── Git ──────────────────────────────────────────────────────────────────────
BRANCH=""; GIT_DIRTY=""; REPO_ROOT=""; AHEAD=0; BEHIND=0
if git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  REPO_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  # One status call: changed files plus ahead/behind of the upstream.
  STATUS=$(git -C "$DIR" status --porcelain=v2 --branch 2>/dev/null)
  CHANGED=$(printf '%s\n' "$STATUS" | grep -cv '^#')
  [ "$CHANGED" -gt 0 ] && GIT_DIRTY=" *${CHANGED}"
  if AB=$(printf '%s\n' "$STATUS" | sed -n 's/^# branch.ab +\([0-9]*\) -\([0-9]*\)$/\1 \2/p') && [ -n "$AB" ]; then
    read -r AHEAD BEHIND <<< "$AB"
  elif [ -n "$BRANCH" ]; then
    # Never pushed: count commits not in the remote default branch.
    BASE=$(git -C "$DIR" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
    [ -n "$BASE" ] && AHEAD=$(git -C "$DIR" rev-list --count "$BASE..HEAD" 2>/dev/null || echo 0)
  fi
fi
SYNC_MARKS=""
[ "${AHEAD:-0}" -gt 0 ] && SYNC_MARKS+=" ${ACCENT}↑${AHEAD}${NC}"
[ "${BEHIND:-0}" -gt 0 ] && SYNC_MARKS+=" ${PRIMARY}↓${BEHIND}${NC}"

# Ticket: from the branch, else from the session name ("LK-46147: …" when the session
# runs from the main checkout while the ticket lives in its own worktree).
TICKET=""; TICKET_BRANCH=""
if [[ "$BRANCH" =~ (LK-[0-9]+) ]]; then TICKET=${BASH_REMATCH[1]}; TICKET_BRANCH=$BRANCH
elif [[ "$SESSION_NAME" =~ (LK-[0-9]+) ]]; then TICKET=${BASH_REMATCH[1]}; TICKET_BRANCH=$TICKET
fi

# LK-* branches link to their Jira ticket (OSC 8 hyperlink).
BRANCH_TEXT="${BRANCH}${GIT_DIRTY}"
if [[ "$BRANCH" =~ (LK-[0-9]+) ]]; then
  BRANCH_TEXT="\033]8;;${JIRA_BROWSE}/${BASH_REMATCH[1]}\033\\\\${BRANCH_TEXT}\033]8;;\033\\\\"
fi

# ── Jira ticket of the branch ────────────────────────────────────────────────
# Uses JIRA_URL / JIRA_USERNAME / JIRA_API_TOKEN (~/.zshenv.local). The token goes
# through curl's config on stdin, never on the command line.
jira_fetch() {
  printf 'user = "%s:%s"\n' "$JIRA_USERNAME" "$JIRA_API_TOKEN" |
    curl -sf --max-time 5 -K - "${JIRA_URL%/}/rest/api/3/issue/$1?fields=status" |
    jq -r '"\(.fields.status.statusCategory.key)|\(.fields.status.name)"'
}
jira_segment() {
  [ -n "$TICKET" ] || return
  local key=$TICKET out cat name color
  [ -n "$JIRA_URL" ] && [ -n "$JIRA_USERNAME" ] && [ -n "$JIRA_API_TOKEN" ] || return
  out=$(cached "$CACHE_DIR/jira-$key" 120 jira_fetch "$key")
  [ -n "$out" ] || return
  IFS='|' read -r cat name <<< "$out"
  case "$cat" in
    done) color=$SUCCESS ;;
    indeterminate) color=$ACCENT ;;
    *) color=$MUTED ;;
  esac
  printf '%b' "${color}🎫 \033]8;;${JIRA_BROWSE}/${key}\033\\\\${key}\033]8;;\033\\\\ ${name}${NC}"
}

# ── Engram Cloud ─────────────────────────────────────────────────────────────
# sync_state is the source of truth: the daemon endpoint only reflects its own worker.
engram_segment() {
  [ -r "$ENGRAM_DB" ] || return
  local row lifecycle pending last epoch
  row=$(sqlite3 -readonly -separator '|' "$ENGRAM_DB" \
    "select lifecycle, last_enqueued_seq - last_acked_seq, coalesce(last_success_at, '') from sync_state where target_key = 'cloud'" 2>/dev/null)
  [ -n "$row" ] || return
  IFS='|' read -r lifecycle pending last <<< "$row"
  epoch=$(date -j -u -f '%Y-%m-%d %H:%M:%S' "$last" +%s 2>/dev/null || echo 0)
  # idle/pending/running/healthy are normal; only degraded is a failure.
  if [ "$lifecycle" = "degraded" ]; then
    printf '%b' "${ERROR}🧠 ✗ degraded${NC}"
  elif [ "$pending" -gt 0 ] && [ $(($(date +%s) - epoch)) -gt 1800 ]; then
    printf '%b' "${ERROR}🧠 ↑${pending}${NC}"          # pending and nothing synced for 30 min
  elif [ "$pending" -gt 0 ]; then
    printf '%b' "${ACCENT}🧠 ↑${pending}${NC}"
  else
    printf '%b' "${SUCCESS}🧠 ✓${NC}"
  fi
}

# ── Pull request of the branch ───────────────────────────────────────────────
pr_fetch() {
  cd "$1" && gh pr view "$2" --json number,isDraft,state,statusCheckRollup -q '
    (if .state == "MERGED" then "merged"
     elif .state == "CLOSED" then "closed"
     elif .isDraft then "draft"
     else ([.statusCheckRollup[]? | (.conclusion // .state // .status)] as $c
           | if ($c | map(select(. == "FAILURE" or . == "CANCELLED" or . == "TIMED_OUT")) | length) > 0 then "fail"
             elif ($c | map(select(. == "SUCCESS" or . == "SKIPPED" or . == "NEUTRAL")) | length) == ($c | length) then "ok"
             else "pending" end) end) as $s | "\(.number) \($s)"'
}
pr_segment() {
  [ -n "$REPO_ROOT" ] || return
  local branch=$BRANCH key out num st
  case "$branch" in master|main|develop|"") branch=$TICKET_BRANCH ;; esac
  [ -n "$branch" ] || return
  key=$(printf '%s' "$REPO_ROOT:$branch" | shasum | cut -c1-12)
  out=$(cached "$CACHE_DIR/pr-$key" 120 pr_fetch "$REPO_ROOT" "$branch")
  [ -n "$out" ] || return
  read -r num st <<< "$out"
  case "$st" in
    ok)      printf '%b' "${SUCCESS} #${num} ✓${NC}" ;;
    fail)    printf '%b' "${ERROR} #${num} ✗${NC}" ;;
    pending) printf '%b' "${ACCENT} #${num} ⏳${NC}" ;;
    draft)   printf '%b' "${MUTED} #${num} draft${NC}" ;;
    merged)  printf '%b' "${PURPLE} #${num} merged${NC}" ;;
    closed)  printf '%b' "${MUTED} #${num} closed${NC}" ;;
  esac
}

# ── Next calendar event (macOS Calendar via icalBuddy) ──────────────────────
calendar_fetch() {
  command -v icalBuddy >/dev/null || return 0
  # Next timed event today, else in the next 3 days ("lun 09:30 Retro").
  icalBuddy -n -ea -nc -eed -iep "datetime,title" -po "datetime,title" -ps "| |" \
    -tf "%H:%M" -df "%a" -b "" -li 1 eventsToday+3 2>/dev/null | head -1 |
    sed -E 's/^today at //; s/^tomorrow at /mañana /; s/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun) at /\1 /;
            s/^Mon /lun /; s/^Tue /mar /; s/^Wed /mié /; s/^Thu /jue /; s/^Fri /vie /; s/^Sat /sáb /; s/^Sun /dom /' 
}
calendar_segment() {
  local ev
  ev=$(cached "$CACHE_DIR/calendar" 60 calendar_fetch)
  [ -n "$ev" ] || return
  [ ${#ev} -gt 22 ] && ev="${ev:0:21}…"
  printf '%b' "${SECONDARY}📅 ${ev}${NC}"
}

# ── Unread badges from the Dock (only apps that are running) ─────────────────
badges_fetch() {
  # By bundle id: some process names carry invisible characters (WhatsApp is "\u200eWhatsApp").
  local app asn label out=""
  for app in com.tinyspeck.slackmacgap:Slack net.whatsapp.WhatsApp:WA ru.keepcoder.Telegram:TG com.apple.mail:Mail; do
    asn=$(lsappinfo find bundleid="${app%%:*}" 2>/dev/null | head -1)
    [ -n "$asn" ] || continue
    label=$(lsappinfo info -only StatusLabel "$asn" 2>/dev/null | sed -n 's/.*"label"="\([^"]*\)".*/\1/p')
    [ -n "$label" ] && out+="${out:+ · }${app#*:} ${label}"
  done
  printf '%s' "$out"
}
badges_segment() {
  local b
  b=$(cached "$CACHE_DIR/badges" 15 badges_fetch)
  [ -n "$b" ] && printf '%b' "${ACCENT}💬 ${b}${NC}"
}

# ── Spotify ──────────────────────────────────────────────────────────────────
spotify_fetch() {
  pgrep -xq Spotify || return 0   # never launch Spotify just to ask
  # Podcast episodes have no artist: show the podcast (album) instead.
  osascript -e 'tell application "Spotify"
    if player state is stopped then return ""
    set who to artist of current track
    if who is "" then set who to album of current track
    set mark to "▶"
    if player state is paused then set mark to "⏸"
    return mark & " " & who & " – " & (name of current track)
  end tell'
}
spotify_segment() {
  local track mark who name color=$PRIMARY
  track=$(cached "$CACHE_DIR/spotify" 10 spotify_fetch)
  [ -n "$track" ] || return
  mark=${track%% *}; track=${track#* }
  who=${track%% – *}; name=${track#* – }
  # Podcasts often repeat the show in the episode title: keep just the episode then.
  [[ "$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')" == "$(printf '%s' "$who" | tr '[:upper:]' '[:lower:]')"* ]] && track=$name
  [ "$mark" = "⏸" ] && color=$MUTED
  [ ${#track} -gt 22 ] && track="${track:0:21}…"
  printf '%b' "${color}♫ ${mark} ${track}${NC}"
}

# ── Line 1 ───────────────────────────────────────────────────────────────────
MODEL_ICON="🤖"
case "$MODEL" in
  *Opus*) MODEL_ICON="🎭" ;;
  *Sonnet*) MODEL_ICON="📝" ;;
  *Haiku*) MODEL_ICON="🍃" ;;
esac

BAR_WIDTH=8
FILLED=$((CTX_PERCENT * BAR_WIDTH / 100))
if [ "$CTX_PERCENT" -ge 80 ]; then BAR_COLOR="$ERROR"
elif [ "$CTX_PERCENT" -ge 50 ]; then BAR_COLOR="$ACCENT"
else BAR_COLOR="$SUCCESS"; fi
BAR="${BAR_COLOR}["
for ((i = 0; i < FILLED; i++)); do BAR+="="; done
for ((i = FILLED; i < BAR_WIDTH; i++)); do BAR+="."; done
BAR+="]${NC}"

SEP="${MUTED}  ${NC}"
# Effort: grey for the everyday levels, highlighted from high up (slower and pricier).
case "$EFFORT" in
  "") EFFORT_TEXT="" ;;
  low|medium) EFFORT_TEXT=" ${MUTED}${EFFORT}${NC}" ;;
  *) EFFORT_TEXT=" ${ACCENT}${EFFORT}${NC}" ;;
esac
LINE="${BOLD}${PURPLE}${MODEL_ICON} ${MODEL}${NC}${EFFORT_TEXT}${SEP}${ACCENT}󰉋 $(basename "$DIR")${NC}"
[ -n "$BRANCH" ] && LINE+="${SEP}${SECONDARY} ${BRANCH_TEXT}${NC}${SYNC_MARKS}"
LINE+="${SEP}${SUCCESS}+${ADDED}${NC} ${ERROR}-${REMOVED}${NC}"
LINE+="${SEP}${MUTED}ctx${NC} ${BAR} ${MUTED}${CTX_PERCENT}%${NC}"
# Prompt cache: time until it goes cold (coming back later means a slower, costlier resume).
if [ "${CACHE_EXPIRES:-0}" -gt 0 ]; then
  LEFT=$(( (CACHE_EXPIRES - $(date +%s)) / 60 ))
  if [ "$CACHE_WARM" != "true" ] || [ "$LEFT" -le 0 ]; then
    LINE+="${SEP}${MUTED}⏱ fría${NC}"
  elif [ "$LEFT" -le 10 ]; then
    LINE+="${SEP}${ACCENT}⏱ ${LEFT}m${NC}"
  else
    LINE+="${SEP}${MUTED}⏱ ${LEFT}m${NC}"
  fi
fi
ENGRAM=$(engram_segment)
[ -n "$ENGRAM" ] && LINE+="${SEP}${ENGRAM}"

# ── Line 2 (only the segments that have something to say) ────────────────────
LINE2=""
for seg in "$(jira_segment)" "$(pr_segment)" "$(calendar_segment)" "$(badges_segment)" "$(spotify_segment)"; do
  [ -n "$seg" ] || continue
  [ -n "$LINE2" ] && LINE2+="${SEP}"
  LINE2+="$seg"
done

# \033[K clears leftovers from the previous render
echo -e "${LINE}\033[K"
[ -n "$LINE2" ] && echo -e "${LINE2}\033[K"
exit 0
