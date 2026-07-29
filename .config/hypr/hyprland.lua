-- Hyprland Lua config mirroring the existing i3 workflow.

local mod = "ALT"
local terminal = "ghostty"
local launcher = "rofi -show drun"

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
        gaps_out = 0,
        border_size = 4,
        layout = "dwindle",
        resize_on_border = true,

        col = {
            active_border = { colors = { "rgba(88c0d0ff)", "rgba(81a1c1ff)" }, angle = 45 },
            inactive_border = "rgba(3b4252ff)",
        },
    },

    decoration = {
        rounding = 0,

        blur = {
            enabled = false,
        },

        shadow = {
            enabled = false,
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

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + D", hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + Space", hl.dsp.window.cycle_next("floating"))
hl.bind(mod .. " + C", hl.dsp.layout("preselect r"))
hl.bind(mod .. " + V", hl.dsp.layout("preselect d"))
hl.bind(mod .. " + S", hl.dsp.group.toggle())
hl.bind(mod .. " + W", hl.dsp.group.next())
hl.bind(mod .. " + E", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + period", hl.dsp.exec_cmd("emoji-picker"))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))

hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))

hl.bind(mod .. " + CTRL + H", hl.dsp.window.resize({ x = 10, y = 0 }))
hl.bind(mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = -10 }))
hl.bind(mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = 10 }))
hl.bind(mod .. " + CTRL + L", hl.dsp.window.resize({ x = -10, y = 0 }))

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
    name = "browser-workspace",
    match = { class = "^(Brave-browser|brave-browser|chromium)$" },
    workspace = "2",
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
