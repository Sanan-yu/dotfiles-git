vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.local/share/nvim/undo")

vim.cmd.colorscheme("gruvbox")
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000
vim.opt.clipboard = "unnamedplus"
-- Основные настройки
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.termguicolors = true

-- Автоформат C/C++ при сохранении
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
