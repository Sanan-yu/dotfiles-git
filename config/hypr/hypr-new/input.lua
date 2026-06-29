---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us,ru,", --,az", -- ,de",
		kb_variant = "",
		kb_model = "",
		kb_options = "grp:caps_toggle",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,
		repeat_rate = 50,
		repeat_delay = 300,

		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.device({
	name = "yichip-wireless-device-mouse",
	enabled = true,
	sensitivity = -0.5,
})
