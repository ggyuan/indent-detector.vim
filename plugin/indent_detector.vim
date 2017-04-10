"Script Title: Indent Detector
"Script Version: 0.0.5
"Author: luochen1990
"Last Edited: 2015 July 6

if exists('s:loaded')
	finish
else
	let s:loaded = 1
endif

func indent_detector#search_nearby(pat)
	return search(a:pat, 'Wnc', 0, 20) > 0 || search(a:pat, 'Wnb', 0, 20) > 0
endfunc

func indent_detector#detect(autoadjust)
	let leadtab = indent_detector#search_nearby('^\t')
	let leadspace = indent_detector#search_nearby('^ ')
	if leadtab + leadspace < 2 && indent_detector#search_nearby('^\(\t\+ \| \+\t\)') == 0
		if leadtab
			if a:autoadjust
				setl noexpandtab nosmarttab tabstop=4 shiftwidth=4 softtabstop=4
			endif
			return 'tab'
		elseif leadspace
			let spacenum = 0
			if indent_detector#search_nearby('^ [^\t ]')
				let spacenum = 1
			elseif indent_detector#search_nearby('^  [^\t ]')
				let spacenum = 2
			elseif indent_detector#search_nearby('^   [^\t ]')
				let spacenum = 3
			elseif indent_detector#search_nearby('^    [^\t ]')
				let spacenum = 4
			endif
			if a:autoadjust
				let n = spacenum ? spacenum : 4
				exec 'setl expandtab smarttab tabstop='.n.' shiftwidth='.n.' softtabstop='.n
			endif
			return 'space * '.(spacenum ? spacenum : '>4')
		else
			return 'default'
		endif
	else
		return 'mixed'
	endif
endfunc

" echolevel: 0 - none; 1 - error; 2 - warnning; 3 - info (all)
func indent_detector#hook(autoadjust, echolevel)
	if &readonly == 0 "if file writeable
		let rst = indent_detector#detect(a:autoadjust)
		if rst == 'mixed'
			if a:echolevel > 0
				echohl ErrorMsg | echom 'mixed indent' | echohl None 
			endif
		elseif rst[0] == 's' "space
			if rst[8] == '>' "too many
				if a:echolevel > 1
					echohl WarningMsg | echom 'too many leading spaces here.' | echohl None 
				endif
			else
				if a:echolevel > 2
					silent echo 'indent: '.rst
				endif
			endif
		endif
	endif
endfunc

auto bufenter * call indent_detector#hook(1, 3)
