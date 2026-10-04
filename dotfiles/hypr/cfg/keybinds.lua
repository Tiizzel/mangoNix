-- -----------------------------------------------------
-- Keybindings
-- -----------------------------------------------------

-- =========================================================
-- Applications
-- =========================================================
hl.bind("SUPER + T", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("zen-beta"))
hl.bind("SUPER + F", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + Z", hl.dsp.exec_cmd("antigravity-ide"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd("ghostty -e yazi"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("pavucontrol"))

-- =========================================================
-- Window Management
-- =========================================================
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + M", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Layout Cycling
hl.bind("SUPER + SHIFT + I", hl.dsp.layout("next"))

-- =========================================================
-- Window Navigation & Focus (Arrow Keys & Vi Keys)
-- =========================================================
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))

-- =========================================================
-- Window Moving / Swapping (Arrow Keys & Vi Keys)
-- =========================================================
hl.bind("SUPER + SHIFT + Left", hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.swap({ direction = "d" }))

hl.bind("SUPER + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))

-- =========================================================
-- Workspaces (1 - 9)
-- =========================================================
for i = 1, 9 do
    local str = tostring(i)
    hl.bind("SUPER + " .. str, hl.dsp.focus({ workspace = str }))
    hl.bind("SUPER + SHIFT + " .. str, hl.dsp.window.move({ workspace = str }))
    hl.bind("SUPER + CTRL + " .. str, hl.dsp.workspace.toggle_special(str))
end

-- =========================================================
-- Resizing (Window / Column)
-- =========================================================
hl.bind("SUPER + ALT + Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind("SUPER + ALT + Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind("SUPER + ALT + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind("SUPER + ALT + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))

-- Column Proportion Presets (Scrolling Layout)
hl.bind("SUPER + CTRL + Left", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + CTRL + Right", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + CTRL + H", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + CTRL + L", hl.dsp.layout("colresize +conf"))

-- =========================================================
-- Special Workspace / Scratchpad
-- =========================================================
hl.bind("SUPER + N", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + Space", hl.dsp.workspace.toggle_special("magic"))

-- =========================================================
-- Shell & Desktop Actions (Noctalia IPC)
-- =========================================================
hl.bind("SUPER + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"))
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("noctalia msg panel-toggle noctalia/wallhaven:browser"))
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("noctalia msg window-switcher"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center network"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center calendar"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
hl.bind("SUPER + CTRL + R", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("noctalia msg dock-toggle"))
hl.bind("SUPER + ALT + P", hl.dsp.exec_cmd("noctalia msg settings-toggle"))
hl.bind("SUPER + SHIFT + comma", hl.dsp.exec_cmd("noctalia msg settings-toggle"))

-- Screenshots
hl.bind("SUPER + S", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("noctalia msg screenshot-annotate"))
hl.bind("SUPER + ALT + S", hl.dsp.exec_cmd("noctalia msg screenshot-annotate"))

-- System / Config
hl.bind("SUPER + SHIFT + R", hl.dsp.reload_config())
hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("noctalia msg nightlight-force-toggle"))
hl.bind("SUPER + ALT + T", hl.dsp.exec_cmd("matugen-apply"))

-- Cheatsheet & Keybind Viewers
hl.bind("SUPER + comma", hl.dsp.exec_cmd("bash ~/.config/mango/scripts/show-neovim-cheatsheet.sh --noctalia"))
hl.bind("SUPER + CTRL + comma", hl.dsp.exec_cmd("bash ~/.config/mango/scripts/show-neovim-cheatsheet.sh --fuzzel"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("bash ~/.config/mango/scripts/show-keybinds.sh --noctalia"))
hl.bind("SUPER + CTRL + period", hl.dsp.exec_cmd("bash ~/.config/mango/scripts/show-keybinds.sh --fuzzel"))

-- =========================================================
-- Hardware & Media Keys
-- =========================================================
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("noctalia msg volume-mute"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("noctalia msg mic-mute"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media toggle"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("noctalia msg media next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("noctalia msg media previous"))

-- =========================================================
-- Mouse Binds
-- =========================================================
hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())
hl.bind("SUPER + mouse_up", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ direction = "r" }))

-- Mousewheel: Fine-grained resize
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))

-- Mousewheel: Cycle column preset proportions (scrolling layout)
hl.bind("SUPER + CTRL + mouse_up", hl.dsp.layout("colresize +conf"))
hl.bind("SUPER + CTRL + mouse_down", hl.dsp.layout("colresize -conf"))
