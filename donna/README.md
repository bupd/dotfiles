# donna/bin

Donna's machinery. Every script is standalone, runs with no arguments where it
sensibly can, and carries its own usage at the top (`--help` prints it).

## Calendar and reminders

| Script | What it does |
|---|---|
| `calsync` | Makes the live systemd timers match `donna/calendar.md`. Arms what is missing, re-arms what moved, reports orphans and failures. `apply` to act, `apply --prune` to also stop timers no entry claims, bare `calsync` to report. |
| `prepnote` | Composes a reminder when it fires: what is next on the spine, birthdays today, open urgent items. Pointed at by `live=yes`. |
| `eodrecap` | Drafts the end-of-day recap into today's note between its own markers, then nudges. Pointed at by `live=eodrecap`. |
| `daysheet` | One merged day: 8gears spine + birthdays + Donna's calendar + `calendar.md`, with conflicts, back-to-back runs and free blocks. `--days=2`, `--json`. |
| `prepwatch` | Keeps a 30-minute prep timer armed per meeting. Reconciles every 15 min. |
| `meetprep` | The brief for one meeting, re-fetched at fire time so cancellations and moves are caught. |

## Watching

| Script | What it does |
|---|---|
| `driftwatch` | Heals arm/re-arm drift on a timer, tells Donna only what she must decide. Never auto-prunes. |
| `morningwake` | Hands Donna the composed sweep at 08:30. |
| `trackerage` | How long items in `tracker.md` have been open; flags stale and overdue. |

## Writing calendar entries

An entry is one list item under a `## YYYY-MM-DD` heading. Put its time at the
**front** of the line — times later in the prose describe something else and are
ignored. For exact control add a directive on an indented line beneath it
(invisible in Obsidian preview):

```markdown
- **19:05 — EOD recap.** what it is, why it moved.
  <!-- remind unit=eod at=19:05 live=eodrecap -->
```

Fields: `unit=` (required), `at=HH:MM` (required), `lead=30m` fires early,
`urgency=low|normal|critical`, `title=`, `body=`, `ntfy=`, `stack=`, and
`live=prepnote|eodrecap` to compose at fire time instead of carrying fixed text.
Without a directive, an entry still works if it names a `` `donna-<slug>` `` unit
and leads with a time.

## Unit naming

- `donna-<slug>` — reminders from `calendar.md`, transient, owned by `calsync`.
- `donna-prep-<id>` — meeting briefs, transient, owned by `prepwatch`.
  Reserved: `calsync` never touches these.
- `donna-infra-*` — installed units under `~/.config/systemd/user`, survive
  reboot: `driftwatch` (15 min), `morning` (08:30), `trackerage` (14:00),
  `prepwatch` (15 min). `calsync` ignores all non-transient units.

Transient timers do not survive a reboot; `driftwatch` re-arms them from
`calendar.md` three minutes after boot, and `prepwatch` re-arms the meeting
briefs four minutes after boot.

## Discord voice inbox

| Script | What it does |
|---|---|
| `discordwatch` | Watches Discord channels/DMs for Prasanth's messages. Voice notes are transcribed locally (ffmpeg → `hyprwhspr transcribe`, whisper.cpp on CUDA, ~1s per note), text passes through. Every message lands in `donna/discord-inbox.md`, goes to Donna via `herdr agent prompt`, gets a ✅ reaction, and voice notes get the transcript as a reply. `once` and `status` subcommands for testing. |

| `discordsend` | The reply side: `discordsend "text"` posts to Discord as Donna. Default target is the channel the last inbound message came from (falls back to first `DISCORD_CHANNELS` entry); `--channel ID` overrides; stdin works. Splits >1900 chars, never pings, prints the message id. |

Runs as `donna-infra-discord.service` (long-running daemon, 20s poll, enabled).
Config in `~/.config/donna/discord.env` (chmod 600): `DISCORD_BOT_TOKEN`,
`DISCORD_CHANNELS` (IDs), `DISCORD_DM_USERS` (user IDs whose DMs to watch),
`DISCORD_ALLOWED_USERS`. Without a token the daemon idles and rechecks every
cycle — paste the token and it picks up within 20s, no restart. First sight
of a channel sets a watermark; history is never replayed.

Waiting on Prasanth: create the bot at discord.com/developers/applications
(Bot tab → token; enable Message Content Intent), invite it with
`https://discord.com/oauth2/authorize?client_id=<APP_ID>&scope=bot&permissions=68672`,
fill the env file. If `herdr agent prompt` fails (Donna's pane blocked), the
message still lands in the inbox note and the Discord message shows ⚠️
instead of ✅ — a retry queue is a known gap.

## Voice channel (agents-vc)

| Script | What it does |
|---|---|
| `discordears` | Donna's full voice presence: discord.js + @discordjs/voice with DAVE (E2EE) support - the only stack whose receive works post-E2EE (py-cord 2.6/2.7 cannot handshake, 2.8's receive is broken upstream, pycord#3139; the py-cord attempt is kept as `discordvoice` for reference). Joins `DISCORD_VOICE_CHANNEL` when a human is present, leaves when empty. Utterances cut on 1s silence -> opus decode -> hyprwhspr -> inbox + herdr prompt to Donna. Runs as `donna-infra-voice.service`; node deps in `~/.local/share/donna-voice/ears/`. |
| `vcsay` | Donna speaks in the channel: `vcsay "text"` drops into the spool (`~/.local/state/donna/vc-say/`), synthesized by kokoro and played in order. |
| `voicelab` | Web UI at 127.0.0.1:7777 for tuning Donna's voice: blend up to 4 of kokoro's 50 voices with weight sliders, speed and pitch dials, test box, Save writes `~/.config/donna/voice.env` which `speak` reads every call. Current profile: `af_bella:60,af_river:40` speed 1.1 - tuned against a Suits reference clip (median F0 188Hz, blend measures 187.5). |

hyprwhspr note: its `transcribe` subcommand runs in the app venv at
`~/.local/share/hyprwhspr/venv`, which was missing `soundfile` — installed
2026-09-16. The launcher routes on argv[1], so `transcribe` must be the
first argument; transcript is stdout, progress noise is stderr.

## History mirrors (searchable local SQLite)

| Script | What it does |
|---|---|
| `discsync` | Mirrors Discord server history via `discrawl` (brew, openclaw/tap). Bare run: init-if-needed + sync + status, hourly via `donna-infra-discrawl.timer`. Any args pass through with the token injected: `discsync search ...`, `discsync tui`. |
| `slacsync` | Mirrors Slack history via `slacrawl` (brew). Bare run: sync + status, every 6h via `donna-infra-slacrawl.timer`. Args pass through: `slacsync search ...`. |

`discsync` uses the SAME `DISCORD_BOT_TOKEN` from `~/.config/donna/discord.env`
as discordwatch — one bot, two jobs (live voice inbox + history mirror).
`slacsync` reads `~/.config/donna/slack.env`: `SLACK_BOT_TOKEN` (xoxb,
required), `SLACK_APP_TOKEN` (xapp, optional live tail), `SLACK_USER_TOKEN`
(xoxp, optional, unlocks DMs and full threads). Both wrappers exit 0 quietly
without a token, so the timers self-heal when tokens land. slacrawl's desktop
and Codex-MCP sources are unused here, same story as notcrawl.

## Text to speech

| Script | What it does |
|---|---|
| `speak` | Local TTS aloud via kokoro-tts (onnx, offline). `speak <text...>`, `speak file.txt\|epub\|pdf`, stdin pipe, `-o out.wav` to save instead of play. `SPEAK_VOICE` (default af_sarah) and `SPEAK_SPEED` env overrides. |

Symlinked to `~/.local/bin/speak`. kokoro-tts installed via `uv tool install`;
models (~350MB) live in `~/.local/share/kokoro-tts/`. No account, no token,
fully offline.

## Notion access

| Script | What it does |
|---|---|
| `notionsync` | Pulls the Notion workspace into `notcrawl` (`~/.notcrawl/notcrawl.db`) over the official API and renders markdown to `~/.notcrawl/pages`. `status` and `search QUERY` subcommands. |

Token comes from `NOTION_TOKEN` in the environment or `~/.notcrawl/env`
(chmod 600, placeholder created). Waiting on Prasanth to mint an internal
integration at notion.so/my-integrations and share the pages with it — the
API sees only explicitly shared pages. First target: the container-registry
page `aa382899122247c6b5b2a2e23bc55a29`.

notcrawl's other two sources are dead here: no Notion desktop app (empty
cache), and the MCP source rides the Codex ChatGPT credential in
`~/.codex/auth.json`, which 401'd and is off-limits to agents (secrets
classifier). Always sync with `notionsync`, not `notcrawl sync --source all`.

## Google access

One token, `bupddev@gmail.com`, all scopes (`gog auth list`). Calendar roles:
`prasanth@8gears.com` writer (the spine — everything real), `bupddev@gmail.com`
owner (Donna's own), `bupdprasanth@gmail.com` reader (birthdays only).

Gmail, Drive, Contacts and Tasks are scoped but their APIs are **not enabled**
in project `bupd-calendar`; until they are, those commands fail with a console
link. Enable from Cloud Shell as the project owner:

```
gcloud services enable gmail.googleapis.com drive.googleapis.com \
  people.googleapis.com tasks.googleapis.com docs.googleapis.com \
  sheets.googleapis.com --project=bupd-calendar
```

No re-auth is needed afterwards; the token already carries the scopes.

## Multilingual

`whisperd` (donna-infra-whisperd) keeps large-v3-turbo loaded and serves
transcription over a unix socket; both Discord pipelines prefer it and fall
back to the hyprwhspr CLI. It runs whisper's translate task with auto-detect,
so Hindi/Tamil/English speech all reach Donna as English text. Runs on the
GPU via faster-whisper: CUDA comes as pip wheels in the fw venv
(~/.local/share/donna-voice/fw), no system toolkit - pacman cannot install
cuda on this bootc host (/opt conflict). ~1s/utterance on the 3060; the
proper toolkit is baked into the next image (oci-native/archlinux#29).

Hindi out: `speak --hi "देवनागरी"` / `vcsay --hi "..."` synthesize real Hindi
via `kokorohi` (kokoro's hf_alpha voice; the library's 6-language guard is
patched - the model itself was trained on Hindi). `SPEAK_HI_VOICE` /
`SPEAK_HI_SPEED` tune it. No Tamil voice exists in the model.
