vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 8
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"

local servers = { "clangd", "lua_ls", "tinymist", "pyright", "ruby_lsp", "ts_ls" }
vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/akinsho/toggleterm.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/saghen/blink.lib" },
	{ src = "https://github.com/akinsho/toggleterm.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/folke/trouble.nvim" }
})



require("trouble").setup()
require("mason").setup({
	firewall = {
		enabled = true
	}
})

require("toggleterm").setup({
	open_mapping = [[<c-t>]],
	direction = "float"
})
require("oil").setup({

	columns = {
		"permissions",
		"icon",
	},
	view_options = {
		show_hidden = true
	}
})

require("blink.cmp").setup({
	fuzzy = { implementation = "lua" },
	keymap = {
		preset = "enter",
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" }
	}
})
require("telescope").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.statusline").setup()

for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end

vim.cmd.colorscheme("tokyonight-night")
vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format)
vim.keymap.set("n", "<C-n>", ":Oil<CR>")
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers)
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)
vim.keymap.set("v", "<leader>cc", '"+y')

vim.keymap.set({ "v", "n" }, "<leader>/", ":norm gcc<CR>")
vim.keymap.set("n", "<leader>q", ":Trouble diagnostics toggle<CR>")
vim.keymap.set("n", "<ESC>", ":noh<CR>")
