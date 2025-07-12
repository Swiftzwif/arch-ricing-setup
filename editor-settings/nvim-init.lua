vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.guifont = "JetBrainsMono Nerd Font:h14"

-- Set colorscheme (use 'tokyonight' as a close match)
vim.cmd [[colorscheme tokyonight]]

-- Custom highlight overrides
vim.cmd [[
  highlight Normal guibg=#181C24 guifg=#F5F7FA
  highlight Comment guifg=#BFC9D1
  highlight Identifier guifg=#4B6EAF
  highlight Statement guifg=#A3C7F7
  highlight Type guifg=#7FD8F7
  highlight Constant guifg=#F7BFD8
]] 