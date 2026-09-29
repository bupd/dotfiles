#!/bin/sh
# Herdr event hook: dunst popup when an agent finishes a turn or blocks on input.
set -eu
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
herdr=${HERDR_BIN_PATH:-herdr}

ev=${HERDR_PLUGIN_EVENT_JSON:-}
[ -n "$ev" ] || exit 0
pane=$(printf '%s' "$ev" | jq -r '.data.pane_id // empty')
status=$(printf '%s' "$ev" | jq -r '.data.agent_status // empty')
[ -n "$pane" ] || exit 0

# Event carries only the new status; remember the previous one per pane.
state_dir=${HERDR_PLUGIN_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/herdr-agent-notify}
mkdir -p "$state_dir"
state_file="$state_dir/$(printf '%s' "$pane" | tr ':/' '__')"
prev=$(cat "$state_file" 2>/dev/null || true)
printf '%s' "$status" > "$state_file"

case "$status" in
  idle|done) [ "$prev" = working ] || exit 0; kind=done ;;
  blocked) [ "$prev" != blocked ] || exit 0; kind=blocked ;;
  *) exit 0 ;;
esac

# pane get also works while an agent is still blocked during startup.
agent_json=$("$herdr" pane get "$pane" 2>/dev/null | jq -c '.result.pane // empty') || exit 0
[ -n "$agent_json" ] || exit 0
agent_name=$("$herdr" agent get "$pane" 2>/dev/null | jq -r '.result.agent.name // empty' || true)
ws_id=$(printf '%s' "$agent_json" | jq -r '.workspace_id')
tab_id=$(printf '%s' "$agent_json" | jq -r '.tab_id')
ws_json=$("$herdr" workspace get "$ws_id" 2>/dev/null | jq -c '.result.workspace')
tab_json=$("$herdr" tab get "$tab_id" 2>/dev/null | jq -c '.result.tab')

# Same rule as Herdr's own popups: stay quiet for the pane you are looking at.
if [ "$(printf '%s' "$ws_json" | jq -r '.focused')" = true ] &&
   [ "$(printf '%s' "$ws_json" | jq -r '.active_tab_id')" = "$tab_id" ] &&
   [ "$(printf '%s' "$agent_json" | jq -r '.focused')" = true ]; then
  exit 0
fi

name=${agent_name:-$(printf '%s' "$agent_json" | jq -r '.agent // "agent"')}
space=$(printf '%s' "$ws_json" | jq -r '.label // .workspace_id')
tab=$(printf '%s' "$tab_json" | jq -r '.label // (.number|tostring)')

# Body: Claude's last reply from its transcript, else the agent's terminal title.
body=
session=$(printf '%s' "$agent_json" | jq -r 'select(.agent == "claude") | .agent_session.value // empty')
if [ "$kind" = done ] && [ -n "$session" ]; then
  transcript=$(ls "$HOME"/.claude/projects/*/"$session".jsonl 2>/dev/null | head -n1 || true)
  if [ -n "$transcript" ]; then
    body=$(tail -n 200 "$transcript" | jq -rs '
      [ .[] | select(.type == "assistant") | .message.content
        | if type == "array" then map(select(.type == "text") | .text) | join(" ") else . end
        | select(type == "string" and length > 0) ] | last // empty' 2>/dev/null || true)
  fi
fi
[ -n "$body" ] || body=$(printf '%s' "$agent_json" | jq -r '.terminal_title_stripped // empty')
body=$(printf '%s' "$body" | tr '\n\t' '  ' | tr -d '*`' | tr -s ' ' | cut -c1-240)
esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

if [ "$kind" = blocked ]; then
  summary="$name needs input · $space/$tab"; urgency=critical
else
  summary="$name done · $space/$tab"; urgency=normal
fi
replace_id=$(( 900000 + $(printf '%s' "$pane" | cksum | cut -d' ' -f1) % 100000 ))

dunstify -a Herdr -u "$urgency" -t 8000 -r "$replace_id" "$(esc "$summary")" "$(esc "$body")"
