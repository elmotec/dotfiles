vim.cmd([[
  set runtimepath^=~/vimfiles runtimepath+=~/vimfiles/after
  source ~/.vim/vimrc
]])

vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope git_files<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fF", "<cmd>Telescope find_files search_dir=~<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope grep_string search_dir=../..<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>ft", "<cmd>Telescope tags<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fr", "<cmd>Telescope registers<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fm", "<cmd>Telescope mark<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fc", "<cmd>Telescope git_bcommits<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fx", "<cmd>Telescope quickfix<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { noremap = true })

-- leverage builtin colors ...
local colors = {
    background = 0, -- black
    darkred = 1,
    darkgreen = 2,
    brown = 3,
    darkblue = 4,
    darkmagenta = 5,
    darkcyan = 6,
    text = 7, -- gray
    accentBackground = 8,
    red = 9,
    green = 10,
    yellow = 11,
    blue = 12,
    magenta = 13,
    cyan = 14,
    accentText = 15, -- white
}

-- ... for the theme
local console_theme = {
    normal = {
        a = { fg = colors.accentText, bg = colors.green, },
        b = { fg = colors.lightgrey, bg = colors.background, },
        c = { fg = colors.text, bg = colors.accentBackground, },
    },
    insert = {
        a = { fg = colors.background, bg = colors.blue, },
    },
    visual = {
        a = { fg = colors.background, bg = colors.cyan, },
    },
    replace = {
        a = { fg = colors.background, bg = colors.red, },
    },
    inactive = {
        a = { fg = colors.text, bg = colors.background, },
        b = { fg = colors.text, bg = colors.background, },
        c = { fg = colors.text, bg = colors.background, },
    },
}

require("lualine").setup {
    options = {
        icons_enabled = true,
        --theme = "auto",
        theme = console_theme,
        component_separators = { left = "", right = "╱" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { { "filename", path = 1 } },
        lualine_c = { "branch", "diff", "diagnostics" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}
require("mason").setup()

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "<C-h>", vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, bufopts)
  --vim.keymap.set("v", "<leader>f", vim.lsp.buf.formatexpr, bufopts)
end

local signs = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = "",
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Setup nvim-cmp.
local cmp = require "cmp"

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
            -- require("snippy").expand_snippet(args.body) -- For `snippy` users.
            vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),

    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        -- { name = "vsnip" }, -- For vsnip users.
        -- { name = "luasnip" }, -- For luasnip users.
        -- { name = "snippy" }, -- For snippy users.
        -- { name = "ultisnips" }, -- For ultisnips users.
    }, {
        { name = "buffer" },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won"t work anymore).
cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" }
    }
})

-- Commented out for now because it breaks auto-completion in the command line.
-- Use cmdline & path source for ":" (if you enabled `native_menu`, this won"t work anymore).
-- cmp.setup.cmdline(":", {
    -- mapping = cmp.mapping.preset.cmdline(),
    -- sources = cmp.config.sources({ { name = "path" } })
-- })

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- update_capabilities is deprecated
--local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jedi_language_server (python)
require('lspconfig')['jedi_language_server'].setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities
}
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#clangd
require 'lspconfig'.clangd.setup {
    cmd = {
        "clangd",
        -- "--log=verbose",
        "--enable-config",
        -- "--query-driver=...",  -- path to clang bin
        -- "--ressource-dir=..."  -- path to clang include files
    },
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities
}
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cmake
require 'lspconfig'.cmake.setup {}
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
require'lspconfig'.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

require 'lspconfig'.dockerls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
}

require 'lspconfig'.yamlls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
}

local pylint_commmand = "pylint"
if vim.fn.has("win32") == 1 then
    pylint_commmand = "pylint.exe"
end
require('lspconfig').pylsp.setup({
    debug = true,
})

