set nocompatible              " Disable Vi compatibility
set number                    " Show line numbers
set relativenumber            " Show relative line numbers
syntax on                     " Enable syntax highlighting
set hlsearch                  " Highlight search results
set incsearch                 " Incremental search
set ignorecase                " Case-insensitive search
set smartcase                 " Case-sensitive if uppercase is used

" Indentation settings
set tabstop=4                 " Number of spaces in a tab
set shiftwidth=4              " Number of spaces to use for auto-indent
set expandtab                 " Use spaces instead of tabs
set autoindent                " Maintain indent of current line
set smartindent               " Smart indentation

" Visual settings
set cursorline                " Highlight the current line
set termguicolors             " Enable true color support
colorscheme desert            " Set colorscheme

" Status line
set laststatus=2              " Always show status line
set statusline=%F%m%r%h%w\ [%{&ff}]\ [TYPE=%Y]\ [POS=%04l,%04v][%p%%]

" File handling
set autoread                  " Reload files changed outside of Vim
set undofile                  " Enable undo files


" Key mappings
nnoremap <C-n> :NERDTreeToggle<CR>  " Toggle NERDTree with Ctrl+n
nnoremap <C-p> :Files<CR>           " Open fzf with Ctrl+p
inoremap kj <Esc>

" Misc settings
set clipboard=unnamedplus     " Use system clipboard
set mouse=a                   " Enable mouse support
