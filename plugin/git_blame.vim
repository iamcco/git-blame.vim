"===============================================================================
"File: plugin/git_blame.vim
"Maintainer: iamcco <ooiss@qq.com>
"Licence: Vim Licence
"Version: 0.0.1
"===============================================================================

if exists('g:loaded_git_blame')
    finish
endif
let g:loaded_git_blame = 1

let s:save_cpo = &cpo
set cpo&vim
"-------------------------------------------------------------------------------

function! s:timer_start() abort
    if exists('s:timer')
        call timer_stop(s:timer)
    endif
    let s:timer = timer_start(500, function('s:update_line_blame'))
endfunction

function! s:timer_stop() abort
    if exists('s:timer')
        call timer_stop(s:timer)
    endif
endfunction

function! s:update_line_blame(timer) abort
    let b:git_blame_current_line = get(git_blame#get_lines_blame_parse(), '0', '')
    if exists('#User#Git_Blame_Update')
        doautocmd <nomodeline> User Git_Blame_Update
    endif
endfunction

augroup Git_Blame
    autocmd!
    autocmd CursorHold,CursorHoldI,CursorMoved,CursorMovedI * call s:timer_start()
    autocmd VimLeavePre * call s:timer_stop()
augroup END

"-------------------------------------------------------------------------------
let &cpo = s:save_cpo
unlet s:save_cpo
