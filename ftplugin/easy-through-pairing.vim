let g:closingList = ["'",'"',")","]",">","}","$",'\',':']

fun EasyThrough()
	if &ft == 'python' 
		if getline('.')[col('.')-1:col('.')] == '):'
			return "\<Right>\<Right>\<Enter>"
		elseif getline('.')[col('.')] != ':' 
					\&& getline('.')[col('.')-1] == ')' 
					\&& col('.') == col('$') -1
					\&& getline('.') =~ 'def'
			return "\<Right>\:\<Enter>"
		endif
	endif
	let closing = getline('.')[col('.')-1]
	let current_linenum = line('.')
	for avoid in g:closingList
		if closing == avoid
			return "\<Right>"
		endif
	endfor   
	if &ft == 'c' && getline('.')[col('.')-2] == ')' && col('.') == col('$')
		return "\<Right>\{\<Enter>\}\<C-[>O"
	endif
	if &ft == 'python' 
		if getline('.')[col('.')-1] != ':' 
					\&& getline('.')[col('.')-2] == ')' 
					\&& col('.') == col('$') 
					\&& getline('.') =~ 'def'
			return "\:\<Enter>"
		endif
		if getline('.')[col('.')-2] == ':'
			return "\<enter>"
		endif
	endif
	if pumvisible()
		return "\<Insert>\<Insert>"
	endif
	if col('.') == col('$')
		return "\<enter>"
	else
		return "\<Insert>\<Insert>"
	endif
endfun
inoremap <expr> j pumvisible() ? "\<C-N>" : "j"
inoremap <expr> k pumvisible() ? "\<C-P>" : "k"
inoremap <expr> <A-j> pumvisible() ? "\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>" : "\<A-j>"
inoremap <expr> <A-k> pumvisible() ? "\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>" : "\<A-k>"
inoremap <expr> <A-J> pumvisible() ? "\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>" : "\<A-J>"
inoremap <expr> <A-K> pumvisible() ? "\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>" : "\<A-K>"
inoremap <silent><C-j> <C-R>=EasyThrough()<CR>
inoremap <silent><C-j> <C-R>=EasyThrough()<CR>

let s:sav_clos_pos = []
let s:sav_open_pos = []
let s:search_dict  = {}
let s:paired = 0
fun TheBiggestSmallerThan(arg)
	for index in range(len(s:sav_open_pos))
		if s:sav_open_pos[index] < a:arg
			let tmp = s:sav_open_pos[index]
			call remove(s:sav_open_pos,index)
			return tmp
		endif
	endfor
endf
fun PairingBrackets()
	let s:search_dict = {}
	let s:sav_open_pos = []
	let s:sav_clos_pos = []
	for i in range(col('$'))
		let current_char = getline('.')[i]
		if current_char == '('
			call insert(s:sav_open_pos,i)
		elseif current_char == ')'
			call insert(s:sav_clos_pos,i)
		endif
	endfor
	let s:paired = 0
	if len(s:sav_open_pos) != len(s:sav_clos_pos)
		" redraw!
		echo 'Please, check if or not brackets are closed!'
	endif
	if len(s:sav_clos_pos) > 0
		normal ^
		let numbering = 0
		for i in range(col('$'))
			if getline('.')[i] == ')'
				let appro_i = TheBiggestSmallerThan(i)
				let s:search_dict[numbering] = [appro_i,i]
				let numbering += 1
			endif
		endfor
		let s:paired = 1
	endif
	" echo s:search_dict
	" echo s:sav_open_pos
endf
let s:order_i = 0
function LocatePos(arg,forapt)
	call PairingBrackets()
	if s:paired
		let order = keys(s:search_dict)
		let pos = [0,line('.'),s:search_dict[order[s:order_i]][a:forapt]+1,0]
		" echo pos
		if a:arg == 1
			let s:order_i += 1
		elseif a:arg == -1
			let s:order_i -= 1
		endif
		if s:order_i > len(order) -1
			let s:order_i = 0
		elseif s:order_i < 0
			let s:order_i = len(order) -1
		endif
		" call setpos("'x",pos)
		call setpos('.',pos)
	endif
endfunction
" nmap ,z :call PairingBrackets()<CR>
" nmap ,x :call LocatePos()<CR>

" front attatch - Alt"
imap <silent><A-q> <C-[> : call LocatePos(1,0)<CR>a
imap <silent><A-b> <C-[> : call LocatePos(-1,0)<CR>a
" rear attatch - Ctrl"
imap <silent><C-q> <C-[> : call LocatePos(1,1)<CR>i
imap <silent><C-b> <C-[> : call LocatePos(-1,1)<CR>i

nmap <silent><A-q>       : call LocatePos(1,0)<CR>a
nmap <silent><A-b>       : call LocatePos(-1,0)<CR>a
nmap <silent><C-q>       : call LocatePos(1,1)<CR>i
nmap <silent><C-b>       : call LocatePos(-1,1)<CR>i

" through-pair-brackets.vim
" (((((((())))))))
