-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Insert mode mapping: 'kj' to <Esc>
vim.keymap.set("i", "kj", "<Esc>", { noremap = true })
