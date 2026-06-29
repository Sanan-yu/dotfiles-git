-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 5,
		border_size = 2,

		col = {
			active_border = { colors = { "rgb(212,190,152)", "rgb(212,190,152)" }, angle = 45 },
			inactive_border = "rgba(69,64,61,0.9)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	-- decoration = {
	-- 	rounding = 10,
	-- 	rounding_power = 2,
	--
	-- 	-- Change transparency of focused and unfocused windows
	-- 	active_opacity = 0.96,
	-- 	inactive_opacity = 0.90,
	--
	-- 	shadow = {
	-- 		enabled = true,
	-- 		range = 15,
	-- 		render_power = 3,
	-- 		color = "rgba(1a1a1aee)",
	-- 	},
	--
	-- 	blur = {
	-- 		enabled = true,
	-- 		size = 5,
	-- 		passes = 2,
	-- 		vibrancy = 0.1696,
	-- 		new_optimizations = true,
	-- 		ignore_opacity = false,
	-- 	},
	-- },

	animations = {
		enabled = true,
	},
})

-- Custom Bézier Curves
hl.curve("smooth", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })
hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("bounce", { type = "bezier", points = { { 0.4, 0.0 }, { 0.2, 1.2 } } })

-- Global
hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "smooth" })

-- Windows
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "overshoot", style = "popin 70%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "smooth", style = "slide bottom" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 8, bezier = "smooth", style = "slide bottom" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "smooth" })

-- Layers
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "smooth", style = "slide right" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 7, bezier = "overshoot", style = "popin" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "smooth", style = "fade" })

-- Fade
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smooth" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "fadePopups", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "fadeDpms", enabled = true, speed = 5, bezier = "smooth" })

-- Border
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 10, bezier = "smooth", style = "once" })

-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "bounce", style = "slidefade 15%" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 6, bezier = "smooth", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6, bezier = "smooth", style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 7, bezier = "overshoot", style = "slidefade 20%" })

-- Zoom and Monitor
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 6, bezier = "smooth" })
hl.animation({ leaf = "monitorAdded", enabled = true, speed = 8, bezier = "overshoot" })

hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

hl.config({
	master = {
		new_status = "master",
	},
})

hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})

-- hl.config({
--     plugin = {
--         csgo_vulkan_fix = {
--             fix_mouse = true,
--         },
--     },
-- })

-- hl.plugin.csgo_vulkan_fix.vkfix_app({ app = "cs2", w = 1650, h = 1050 })
