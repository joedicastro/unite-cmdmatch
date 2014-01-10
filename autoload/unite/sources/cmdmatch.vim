let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'cmdmatch',
      \ 'description': 'candidates for command line completition',
      \ 'hooks': {},
      \ 'action_table': {'*': {}},
      \ 'default_action': {'*': 'continue'},
      \ 'default_kind': 'command',
      \ }

let s:unite_source.action_table['*'].continue = {
      \ 'description' : 'continue editing',
      \ 'is_quit' : 1,
      \ }

fu! s:unite_source.action_table['*'].continue.func(candidate)
    call feedkeys(':' . (s:prefix != '' ? s:prefix . ' ' : '') . a:candidate.action__command)
endf

fu! s:GetCmdCompletition(cmd)

    let [cwh,ls,v] = [&cwh, &ls, @v]
    set cwh=1 ls=0

    exe 'nn <buffer> z&u :' . a:cmd . '<c-a><c-f>"vyyo<cr>'
    norm z&u
    let res = split(@v)

    let [&cwh,&ls,@v] = [cwh,ls,v]
    return res
endf

fu! s:unite_source.gather_candidates(args, context)
    let arg = get(a:args, 0, '')

    let i = strridx(arg, ' ')
    let s:prefix = strpart(arg, 0, i)
    let sufix = strpart(arg, i+1)
    let c = strpart(sufix, 0, 1)

    let clist = s:GetCmdCompletition(c)
    retu map(clist, '{ "word": v:val,  "kind": ["common", "command"], "action__command": v:val  }')
endf

fu! unite#sources#cmdmatch#define()
  retu s:unite_source
endf

call unite#define_source(s:unite_source)
call unite#custom#profile('source/common', 'ignorecase', 1)
"call unite#custom#source('cmdmatch', 'filters',['matcher_fuzzy'])

cno <c-o> <c-f>^"vyg_ddo<cr>:Unite -buffer-name=cmdmatch -direction=botr -start-insert -input=<c-r>=strpart(@v, strridx(@v, ' ')+1)<cr> cmdmatch:<c-r>=escape(@v,' ')<cr><cr>
