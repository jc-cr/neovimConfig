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
