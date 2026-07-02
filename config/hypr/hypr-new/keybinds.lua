-- Variables
local terminal = "kitty"
local fileManager = "thunar"
-- local menu = "rofi -show drun -show-icons"
local menu = "qs -c test ipc call appWin toggleOpened"
-- local browser = "firefox"
local browser = "zen-browser"
local resetSubMap = "hyprctl dispatch 'hl.dsp.submap(\"reset\")'"
local mainMod = "SUPER"

hl.config({ binds = { scroll_event_delay = 8 } })
--------------------------------------------------------------------------------
-- SUBMAP DEFINITIONS
--------------------------------------------------------------------------------

-- Launch Submap
hl.define_submap("launch", function()
	hl.bind("V", hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/clipboard/history & " .. resetSubMap))
	hl.bind("B", hl.dsp.exec_cmd(browser .. " & " .. resetSubMap))
	hl.bind("SHIFT + B", hl.dsp.exec_cmd(browser .. " --private-window & " .. resetSubMap))
	hl.bind("G", hl.dsp.exec_cmd("chromium & " .. resetSubMap))
	hl.bind("R", hl.dsp.exec_cmd(menu .. " & " .. resetSubMap))
	hl.bind("F", hl.dsp.exec_cmd(fileManager .. " & " .. resetSubMap))
	hl.bind("O", hl.dsp.exec_cmd("$HOME/bin/toggle-otter.sh & " .. resetSubMap))
	hl.bind("E", hl.dsp.exec_cmd("rofi -show emoji & " .. resetSubMap))
	hl.bind("T", hl.dsp.exec_cmd("$HOME/Desktop/PineconeMc/ElyPrismLauncher & " .. resetSubMap))
	hl.bind("SHIFT + E", hl.dsp.exec_cmd("$HOME/Desktop/Prism/PrismLauncher & " .. resetSubMap))
	hl.bind("C", hl.dsp.exec_cmd("toggle-recording & " .. resetSubMap))
	hl.bind("D", hl.dsp.exec_cmd("discord & " .. resetSubMap))
	hl.bind("N", hl.dsp.exec_cmd("nmgui & " .. resetSubMap))
	hl.bind("S", hl.dsp.exec_cmd("spotify-launcher & " .. resetSubMap))
	hl.bind("SHIFT + R", hl.dsp.exec_cmd(browser .. " reddit.com & " .. resetSubMap))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Tools Submap
hl.define_submap("tools", function()
	hl.bind("D", hl.dsp.exec_cmd("hyprpicker | wl-copy & " .. resetSubMap))
	hl.bind("A", hl.dsp.exec_cmd("~/bin/change_wallpaper & " .. resetSubMap))
	hl.bind("R", hl.dsp.exec_cmd(os.getenv("HOME") .. "/bin/random_wallpaper & " .. resetSubMap))
	hl.bind("W", hl.dsp.exec_cmd("killall -SIGUSR1 waybar & " .. resetSubMap))
	hl.bind("M", hl.dsp.exec_cmd("killall -SIGUSR2 waybar & " .. resetSubMap))
	hl.bind("E", hl.dsp.exec_cmd("resources & " .. resetSubMap))
	hl.bind("O", hl.dsp.exec_cmd("qs -c test ipc call overviewLoader toggleVisible & " .. resetSubMap))
	hl.bind("G", hl.dsp.exec_cmd("~/bin/gamemode & " .. resetSubMap))
	hl.bind("K", hl.dsp.exec_cmd("~/bin/toggle-kb & " .. resetSubMap))
	hl.bind("C", hl.dsp.exec_cmd("copyq read 1 | wl-copy &" .. resetSubMap))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Window Submap
hl.define_submap("window", function()
	hl.bind("N", hl.dsp.focus({ urgent = true, last = true }))
	hl.bind("SHIFT + C", hl.dsp.window.kill()) -- sends SIGKILL, I use it with popups that don't close)
	hl.bind("F", hl.dsp.window.float({ action = "toggle" }))
	hl.bind("SHIFT + F", hl.dsp.window.fullscreen())
	hl.bind("P", hl.dsp.window.pseudo())
	hl.bind("J", hl.dsp.layout("togglesplit"))
	hl.bind("Z", function()
		work = hl.get_active_workspace()
		windows = hl.get_windows({ workspace = work })
		for _, wind in ipairs(windows) do
			hl.dsp.window.float({ window = wind, action = "toggle" })
		end
	end)
	hl.bind("A", hl.dsp.window.pin())
	hl.bind("SHIFT + Q", hl.dsp.exit())
	hl.bind("SHIFT + M", hl.dsp.exec_cmd("hyprshutdown --post-cmd poweroff"))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Multimedia Submap
hl.define_submap("multimedia", function()
	hl.bind("A", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
	hl.bind("P", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
	hl.bind("N", hl.dsp.exec_cmd("playerctl next"), { locked = true })
	hl.bind(
		"right",
		hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 3%+"),
		{ repeating = true, locked = true }
	)
	hl.bind("left", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"), { repeating = true, locked = true })
	hl.bind("M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
	hl.bind("S", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
	hl.bind("up", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%+"), { repeating = true, locked = true })
	hl.bind("down", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%-"), { repeating = true, locked = true })
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Screenshot Submap
hl.define_submap("screenshot", function()
	hl.bind("S", hl.dsp.exec_cmd("hyprshot -m region --output-folder ~/Pictures/screenshots & " .. resetSubMap))
	hl.bind("SHIFT + S", hl.dsp.exec_cmd("hyprshot -m window --output-folder ~/Pictures/screenshots & " .. resetSubMap))
	hl.bind("SUPER + S", hl.dsp.exec_cmd("hyprshot -m output --output-folder ~/Pictures/screenshots & " .. resetSubMap))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- System Submap
hl.define_submap("system", function()
	hl.bind("W", hl.dsp.exec_cmd("wlogout & " .. resetSubMap))
	hl.bind("L", hl.dsp.exec_cmd("hyprlock & " .. resetSubMap))
	hl.bind("S", hl.dsp.exec_cmd("suspend & " .. resetSubMap))
	hl.bind("H", hl.dsp.exec_cmd("hibernate & " .. resetSubMap))
	hl.bind("R", hl.dsp.exec_cmd("reboot & " .. resetSubMap))
	hl.bind("P", hl.dsp.exec_cmd("hyprshutdown --post-cmd poweroff & " .. resetSubMap))
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Passthru Submap(VMs)
hl.define_submap("passthru", function()
	hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
end)

--------------------------------------------------------------------------------
-- MAIN BINDINGS
--------------------------------------------------------------------------------

-- Global Submap Entry Binds
hl.bind(mainMod .. " + R", hl.dsp.submap("launch"))
hl.bind(mainMod .. " + W", hl.dsp.submap("window"))
hl.bind(mainMod .. " + T", hl.dsp.submap("tools"))
hl.bind(mainMod .. " + M", hl.dsp.submap("multimedia"))
hl.bind(mainMod .. " + E", hl.dsp.submap("screenshot"))
hl.bind(mainMod .. " + X", hl.dsp.submap("system"))
hl.bind(mainMod .. " + V", hl.dsp.submap("passthru"))

-- Core App Binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())

-- Focus and Navigation
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Swapping / Moving (Repeating)
hl.bind(mainMod .. " + SHIFT + left", function()
	hl.dispatch(hl.dsp.window.move({ x = -60, y = 0, relative = true }))
	hl.dispatch(hl.dsp.window.swap({ direction = "left" }))
end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", function()
	hl.dispatch(hl.dsp.window.move({ x = 60, y = 0, relative = true }))
	hl.dispatch(hl.dsp.window.swap({ direction = "right" }))
end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", function()
	hl.dispatch(hl.dsp.window.move({ x = 0, y = -60, relative = true }))
	hl.dispatch(hl.dsp.window.swap({ direction = "up" }))
end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", function()
	hl.dispatch(hl.dsp.window.move({ x = 0, y = 60, relative = true }))
	hl.dispatch(hl.dsp.window.swap({ direction = "down" }))
end, { repeating = true })

-- Resizing
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -60, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 60, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -60, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 60, relative = true }), { repeating = true })

for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Special Workspace
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))

-- Mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Hardware / XF86 Keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd("hyprlock"), { locked = true })
hl.bind("XF86Display", hl.dsp.exec_cmd("gtk-launch mpv"), { locked = true })
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"), { locked = true })

-- Screenshots
hl.bind(
	"PRINT",
	hl.dsp.exec_cmd("hyprshot -m region --output-folder ~/Pictures/screenshots --freeze"),
	{ locked = true }
)
hl.bind(
	"SHIFT + PRINT",
	hl.dsp.exec_cmd("hyprshot -m window --output-folder ~/Pictures/screenshots"),
	{ locked = true }
)
hl.bind(
	mainMod .. " + PRINT",
	hl.dsp.exec_cmd("hyprshot -m output --output-folder ~/Pictures/screenshots"),
	{ locked = true }
)

-- Zoom
local current_zoom = 1.0

local function set_zoom(delta)
	return function()
		-- Some dynamic type system magic
		if delta == "reset" then
			hl.config({ cursor = { zoom_factor = 1 } })
			current_zoom = 1
			return
		end
		current_zoom = math.max(1.0, current_zoom + delta)
		hl.config({ cursor = { zoom_factor = current_zoom } })
	end
end

hl.bind(mainMod .. " + SHIFT + I", set_zoom(0.5), { repeating = true })
hl.bind(mainMod .. " + SHIFT + O", set_zoom(-0.5), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Z", set_zoom("reset"))

hl.bind(mainMod .. " + SHIFT + mouse_down", set_zoom(0.1))
hl.bind(mainMod .. " + SHIFT + mouse_up", set_zoom(-0.1))
