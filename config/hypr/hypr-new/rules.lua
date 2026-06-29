hl.window_rule({
	match = { class = "otter-launcher", title = "otter-launcher" },
	float = true,
	rounding = 0,
	size = { 800, 600 },
	center = true,
})

hl.window_rule({ match = { class = "imv" }, float = true })
hl.window_rule({ match = { class = "feh" }, float = true })
hl.window_rule({
	match = { class = "^(xwaylandvideobridge)$" },
	opacity = 0.0,
	no_anim = true,
	no_initial_focus = true,
})
hl.window_rule({ match = { class = "^(.*Minecraft.*)$" }, opacity = 1, no_blur = true })
hl.window_rule({ match = { class = "^(.*gimp.*)" }, opacity = 1, no_blur = true })
hl.window_rule({ match = { class = "^()" }, opacity = 1, no_blur = true })
hl.window_rule({ match = { class = "^(atril)" }, opacity = 1 })
hl.window_rule({ match = { class = "^(Spotify)$" }, workspace = 4 })
hl.window_rule({ match = { class = "firefox" }, workspace = 1 })
hl.window_rule({ match = { class = "zen" }, workspace = 1 })

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	match = {
		class = "com.github.hluk.copyq",
	},
	float = true,
	size = "900 620",
	rounding = 20,
})

hl.layer_rule({ match = { class = "vicinae" }, blur = true, ignore_alpha = false, no_anim = true })

hl.layer_rule({ match = { class = "qs" }, blur = false, ignore_alpha = false, no_anim = true })

-- local suppressMaximizeRule = hl.window_rule({
-- 	-- Ignore maximize requests from all apps. You'll probably like this.
-- 	name = "suppress-maximize-events",
-- 	match = { class = ".*" },
--
-- 	suppress_event = "maximize",
-- })
-- suppressMaximizeRule:set_enabled(false)
