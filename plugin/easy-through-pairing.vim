let g:closingList = ["'",'"']
let g:closingListMore = [")","]",">","}","$",'\',':']
" 
fun! Condition2(arg)
	if getline('.')[col('.')] != ':' 
				\&& col('.') == col('$')
				\&& getline('.') =~ a:arg
		return 1
	else
		return 0
	endif
endfun
fun! Condition1(arg)
	if getline('.')[col('.')] != ':' 
				\&& getline('.')[col('.')-1] == ')' 
				\&& col('.') == col('$') -1
				\&& getline('.') =~ a:arg
		return 1
	else
		return 0
	endif
endfun
fun! EasyThrough()
	let closing = getline('.')[col('.')-1]
	let current_linenum = line('.')
	for avoid in g:closingList
		if closing == avoid
			return "\<Right>"
		endif
	endfor   
	if &ft == 'html' 
		if getline('.')[col('.')-1:col('.')] == '</'
			return "\<End>\<Enter>"
		endif
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
		if getline('.')[col('.')-1:col('.')] == '):'
			return "\<Right>\<Right>\<Enter>"
		" elseif Condition1('def') || Condition1('if') || Condition1('while') || Condition1('elseif') || Condition1('class')
		elseif Condition1('def') || Condition1('while') || Condition1('elseif') || Condition1('class')
			return "\<Right>\:\<Enter>"
		elseif Condition2('for ') || Condition2('if ') || Condition2('while ') || Condition2('elseif ') || Condition2('else')
			return ":\<Enter>"
		endif
	endif
	if &ft == 'c' || &ft == 'javascript'
		if getline('.')[col('.')-1] == ')'
					\&& getline('.')[col('.')+1] == '{'
			echo "1"
			return "\<esc>^i\<Down>\<Right>\<Right>\<Right>\<Right>\<esc>"
		elseif getline('.')[col('.')-1] == ')' 
			echo "2"
						\&& CheckBelow()
			return "\<esc>^i\<Down>\<Down>\<Right>\<Right>\<Right>\<Right>\<esc>"
		elseif getline('.')[col('.')-1] == ')' && col('.') == col('$') -1
			echo "1"
			return "\<Right>\<Right>\{\<Enter>\}\<C-[>O"
			" else
			" return "\<Esc>^ji"
		endif
	endif
	if pumvisible()
		return "\<Insert>\<Insert>"
	endif
	for avoid in g:closingListMore
		if closing == avoid
			return "\<Right>"
		endif
	endfor   
	if col('.') == col('$')
		" return a:char.a:char."\<Esc>i"
		" return a:char.a:char."\<Esc>i"
		return "\<Esc>^ji"
		" return "\<enter>"
	else
		return "\<ESC>ea"
		" return "\<Insert>\<Insert>"
	endif
endfun
fun! CheckBelow()
	normal ^j
	let ccc = getline('.')[col('.')-1]
	if ccc == '{'
		normal k
		return 1
	else
		normal k
		return 0
	endif
endfun
inoremap <expr> j pumvisible() ? "\<C-N>" : "j"
inoremap <expr> k pumvisible() ? "\<C-P>" : "k"
" inoremap <expr> <space> pumvisible() ? "\<CR>"  : "\<space>"

inoremap <expr> <M-j> pumvisible() ? "\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>" : "\<A-j>"
inoremap <expr> <M-k> pumvisible() ? "\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>" : "\<A-k>"
                                                           
inoremap <expr> <M-J> pumvisible() ? "\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>\<C-N>" : "\<A-J>"
inoremap <expr> <M-K> pumvisible() ? "\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>\<C-P>" : "\<A-K>"


inoremap <expr> <C-o> pumvisible() ? "\<C-x>\<C-o>" : "\<C-o>"
inoremap <silent><C-j> <C-R>=EasyThrough()<CR>

fun! EasyThroughBack()
	return "\<Esc>bi"
endf
inoremap <silent><C-f> <C-R>=EasyThroughBack()<CR>

let s:sav_clos_pos = []
let s:sav_open_pos = []
let s:search_dict  = {}
let s:paired = 0
fun! TheBiggestSmallerThan(arg)
	for index in range(len(s:sav_open_pos))
		if s:sav_open_pos[index] < a:arg
			let tmp = s:sav_open_pos[index]
			call remove(s:sav_open_pos,index)
			return tmp
		endif
	endfor
endf
fun! PairingBrackets()
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
endf
let s:order_i = 0
let s:prev_line = 0 
function! LocatePos(arg,forapt)
	call PairingBrackets()
    let lin_num = line('.')
    let col_num = virtcol('.')
    let cur_pos = getpos('.')
	if s:paired
		let order = keys(s:search_dict)
        " try
        if lin_num != s:prev_line 
            let s:order_i = -1
        endif
        let pos = [0,lin_num,s:search_dict[order[s:order_i]][a:forapt]+1,0]
        " let pos = [0,line('.'),s:search_dict[order[s:order_i]][a:forapt]+1,0]
        let s:prev_line = lin_num

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
		call setpos('.',pos)
	endif
endfunction
" nmap ,z :call PairingBrackets()<CR>
" nmap ,x :call LocatePos()<CR>

if has('unix')
	set <M-f>=f
	set <M-b>=b
endif
"------------------"
" backward traverse"
imap <silent><M-b> <C-[>:call LocatePos(-1,0)<CR>a
nmap <silent><M-b> :call LocatePos(-1,0)<cr>a
"------------------"

"------------------"
" forward traverse"
imap <silent><M-f> <C-[>:call LocatePos(1,1)<CR>i
nmap <silent><M-f> :call LocatePos(1,1)<CR>i
"------------------"
  

" through-pair-brackets.vim
" ((kkkk((wef(wefewfe(((wefk)m)ÛÛÛÛÛÛÛ)ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ)(()ÛÛÛÛÛh)))ÛÛÛÛÛÛÛÛÛÛÛÛ) ()
" (weoi+)(wefiojo)(weoifj;)(oêewofijê(îweofi(weojif);)(woe+i(weoi+(weofij))))
