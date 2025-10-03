-- Включение LSP серверов (только если у тебя Neovim >= 0.11)

vim.lsp.config("lua_ls", {})

vim.lsp.enable({
	"bashls",
	"clangd",
	"qmlls",
	"pyright",
	"lua_ls",
	"html",
	"cssls",
})

-- Настройка автокоманд для LSP
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local opts = { buffer = bufnr, silent = true, noremap = true }

		-- Бинды
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})

vim.lsp.config.clangd = {
	cmd = {
		"clangd",
		"--clang-tidy",
		"--background-index",
		"--offset-encoding=utf-8",
	},
	root_markers = { ".clangd", "compile_commands.json" },
	filetypes = { "c", "cpp" },
}

vim.lsp.config.qmlls = {
	cmd = {
		"qmlls6",
	},
	filetypes = { "qml" },
}

vim.lsp.config.bashls = {
	cmd = {
		"bash-language-server",
		"start",
	},
	filetypes = { "sh", "bash" },
}

vim.lsp.config.html = {
	cmd = {
		"vscode-html-language-server",
		"--stdio",
	},
}

vim.lsp.config.css = {
	cmd = {
		"vscode-css-language-server",
		"--stdio",
	},
}

vim.lsp.config.pyright = {
	cmd = {
		"pyright-langserver",
		"--stdio",
	},
}
