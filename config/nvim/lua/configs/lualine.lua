require("lualine").setup({
	options = {
		theme = "auto",
		icons_enabled = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = { { "mode", icon = "" } }, -- режим (Normal/Insert…)
		lualine_b = { "branch", "diff" }, -- git-ветка и diff
		lualine_c = {
			{ "filename", path = 1 }, -- имя файла + относительный путь
			{ "diagnostics", sources = { "nvim_lsp" } }, -- ошибки/варнинги из LSP
		},
		lualine_x = {
			{ "encoding" },
			{ "fileformat" },
			{ "filetype" }, -- кодировка, формат, тип файла
		},
		lualine_y = { "progress" }, -- % прокрутки по файлу
		lualine_z = { "location" }, -- строка:колонка
	},
})
