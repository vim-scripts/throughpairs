fun! SpaceSpread(normal,positive)
	let cur_pos = getpos('.')
    " if getline('.')[cur_pos[2]-1] == '(' && getline('.')[cur_pos[2]] == ')' 
        " echo 'got it!!!'
        " normal a  
    " endif
    if a:normal
        normal h
    endif
    if a:positive

        normal f)i 
        normal %a 
        call setpos('.',cur_pos)
        if !a:normal
            normal l
        endif
        normal l
    else
        
        normal f)h
        if getline('.')[col('.')-1] == ' ' 
            normal x
            normal %l
            " echo col('.')
            if getline('.')[col('.')-1] == ' ' 
                normal x
            endif
        else
            call setpos('.',cur_pos)
            if !a:normal
                normal l
            endif
            return
        endif
        call setpos('.',cur_pos)
        if a:normal && !a:positive 
            normal h
        endif
    endif
endfun

if has('unix')
	set <M-l>=l
	set <M-h>=h
endif

nmap <silent><M-l> :call SpaceSpread(1,1)<cr>
imap <silent><M-l> <ESC>:call SpaceSpread(0,1)<cr>i
nmap <silent><M-h> :call SpaceSpread(1,0)<cr>
imap <silent><M-h> <ESC>:call SpaceSpread(0,0)<cr>i
" (  <esc>hi(  hi))
" (  h)
" " " " " " " " " " " " " " " " " " " (h (woei>)(        ())(ÛÛÛÛÛÛÛ) )
" " " " " " " " " " " " ( (woei>)(        ())(ÛÛÛÛÛÛÛ) )
" " " " " " " " " " " " ( (woei>)(        ())(ÛÛÛÛÛÛÛ) )
" " " " " " " " " " " " ( (woei>)(        ())(ÛÛÛÛÛÛÛ) )
" " " " " " " " " " " " ( (woei>)(        ())(ÛÛÛÛÛÛÛ) )
" " " " " " " " " " " " ( (woei>)(        ())(ÛÛÛÛÛÛÛ) )
" " " " " " " " " " " " ( (woei>)(        ())(ÛÛÛÛÛÛÛ) )
" " " " " " " " " " " " " ( (                                 woei>                                 )(        ())(ÛÛÛÛÛÛÛ) )
" ie + owie +  (woei>oei+)
" ()()   ( weoi>oiew+)     (
" ( oewi>woei+)
" ()                               ()
" ()
" (
" (  `l:)        (ÛÛÛÛÛÛÛÛÛÛ)
" ( ()
" ()( (,f(                                ),) )
" ()fun(weofijweoi+)
