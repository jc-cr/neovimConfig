" Notes: 
" - To paste in command mode: Shift + r, Shift + =  
" - Block insert: cntrl + v, down the line, :s/^/inserted text

let &path.="src/include,/usr/include/AL,"    " list of directories to look for file
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

" Plugins
Plug 'junegunn/vim-easy-align'
Plug 'tmhedberg/SimpylFold'
Plug 'itchyny/lightline.vim'
Plug 'fxn/vim-monochrome'
Plug 'smithbm2316/centerpad.nvim'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'windwp/nvim-autopairs'
Plug 'alvan/vim-closetag'
Plug 'rhysd/vim-clang-format'
Plug 'Chiel92/vim-autoformat'
Plug 'nvim-tree/nvim-tree.lua', { 'commit': '9c97e6449b0b0269bd44e1fd4857184dfa57bb4c'}

call plug#end()

"-------------------- General
filetype on

augroup GeneralFormatting
  set fileformat=unix
  set fenc=utf-8
  set encoding=utf-8
  set termencoding=utf-8
  set splitright
  set textwidth=120
  set tabstop=2
	set t_Co=256 " enable colors in terminal
	colorscheme monochrome
	set background=dark
	set nu
augroup END

augroup GeneralSettings
	set clipboard^=unnamed,unnamedplus
	autocmd BufNewFile,BufRead * match BadWhitespace /\s\+$/
  set backspace=indent,eol,start
	" Folding settings
	set foldmethod=indent
	set foldlevel=99
	" Cursor line highlighting
	set cursorline
	highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=233 guifg=NONE guibg=#121212
	autocmd InsertEnter * highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=234 guifg=NONE guibg=#1c1c1c
	autocmd InsertLeave * highlight CursorLine cterm=NONE ctermfg=NONE ctermbg=233 guifg=NONE guibg=#121212
augroup END

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

"------------------- Spelling
set dictionary+=/usr/share/dict/words

function! SpellSuggestComplete(findstart, base)
  if a:findstart
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && !isspace(line[start - 1])
      let start -= 1
    endwhile
    return start
  else
    let suggestions = split(spellbadword(a:base)[1], '\n')
    return filter(suggestions, {_, v -> v != a:base})
  endif
endfunction

autocmd FileType * setlocal omnifunc=SpellSuggestComplete

" <leader> == \
"------------------- Key bindings
augroup KeyBindings
	nnoremap <space> za 
	nnoremap <silent> `z <cmd>lua require'centerpad'.toggle { leftpad = 80, rightpad = 40}<cr>
	" spelling stuff
	nnoremap <silent> <F8> :set nospell!<cr>
	inoremap <silent> <F8> <C-O>:set nospell!<cr>
	" file tree
	nnoremap <silent> `f :NvimTreeToggle<cr>
	" remove white space
	nnoremap <silent> <leader>rs :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>
	"see kee bindings
	nnoremap <leader>k :echo system("sed -n '101,110p' ~/.config/nvim/init.vim")<CR>
	" Execute file with python <F9>
	autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
	autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
augroup END

"------------------- Closing
let g:closetag_html_style = 1
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:closetag_auto_close = 1

"------------------- Markdown stuff 
lua vim.g.markdown_recommended_style = 1

"------------------- Enable nvim-autopairs
lua require('nvim-autopairs').setup()

"------------------- ROS Stuff
augroup ROSSettings
  autocmd BufRead,BufNewFile *.launch setfiletype roslaunch
  autocmd FileType html,xhtml,css,xml,xslt,vim,lua,nginx set shiftwidth=2 softtabstop=2
augroup END

"------------------- C stuff 

augroup CGroup
  autocmd BufNewFile,BufRead *.c,*.cpp,*.cc,*.h,*.hpp,*.ino setlocal tabstop=2 shiftwidth=2 expandtab | 
		setlocal comments=sl:/*,mb:\ *,elx:\ */ | 
		setlocal smartindent | 
		setlocal showmatch |
		autocmd BufNewFile,BufRead *.ino set filetype=cpp |
		let g:clang_format#enable_auto = 1 |
		let g:clang_format#style = 'google'
augroup END

"------------------ Start Python stuff

augroup PythonGroup
  autocmd BufRead,BufNewFile *.py,*.pyw setlocal tabstop=4 shiftwidth=4 expandtab |
		setlocal autoindent | 
		setlocal foldmethod=indent |
   	let b:autoformat_autoindent=1 |
		let b:autoformat_remove_trailing_spaces=0 |
		let b:autoformat_formatter='yapf' |
		let b:autoformat_options='--style google'
augroup END


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
    ensure_installed = { "pylsp", "marksman", "lemminx", "cmake", "clangd"}
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


-- You can also add additional LSP servers and configuration for other languages as needed

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
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

