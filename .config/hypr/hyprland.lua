-- Hyprland Lua config mirroring the existing i3 workflow.

local mod = "ALT"
local terminal = "ghostty"
local launcher = "walker"
local default_wallpaper = "$HOME/dotfiles/wallpapers/arch-hyprland/0anime.jpg"
local current_wallpaper = "$HOME/.config/hypr/current_wallpaper"
local reload_session = "$HOME/dotfiles/bin/reload-rice"

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x1080",
    scale = 1,
})

-- fallback for any other/unrecognized monitor
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'command -v awww-daemon >/dev/null 2>&1 && (pgrep -x awww-daemon >/dev/null 2>&1 || awww-daemon >/dev/null 2>&1 &)'")
    hl.exec_cmd('sh -c "mkdir -p $HOME/.config/hypr && [ -e ' .. current_wallpaper .. ' ] || ln -sfn ' .. default_wallpaper .. ' ' .. current_wallpaper .. '"')
    hl.exec_cmd('sh -c "command -v awww >/dev/null 2>&1 && sleep 0.5 && awww img --transition-type none ' .. current_wallpaper .. '"')
    hl.exec_cmd("$HOME/dotfiles/bin/hypr-wallpaper-border-color")
    hl.exec_cmd("sh -c 'if command -v wl-paste >/dev/null 2>&1 && command -v cliphist >/dev/null 2>&1 && ! pgrep -af \"wl-paste --type text --watch cliphist store\" >/dev/null 2>&1; then wl-paste --type text --watch cliphist store & fi'")
    hl.exec_cmd("sh -c 'if command -v wl-paste >/dev/null 2>&1 && command -v cliphist >/dev/null 2>&1 && ! pgrep -af \"wl-paste --type image --watch cliphist store\" >/dev/null 2>&1; then wl-paste --type image --watch cliphist store & fi'")
    hl.exec_cmd("sh -c 'if command -v elephant >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1; then elephant service enable >/dev/null 2>&1 || true; systemctl --user daemon-reload >/dev/null 2>&1 || true; systemctl --user start elephant.service >/dev/null 2>&1 || true; fi'")
    hl.exec_cmd("sh -c 'command -v walker >/dev/null 2>&1 && ! pgrep -af \"walker --gapplication-service\" >/dev/null 2>&1 && walker --gapplication-service >/tmp/walker.log 2>&1 &'")
    hl.exec_cmd("sh -c 'command -v systemctl >/dev/null 2>&1 && systemctl --user start hyprwhspr.service >/dev/null 2>&1 || true'")
    hl.exec_cmd("waybar")
    hl.exec_cmd("obsidian")
end)

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
        },
    },

    general = {
        gaps_in = 10,
        gaps_out = { top = 12, right = 12, bottom = 12, left = 12 },
        border_size = 4,
        layout = "dwindle",
        resize_on_border = true,

        col = {
            active_border = { colors = { "rgba(88c0d0ff)", "rgba(81a1c1ff)" }, angle = 45 },
            inactive_border = "rgba(3b4252ff)",
        },
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            size = 4,
            passes = 2,
            new_optimizations = true,
        },

        shadow = {
            enabled = true,
            range = 12,
            render_power = 2,
            color = "rgba(00000066)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = true,
    },
})

hl.curve("movePop", { type = "bezier", points = { {0.1, 1}, {0.2, 1} } })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 0.45, bezier = "movePop", style = "popin 98%" })
hl.curve("windowSpawn", { type = "spring", mass = 1, stiffness = 520, dampening = 42 })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 0.7, spring = "windowSpawn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.45, bezier = "movePop", style = "slide" })
hl.curve("workspaceApple", { type = "spring", mass = 1, stiffness = 420, dampening = 34 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.05, spring = "workspaceApple", style = "slide" })

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + D", hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("$HOME/dotfiles/bin/awww-wallpaper-picker"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + Space", hl.dsp.window.cycle_next("floating"))
hl.bind(mod .. " + C", hl.dsp.layout("preselect r"))
hl.bind(mod .. " + V", hl.dsp.layout("preselect d"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mod .. " + W", hl.dsp.group.next())
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd(reload_session))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + backslash", hl.dsp.exec_cmd("/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record"))
hl.bind(mod .. " + period", hl.dsp.exec_cmd("walker --provider symbols"))
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("walker --provider clipboard"))
hl.bind(mod .. " + equal", hl.dsp.exec_cmd("walker --provider calc"))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }), { repeating = true })
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }), { repeating = true })
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }), { repeating = true })
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }), { repeating = true })
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }), { repeating = true })
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }), { repeating = true })

hl.bind(mod .. " + CTRL + H", hl.dsp.window.resize({ x = 60, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + L", hl.dsp.window.resize({ x = -60, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = 60, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = -60, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + H", hl.dsp.window.resize({ x = 60, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + L", hl.dsp.window.resize({ x = -60, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + K", hl.dsp.window.resize({ x = 0, y = 60, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + J", hl.dsp.window.resize({ x = 0, y = -60, relative = true }), { repeating = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

for i = 1, 10 do
    local key = i % 10

    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

for _, target in ipairs({ 1, 2, 3, 4, 10 }) do
    local key = target % 10
    local move_cmd = "hyprctl dispatch movetoworkspacesilent " .. target .. ",class:^(obsidian|obsidian-wayland)$"

    hl.bind(mod .. " + CTRL + " .. key, hl.dsp.exec_cmd(move_cmd .. " && hyprctl dispatch workspace " .. target))
end

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.window_rule({
    name = "ghostty-workspace",
    match = { class = "^(Xfce4-terminal|ghostty)$" },
    workspace = "1",
})

hl.window_rule({
    name = "ghostty-no-border",
    match = { class = "^(com.mitchellh.ghostty|ghostty)$" },
    border_size = 0,
})

hl.window_rule({
    name = "browser-workspace",
    match = { class = "^(Brave-browser|brave-browser|chromium)$" },
    workspace = "2",
})

hl.window_rule({
    name = "browser-opaque",
    match = { class = "^(Brave-browser|brave-browser|chromium|Google-chrome|google-chrome)$" },
    opacity = "1.0 override 1.0 override 1.0 override",
})

hl.window_rule({
    name = "browser-empty-translucent",
    match = {
        class = "^(Brave-browser|brave-browser|chromium|Google-chrome|google-chrome)$",
        title = "^(New Tab|about:blank)( - .*)?$",
    },
    opacity = "0.72 override 0.72 override 1.0 override",
})

hl.window_rule({
    name = "chrome-workspace",
    match = { class = "^(Google-chrome|google-chrome)$" },
    workspace = "3",
})

hl.window_rule({
    name = "whatsapp-workspace",
    match = { class = "^(whatsapp-electron)$" },
    workspace = "4",
})

hl.window_rule({
    name = "steam-translucent",
    match = { class = "^(steam|Steam)$" },
    opacity = "0.90 override 0.84 override 1.0 override",
})

hl.window_rule({
    name = "steam-games-opaque",
    match = { class = "^steam_app_.*$" },
    opacity = "1.0 override 1.0 override 1.0 override",
})

hl.window_rule({
    name = "spotify-workspace",
    match = { class = "^(Spotify)$" },
    workspace = "7",
})

hl.window_rule({
    name = "slack-workspace",
    match = { class = "^(Slack)$" },
    workspace = "8",
})

hl.window_rule({
    name = "obs-discord-workspace",
    match = { class = "^(obs|discord)$" },
    workspace = "9",
})

hl.window_rule({
    name = "obsidian-workspace",
    match = { class = "^(obsidian|obsidian-wayland)$" },
    workspace = "10",
})

hl.window_rule({
    name = "obsidian-translucent",
    match = { class = "^(obsidian|obsidian-wayland)$" },
    opacity = "0.88 override 0.82 override 1.0 override",
})

-- HyprMod managed settings
require("hyprland-gui")
