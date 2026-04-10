-- 1. Modern Path Handling
-- Prepend/Append ensures your vimfiles and nvim-data are in the runtimepath correctly
vim.opt.runtimepath:prepend("~/vimfiles")
vim.opt.runtimepath:append("~/vimfiles/after")
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site')

-- Source legacy vimrc
vim.cmd("source ~/.vim/vimrc")

-- 2. Modern Keymaps (Telescope)
-- Using vim.keymap.set is the modern preference over nvim_set_keymap
local map = vim.keymap.set
local opts_silent = { noremap = true, silent = true }

map("n", "<leader>ff", "<cmd>Telescope git_files<cr>", opts_silent)
map("n", "<leader>fF", "<cmd>Telescope find_files search_dirs=~<cr>", opts_silent)
map("n", "<leader>f/", "<cmd>Telescope live_grep cwd=%:h:p search_dirs=.<cr>", opts_silent)
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts_silent)
map("n", "<leader>ft", "<cmd>Telescope tags<cr>", opts_silent)
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts_silent)
map("n", "<leader>fr", "<cmd>Telescope registers<cr>", opts_silent)
map("n", "<leader>fm", "<cmd>Telescope mark<cr>", opts_silent)
map("n", "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", opts_silent)
map("n", "<leader>fc", "<cmd>Telescope git_bcommits<cr>", opts_silent)
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", opts_silent)
map("n", "<leader>fx", "<cmd>Telescope quickfix<cr>", opts_silent)
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", opts_silent)

-- Diagnostic Keymaps
map("n", "<leader>e", vim.diagnostic.open_float, opts_silent)
map("n", "[d", vim.diagnostic.goto_prev, opts_silent)
map("n", "]d", vim.diagnostic.goto_next, opts_silent)
map("n", "<leader>d", vim.diagnostic.setloclist, opts_silent)

-- 3. Theme & Statusline (Lualine)
local colors = {
    background = 0, darkred = 1, darkgreen = 2, brown = 3,
    darkblue = 4, darkmagenta = 5, darkcyan = 6, text = 7,
    accentBackground = 8, red = 9, green = 10, yellow = 11,
    blue = 12, magenta = 13, cyan = 14, accentText = 15,
}

local console_theme = {
    normal = {
        a = { fg = colors.accentText, bg = colors.darkgreen },
        b = { fg = colors.text, bg = colors.background }, -- Fixed lightgrey ref
        c = { fg = colors.text, bg = colors.accentBackground },
    },
    insert = { a = { fg = colors.accentText, bg = colors.darkblue } },
    visual = { a = { fg = colors.background, bg = colors.cyan } },
    replace = { a = { fg = colors.accentText, bg = colors.red } },
    inactive = {
        a = { fg = colors.text, bg = colors.background },
        b = { fg = colors.text, bg = colors.background },
        c = { fg = colors.text, bg = colors.background },
    },
}

require("lualine").setup {
    options = {
        theme = console_theme,
        component_separators = { left = "", right = "╱" },
        section_separators = { left = "", right = "" },
        globalstatus = true, -- Modern Nvim 0.10+ standard
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { { "filename", path = 1 } },
        lualine_c = { "branch", "diff", "diagnostics" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
    }
}

-- 4. LSP Configuration (The Native 0.11 Way)
require("mason").setup()

-- Modern LspAttach Autocommand (replaces old on_attach logic)
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        
        map("n", "gD", vim.lsp.buf.declaration, bufopts)
        map("n", "gd", vim.lsp.buf.definition, bufopts)
        map("n", "K", vim.lsp.buf.hover, bufopts)
        map("n", "gi", vim.lsp.buf.implementation, bufopts)
        map("n", "<C-h>", vim.lsp.buf.signature_help, bufopts)
        map("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
        map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
        map("n", "gr", vim.lsp.buf.references, bufopts)
        map("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, bufopts)
    end,
})

-- Common capabilities for nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 5. Server Definitions (Using vim.lsp.config for 0.11.6)
local servers = { "cmake", "dockerls", "yamlls", "ty" }

for _, lsp in ipairs(servers) do
    vim.lsp.config(lsp, { capabilities = capabilities })
    vim.lsp.enable(lsp)
end

-- Custom Clangd config
vim.lsp.config('clangd', {
    install = { cmd = { "clangd", "--enable-config" } },
    capabilities = capabilities,
})
vim.lsp.enable('clangd')

-- Custom Ruff config
vim.lsp.config('ruff', {
    capabilities = capabilities,
    init_options = {
        settings = {
            lineLength = 120,
            lint = { select = { "E", "F", "W", "Q" }, preview = true },
        }
    }
})
vim.lsp.enable('ruff')

vim.lsp.config('ty', {
    capabilities = capabilities,
        settings = {
            python = {
                analysis = {
                    -- You can toggle specific strictness levels here
                    typeCheckingMode = "standard", 
            }
        }
    }
})

-- 6. Diagnostics & Treesitter
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN] = "△",
            [vim.diagnostic.severity.HINT] = "·",
            [vim.diagnostic.severity.INFO] = "",
        },
        linehl = { [vim.diagnostic.severity.ERROR] = 'ErrorMsg' },
        numhl = { [vim.diagnostic.severity.WARN] = 'WarningMsg' },
    },
})

-- Treesitter (Conditional for Windows)
if vim.fn.has("win32") == 0 then
    require('nvim-treesitter.config').setup {
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "markdown" },
        auto_install = true,
        highlight = { enable = true },
    }
end

-- 7. Completion (nvim-cmp)
local cmp = require "cmp"
cmp.setup({
    snippet = { expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end },
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "buffer" },
    })
})
