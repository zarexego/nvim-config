
-- Neovim config

-- 1. 
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. 
local opt = vim.opt

-- Интерфейс
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.laststatus = 3

-- Поведение
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.undofile = true
opt.swapfile = false

-- Табы
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- Поиск
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- 3. БУТСТРАП lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
opt.rtp:prepend(lazypath)

-- 4. ПЛАГИНЫ
vim.g.lazy_git_timeout = 120
require("lazy").setup({
  -- ВНЕШНИЙ ВИД 
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night", transparent = false })
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "auto", globalstatus = true } })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup()
      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Предыдущий буфер" })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Следующий буфер" })
      vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Закрыть буфер" })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({ scope = { enabled = true } })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function() require("which-key").setup() end,
  },

  -- ФАЙЛЫ И ПОИСК
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Проводник" })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Поиск файлов" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Поиск по тексту" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Буферы" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Справка" },
    },
    config = function() require("telescope").setup({}) end,
  },

  -- СИНТАКСИС
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "python", "rust", "java",
          "javascript", "typescript", "html", "css",
          "json", "yaml", "toml", "markdown", "bash",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff", "rust_analyzer" },
        automatic_installation = true,
      })

      
      -- Настройка rust-analyzer
      vim.lsp.config('rust_analyzer', {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = true,
            cargo = { allFeatures = true },
            inlayHints = { bindingModeHints = { enable = true } },
          },
        },
      })
      vim.lsp.enable('rust_analyzer')
      -- Кеймапы LSP
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf, desc = "LSP" }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
        end,
      })
    end,
  },

  -- АВТОДОПОЛНЕНИЕ
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
    
  --РЕДАКТИРОВАНИЕ
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function() require("nvim-autopairs").setup({}) end,
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function() require("Comment").setup() end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<C-\>]],
        direction = "horizontal",
        close_on_exit = true,
        shell = vim.o.shell,
      })
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Выйти из терминала" })
      vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Терминал снизу" })
      vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Плавающий терминал" })
    end,
  },

  -- GIT 
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })
      vim.keymap.set("n", "]c", "<cmd>Gitsigns next_hunk<cr>", { desc = "Следующее изменение" })
      vim.keymap.set("n", "[c", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Предыдущее изменение" })
      vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Просмотр изменения" })
      vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git blame" })
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" } },
  },

  -- ФОРМАТИРОВАНИЕ И ЛИНТИНГ
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format", "ruff_organize_imports" },
          rust = { "rustfmt" },
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
        },
        format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = { python = { "ruff" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },
})


-- 5. ГЛОБАЛЬНЫЕ НАСТРОЙКИ (вне lazy.setup)

-- Диагностика
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})

-- Общие кеймапы
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Сохранить" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Выйти" })
map("n", "<leader>Q", "<cmd>quitall!<cr>", { desc = "Выйти без сохранения" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Убрать подсветку" })
map("n", "<C-h>", "<C-w>h", { desc = "Окно влево" })
map("n", "<C-j>", "<C-w>j", { desc = "Окно вниз" })
map("n", "<C-k>", "<C-w>k", { desc = "Окно вверх" })
map("n", "<C-l>", "<C-w>l", { desc = "Окно вправо" })

-- Java: запуск jdtls
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    local jdtls_path = vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls")
    local config_dir = jdtls_path .. "/config_linux"
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local workspace_dir = vim.fn.expand("~/java-workspace/" .. project_name)
    vim.fn.mkdir(workspace_dir, "p")

    local launcher_jars = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar", false, true)
    if #launcher_jars == 0 then
      vim.notify("jdtls: launcher jar не найден", vim.log.levels.ERROR)
      return
    end
    local launcher_jar = launcher_jars[#launcher_jars]

    local root_files = vim.fs.find({ "pom.xml", "build.gradle", "build.gradle.kts", ".git", "src" }, { upward = true })
    local root_dir = root_files[1] and vim.fs.dirname(root_files[1]) or vim.fn.getcwd()

    vim.lsp.start({
      name = "jdtls",
      cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang.invoke=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED",
        "--add-opens", "java.base/java.io=ALL-UNNAMED",
        "--add-opens", "java.base/java.net=ALL-UNNAMED",
        "--add-opens", "java.base/java.nio=ALL-UNNAMED",
        "--add-opens", "java.base/java.util.concurrent=ALL-UNNAMED",
        "--add-opens", "java.base/java.util.concurrent.atomic=ALL-UNNAMED",
        "--add-opens", "java.base/jdk.internal.ref=ALL-UNNAMED",
        "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED",
        "--add-opens", "java.management/sun.management=ALL-UNNAMED",
        "--add-opens", "jdk.management/com.sun.management.internal=ALL-UNNAMED",
        "-jar", launcher_jar,
        "-configuration", config_dir,
        "-data", workspace_dir,
      },
      root_dir = root_dir,
      bufnr = args.buf,
    })
  end,
})
