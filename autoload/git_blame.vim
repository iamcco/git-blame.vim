" ============================================================================
" FILE: git_blame.vim
" AUTHOR: 年糕小豆汤 <ooiss@qq.com>
" License: MIT license
" ============================================================================

scriptencoding utf-8

let s:temp = resolve(tempname()) . '.git_blame'

function! s:is_no_name() abort
    let l:res = v:false
    let l:file_name = expand('%:p')
    if l:file_name ==# ''
        let l:res = v:true
    endif
    return l:res
endfunction

function! git_blame#get_git_dir() abort
    return fnamemodify(fnamemodify(finddir('.git', fnameescape(expand('%:p:h')) . ';'), ':p:h'), ':h')
endfunction

" parse blame info
function! git_blame#parse_blame(line) abort
    let l:res = {
                \ 'status': v:true,
                \ 'input': a:line,
                \ }
    if a:line =~? '\v^fatal'
        let l:res.status = v:false
    else
        let l:temp = substitute(a:line, '\v([^\(]*\([^\)]*\)).*$', '\1', '')
        let l:temp = split(l:temp, '(')
        let l:res.commit = get(l:temp, '0', '')
        let l:temp = split(get(l:temp, '1', ''), ' ')
        let l:res.user = join(l:temp[0:-5], ' ')
        let l:res.date = l:temp[-4:-4][0]
        let l:res.time = l:temp[-3:-3][0]
    endif
    return l:res
endfunction

" get blame of file
" @params: s_line, e_line, file_path, ext_cmd
function! git_blame#get_blame(...) abort
    let l:s_line = get(a:, '1', 1)
    let l:e_line = get(a:, '2', '')
    let l:file_path = get(a:, '3', expand('%:p'))
    let l:ext_cmd = get(a:, '4', '')
    " get file directory and file name
    let l:work_dir = git_blame#get_git_dir()
    let l:git_dir = l:work_dir . '/.git'
    let l:file_name = fnamemodify(l:file_path, ':s?\v^' . l:work_dir . '/??')
    " save current buffer to temp file
    silent! execute '%write !> ' . s:temp . ' 2> /dev/null'
    " join cmd
    let l:cmd = join([
                \ 'git',
                \ '--git-dir=' . shellescape(l:git_dir),
                \ '--work-tree=' . shellescape(l:work_dir),
                \ 'blame',
                \ '--contents',
                \ s:temp,
                \ '-L',
                \ l:s_line . ',' . l:e_line,
                \ l:file_name,
                \ l:ext_cmd,
                \ ], ' ')
    " get blame lines
    let l:git_blame_lines = systemlist(l:cmd)
    return l:git_blame_lines
endfunction

" get blame of current file
" @params: line_number
function! git_blame#get_lines_blame(...) abort
    let l:res = []
    if !s:is_no_name()
        let l:s_line = get(a:, '1', getcurpos()[1])
        let l:e_line = get(a:, '2', l:s_line)
        let l:res = git_blame#get_blame(l:s_line, l:e_line)
    endif
    return l:res
endfunction

" get blame of current file as obj
" @params: line_number
function! git_blame#get_lines_blame_parse(...) abort
    let l:res = []
    if !s:is_no_name()
        let l:s_line = get(a:, '1', getcurpos()[1])
        let l:e_line = get(a:, '2', l:s_line)
        let l:blame_info = git_blame#get_blame(l:s_line, l:e_line)
        for l:line in l:blame_info
            call add(l:res, git_blame#parse_blame(l:line))
        endfor
    endif
    return l:res
endfunction
