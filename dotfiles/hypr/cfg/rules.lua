-- -----------------------------------------------------
-- Window Rules
-- -----------------------------------------------------

hl.window_rule({ match = { class = "^(steam)$", title = "^(Steam Settings)$" }, float = true })
hl.window_rule({ match = { title = "^(Neovim Cheat Sheet)$" }, float = true })
hl.window_rule({ match = { class = "^(webapp-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(nix-search)$" }, float = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.pulseaudio\\.pavucontrol)$" }, float = true })

hl.window_rule({ match = { class = "^(com\\.mitchellh\\.ghostty)$" }, opacity = "0.90 0.85" })
hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.95 0.85" })

-- Browsers — never have opacity or blur
hl.window_rule({
    match = { class = "^([Zz]en.*|[Ff]irefox.*|[Bb]rave.*|[Cc]hromium.*|[Gg]oogle-chrome.*|[Hh]elium.*)$" },
    opaque = true,
    no_blur = true,
    opacity = "1.0 override 1.0 override",
})

-- Fullscreen windows — never have opacity or blur
hl.window_rule({
    match = { fullscreen = true },
    opaque = true,
    no_blur = true,
    opacity = "1.0 override 1.0 override",
})

-- Games — never have opacity or blur
hl.window_rule({
    match = {
        class = "^(steam_app_.*|.*\\.exe|[Gg]amescope|[Dd][Dd][Nn]et.*|[Tt]ater[Cc]lient.*)$",
    },
    opaque = true,
    no_blur = true,
    opacity = "1.0 override 1.0 override",
})

hl.window_rule({ match = { class = "^([Zz]en.*)$" }, workspace = "1 silent" })
hl.window_rule({ match = { class = "^([Ss]potify.*)$" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "^([Vv]esktop.*)$" }, workspace = "2 silent" })


-- Workspace Rules
for i = 1, 6 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor = "DP-1",
        default = (i == 1),
        persistent = true,
    })
end
