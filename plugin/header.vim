""
""  File							: header.vim
""	 Path							: /home/dio/.vim/plugin/header.vim
""  Created by					: Pierre "Za_warudo" SAILLARD
""  Login						: dio
""
""  Started						: [Sun 09 Oct 2016 01:42:06]
""  Last modification		: [Fri 28 Oct 2016 12:00:28]
""

function InsertHeader()
	let s:ext = expand('%:e')
	let s:file = expand('%:t')
	let s:path = expand('%:p')
	let s:tplFile = g:VIMTEMPLATES."headerDefault.vimtpl"
	let s:tplRg = FileLineNum(s:tplFile)

	"copy the template at the beginning of the file
	"delete the empty line at the file's first line
	normal gg
	execute "read ".s:tplFile
	normal ggdd

	"this first 'if' statement is absolutely unneccesary unless you prefer your C headers commented using the pair '/*' and '*/' instead of '//' (it's my case).
	if (s:ext != 'c' && s:ext != 'cpp' && s:ext != 'h' && s:ext != 'hh')
		if (has_key(g:dictComments, s:ext))
			execute "1,".s:tplRg."substitute/^[\/\*][\*\/]/".g:dictComments[s:ext]."/e"
		endif
	endif

	"replace fillers
	execute "1,".s:tplRg."substitute/USERFNAME \"USERNNAME\" USERLNAME/".g:userFirstName." \"".g:userNickName."\" ".g:userLastName."/"
	execute "1,".s:tplRg."substitute/CURRENTFILENAME/".s:file
	"" slashes in the path are interpreted so escape() has to be used to avoid
	""it
	execute "1,".s:tplRg."substitute/CURRENTFILEPATH/".escape(s:path, '/')
	execute "1,".s:tplRg."substitute/USERLOGIN/".$USER
	execute "1,".s:tplRg."substitute/DATEOFTHEDAY/".strftime("%a %d %b %Y %T", localtime())

	if (s:ext == 'h' || s:ext == 'hh')
		call Includeguard(s:file)
	endif

	if (has_key(g:dictShebang, s:ext))
		call Shebang(g:dictShebang[s:ext])
	endif
	normal G
endfunction

function Shebang(interp)
	"add a shebang formated like this => #!/usr/bin/(interp)
	normal ggO
	execute "normal 0d$i#!/usr/bin/".a:interp
endfunction

function ScriptExecRights()
	""set the file permissions the same way as 'chmod 751 filename' if it is a
	""script file
	let s:path = expand('%:p')

	if (has_key(g:dictShebang, expand('%:e')) && getfperm(s:path) != "rwxr-x--x")
		call setfperm(s:path, "rwxr-x--x")
	endif
endfunction

function Includeguard(filename)
	"if the file is a .h or a .hh, this function add basic include guards
	normal Go
	let s:fname = a:filename
	let s:file = substitute(toupper(s:fname), '\.', "_", "")
	let s:tplFile = g:VIMTEMPLATES."includeguardC.vimtpl"
	"1 is substracted since the substitution range will be ralative and the
	"first line is counted as 0
	let s:tplRge = FileLineNum(s:tplFile) - 1

	execute "read ".s:tplFile
	execute ".,.+".s:tplRge."substitute/CURRENTHEADERNAME/".s:file."/e"
endfunction

function UpdateHeader()
	"update last modification date
	let s:curpos = getcurpos()
	let s:lastmod = "Last modification\t\t: [".strftime("%a %d %b %Y %T", localtime ())."]"
	let s:tplFile = g:VIMTEMPLATES."headerDefault.vimtpl"
	let s:tplRge = FileLineNum(s:tplFile)

	execute "1,".s:tplRge.'substitute/Last modification\s\+:\s\+\[.*]/'.s:lastmod
	call setpos('.', s:curpos)
endfunction
