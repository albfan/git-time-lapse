function! Display(commit)
	diffoff!
	wincmd t
	if t:current == t:total - 1
      enew
   else
	   exe 'e '.t:path
	   exe 'Gedit '.a:commit.'~1:'.t:path
   endif

	wincmd l
	exe 'e '.t:path
	exe 'Gedit '.a:commit.':'.t:path
	map <silent> <buffer> <CR> :call Blame() <cr>

	wincmd j
	exe '%d'
	exe ':silent :0 read !git log --stat -1 '.a:commit
	exe 'normal ggA ('.(t:total - t:current).' / '.t:total.')'
	setfiletype git

	wincmd t
	diffthis
	wincmd l
	diffthis

	wincmd j
	normal gg
endfunction

function! Goto(pos)
	let t:current = a:pos

	if t:current < 0
		let t:current = 0
      echom "Trying to go above last change"
	elseif t:current > t:total - 1
		let t:current = t:total - 1
      echom "Trying to go beyond first change"
	endif

	call Display(t:commits[t:current])
endfunction

function! Move(amount)
	call Goto(t:current + a:amount)
endfunction

function! Blame()
	let current = t:commits[t:current]
	let line = getpos(".")[1]

	let output = system('git blame -p -n -L'.line.','.line.' '.
						\current.' -- '.t:path)

	let results = split(output)

	if results[0] == "fatal:"
      echom split(output, '\n')[0]
		return
	endif

	for i in range(len(t:commits))
		if t:commits[i] =~ results[0]
			call Goto(i)
			break
		endif
	endfor

	wincmd t
	wincmd l
	exe ':'.results[1]
	normal z.
endfunction

function! GetLog()
	let tmpfile = tempname()
	exe ':silent :!git log --no-merges --pretty=format:"\%H" '.t:path.' > '.tmpfile
	let t:commits = readfile(tmpfile)
	call delete(tmpfile)
	let t:total = len(t:commits)
	return t:total
endfunction

function! ChDir()
	" Change directory to the one with .git in it and return path to the
	" current file from there. If you live in this directory and execute git
	" commands on that path then everything will work.
	cd %:p:h
	let dir = finddir('.git', '.;')
	exe 'cd '.dir.'/..'
	let path = fnamemodify(@%, ':.')
	return path
endfunction

function! TimeLapse()
	" Open a new tab with a time-lapse view of the file in the current
	" buffer.
	let path = ChDir()

	tabnew
	let t:path = path

	if GetLog() <= 1
		tabclose
		return
	endif

	set buftype=nofile

	new
	set buftype=nofile

	wincmd j
	resize 10
	set winfixheight

	" Go backwards and forwards one commit
	map <silent> <buffer> <Left> :call Move(1) <cr>
	map <silent> <buffer> <Right> :call Move(-1) <cr>

	" Rewind all the way to the start or end
	map <silent> <buffer> <S-Left> :call Goto(t:total - 2) <cr>
	map <silent> <buffer> <S-Right> :call Goto(0) <cr>


	wincmd k
	vnew
	set buftype=nofile

	" The first line in the file is the most recent commit
	let t:current = 0
	call Display(t:commits[t:current])
endfunction

command! TimeLapse call TimeLapse()

