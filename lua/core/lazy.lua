-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Import plugin configurations
		{ import = "plugins" },
  -- Обеспечиваем совместимость с 'vim-vsnip'
  {
    "hrsh7th/vim-vsnip",
    dependencies = {
      "hrsh7th/vim-vsnip-integ",
      "rafamadriz/friendly-snippets",
    },
  }
}, {
  install = {
    -- Try to load colorscheme when installing plugins
    colorscheme = { "onedark", "habamax" },
  },
  ui = {
    -- Display borders
    border = "rounded",
    icons = {
      cmd = "⌘",
      config = "🛠️",
      event = "📅",
      ft = "📂",
      init = "⚙️",
      keys = "🔑",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
  change_detection = {
    -- Automatically check for config changes
    enabled = true,
    notify = true,
  },
})

vim.cmd [[
  augroup lazy_cmds
    autocmd!
    autocmd FileType lazy lua vim.opt_local.wrap = false
  augroup end
]]
