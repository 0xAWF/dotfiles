vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"
vim.o.colorcolumn = '80'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

local servers = {
    "clangd",
    "lua_ls",
    "tinymist",
    "basedpyright",
    "ruby_lsp",
    "ts_ls",
    "jsonls",
    "rust_analyzer"
}

vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-mini/mini.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/akinsho/toggleterm.nvim" },
    { src = "https://github.com/saghen/blink.cmp" },
    { src = "https://github.com/saghen/blink.lib" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/akinsho/toggleterm.nvim" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/folke/trouble.nvim" },
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/0xAWF/arrakis.nvim" }

})

require("conform").setup({
    formatters_by_ft = { python = { "black" } }
})
require("trouble").setup()
require("mason").setup({
    firewall = {
        enabled = true
    }
})

require("toggleterm").setup({
    open_mapping = [[<c-t>]],
    direction = "horizontal"
})
vim.keymap.set({ "n", "t" }, "<C-+>", "<cmd>resize +2<CR>")
vim.keymap.set({ "n", "t" }, "<C-->", "<cmd>resize -2<CR>")
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*toggleterm#*",
    callback = function()
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = 0 })
        vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], { buffer = 0 })
    end,
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
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" }
    }
})

require("telescope").setup()
require("mini.pairs").setup()
require("mini.surround").setup({
    mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr"
    },
})


for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end


require("arrakis").setup({
    transparent = false,
    italic_comments = true,
})

vim.cmd("colorscheme arrakis")
-- vim.opt.runtimepath:append("~/Developer/personal/plugins/tinytask.nvim")
-- require("tinytask").setup({ keymap = "<leader>tt" })
-- require("tinytask").setup()

-- Pluginbindings
vim.keymap.set("n", "<leader>fm", function()
    require("conform").format({ lsp_fallback = true })
end
)

vim.keymap.set("n", "<C-n>", ":Oil<CR>")
vim.keymap.set("n", "<leader>gi", vim.lsp.buf.definition)
-- <C-h> inside the picker toggles hidden files (keeps the typed prompt)
local function find_files(hidden, prompt)
    require("telescope.builtin").find_files({
        prompt_title = hidden and "Find Files (hidden)" or "Find Files",
        hidden = hidden,
        find_command = { "rg", "--files", "--color", "never", "--glob", "!**/.git/*" },
        default_text = prompt,
        attach_mappings = function(bufnr, map)
            map({ "i", "n" }, "<C-h>", function()
                local line = require("telescope.actions.state").get_current_line()
                require("telescope.actions").close(bufnr)
                find_files(not hidden, line)
            end)
            return true
        end,
    })
end
vim.keymap.set("n", "<leader>ff", function() find_files(false) end)
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers)
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)
vim.keymap.set("n", "<leader>fk", require("telescope.builtin").keymaps)
vim.keymap.set("v", "<leader>cc", '"+y')
-- vim.keymap.set("v", "<leader>rr", vim.lsp.buf.rename)

-- Magic
--- Comments
vim.keymap.set("x", "<leader>/", "gc", { remap = true, desc = "Toggle Comment" })
vim.keymap.set("v", "<leader>/", "gcc", { remap = true, desc = "Toggle Comment line" })

vim.keymap.set("n", "<leader>q", ":Trouble diagnostics toggle<CR>")
vim.keymap.set("n", "<ESC>", ":noh<CR>")

vim.keymap.set("v", "<Tab>", ":'<,'>>'<CR>gv")
vim.keymap.set("v", "<S-Tab>", ":'<,'><'<CR>gv")
vim.keymap.set("x", "<Tab>", ">gv")
vim.keymap.set("x", "<S-Tab>", "<gv")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set({ "n", "v" }, "<leader>å", ':put +<CR>')

vim.keymap.set("n", "<leader>rl", ":so $MYVIMRC<CR>")
