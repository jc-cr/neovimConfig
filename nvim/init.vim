"V12: Setup spell check, options for markdown files  
"
" Notes: 
" - Had problems with Python recognition on Windows, make sure to do pip
" install neovim
" - Changed monochrome version
" - To paste in command mode: Shift + r, Shift + =  
" - Block insert: cntrl + v, down the line, :s/^/inserted text

let &path.="src/include,/usr/include/AL,"	" list of dirctories to look for file
set nocompatible              " required
filetype off                  " required

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()
" aligning
Plug 'junegunn/vim-easy-align'

" Fold blocks of text
Plug 'tmhedberg/SimpylFold'

" Status bar
Plug 'itchyny/lightline.vim'

" Monochrome theme
Plug 'fxn/vim-monochrome'

" :Centerpad to center a signle buffer
Plug 'smithbm2316/centerpad.nvim'

" LSP manage
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" NVIM language server protocol
" Must go after mason
Plug 'neovim/nvim-lspconfig'

" File tree
Plug 'nvim-tree/nvim-tree.lua'

" LSP include for ros
"Plug 'taketwo/vim-ros'

" Initialize plugin system
" - Automatically executes `filetype plugin indent on` and `syntax enable`.
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting


"------------------- Gen. Settings 
" File detection tuff
filetype on
filetype plugin indent on    " load perfile indent guidlines
" Numbered lines
set nu

" for windows clipboard pasteign and yanking
" on xubuntu must install xclip to be able to copt to sys clipboard
set clipboard^=unnamed,unnamedplus

" colored termianl
set t_Co=256 " enable colors in terminal

" Enable syntax highlighting
"syntax on

" Color scheme settigns
colorscheme monochrome
set background=dark

" Use UNIX (\n) line endings.
au BufNewFile *.py,*.pyw,*.c,*.h,*.cpp set fileformat=unix

" Set the default file encoding to UTF-8:
set encoding=utf-8
set fenc=utf-8
set termencoding=utf-8

" make backspaces more powerfull
set backspace=indent,eol,start

" Enable folding
set foldmethod=indent
set foldlevel=99

"use space to open folds
nnoremap <space> za

" Change highlighting of cursor line when entering/leaving Insert Mode
set cursorline
highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=233 guifg=NONE guibg=#121212
autocmd InsertEnter * highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=234 guifg=NONE guibg=#1c1c1c
autocmd InsertLeave * highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=233 guifg=NONE guibg=#121212

set splitright

" wrap lines at 120 chars. 80 is somewaht antiquated with nowadays displays.
set textwidth=120

" configure tabwidth and insert spaces instead of tabs
"set tabstop=4        " tab width is 4 spaces
"set shiftwidth=4     " indent also with 4 spaces
"set expandtab        " expand tabs to spaces

" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

"---------------------- Keybinding
" Note: Don't use "'" for shit, it causes delay when programming

" Centerpad using the lua function
nnoremap <silent> ,z <cmd>lua require'centerpad'.toggle { leftpad = 80, rightpad = 40}<cr>

" Turn on and off spell with F8
nnoremap <silent> <F8> :set nospell!<cr>
inoremap <silent> <F8> <C-O>:set nospell!<cr>

" install en_us
"set spell spelllang=en_us

nnoremap <silent> ,f :NvimTreeToggle<cr>
inoremap <silent> ,f :NvimTreeToggle<cr>

"---------------------- Lightline config
set laststatus=2
set noshowmode

let g:lightline = {
      \ 'colorscheme': 'rosepine',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'absolutepath', 'readonly' ] ]
      \ },
      \ }

"------------------- Markdown stuff 
lua vim.g.markdown_recommended_style = 1


"------------------- ROS Stuff
autocmd BufRead,BufNewFile *.launch setfiletype roslaunch

" https://superuser.com/questions/632657/how-to-setup-vim-to-edit-both-makefile-and-normal-code-files-with-two-different
" fixed indentation should be OK for XML and CSS. People have fast internet
" anyway. Indentation set to 2.
autocmd FileType html,xhtml,css,xml,xslt set shiftwidth=2 softtabstop=2

" two space indentation for some files
autocmd FileType vim,lua,nginx set shiftwidth=2 softtabstop=2

" add completion for XML
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags

"------------------- C stuff 
" Filetype detection
augroup project
  autocmd!
  autocmd BufRead,BufNewFile *.h,*.c set filetype=c.doxygen
augroup END

au FileType c,c++ set showmatch " show matching brackets

autocmd BufNewFile,BufRead *.c,*.cpp,*.h,*.hpp set comments=sl:/*,mb:\ *,elx:\ */

autocmd BufNewFile,BufRead *.c,*.cpp,*.h,*.hpp set smartindent


"------------------ Start Python stuff
" Execute file with pyhton <F9>
autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>

" Number of spaces that a pre-existing tab is equal to.
" au BufRead,BufNewFile *py,*pyw,*.c,*.h set tabstop=4

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Display tabs at the beginning of a line in Python mode as bad.
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/


"set colorcolumn=110
"highlight ColorColumn ctermbg=darkgray

" Keep indentation level from previous line:
autocmd FileType python set autoindent

"Folding based on indentation:
autocmd FileType python set foldmethod=indent

"------------------ Lua Based Configs
lua <<EOF

-- **************** LSP Setup
-- Notes:
-- Setup for mason manager
-- Makse sure python3.x
-- python-lsp-server == pylsp, yaml-lsp-server == yamlls
-- make sure: sudo apt install python3.x-venv
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "pylsp", "clangd", "marksman", "lemminx", "cmake" }
})

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require('lspconfig')['clangd'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['lemminx'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}

require('lspconfig')['marksman'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['pylsp'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['yamlls'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
require('lspconfig')['cmake'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}

-- **************** File Tree
-- OR setup with some options

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
  },
  renderer = {
    group_empty = true,
    icons = {
      webdev_colors = false,
      git_placement = "before",
      modified_placement = "after",
      padding = " ",
      symlink_arrow = " ➛ ",
      show = {
	file = false,
	folder = false,
	folder_arrow = false,
	git = false,
	modified = false,
      },
    },  
  },
  filters = {
    dotfiles = true,
  },
})
EOF

