"=============================================================================
" FILE: sudo.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 23 Oct 2012.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

" Variables  "{{{
call unite#util#set_default(
      \ 'g:unite_source_sudo_enable_debug', 0)
"}}}

function! unite#sources#sudo#define() "{{{
  return unite#util#has_vimproc() ? s:source : {}
endfunction"}}}

let s:source = {
      \ 'name' : 'sudo',
      \ 'description' : 'candidates from sudo',
      \}

function! s:source.change_candidates(args, context) "{{{
  " Todo
  return []
endfunction"}}}
function! s:source.vimfiler_check_filetype(args, context) "{{{
  let path = s:parse_path(a:args)

  if isdirectory(path)
    return ['directory', 'sudo:' . path]
  endif

  let type = 'file'

  " Use temporary file.
  let dict = unite#sources#file#create_file_dict(path, 0)
  let dict.action__path = 'sudo:' . dict.action__path
  let dict.kind = 'file/sudo'
  if !filereadable(path)
    " New file.
    let lines = []
  else
    let [status, output] = unite#sources#sudo#external(['cat', path])
    if status
      call unite#print_error(printf('Failed file "%s" cat : %s',
            \ path, unite#util#get_last_errmsg()))
    endif

    let lines = split(output, '\r\n\|\n')
  endif

  return [type, [lines, dict]]
endfunction"}}}
function! s:source.vimfiler_gather_candidates(args, context) "{{{
  " Todo
  return []
endfunction"}}}
function! s:source.vimfiler_dummy_candidates(args, context) "{{{
endfunction"}}}
function! s:source.vimfiler_complete(args, context, arglead, cmdline, cursorpos) "{{{
  return unite#sources#file#complete_file(
        \ a:args, a:context, a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}
function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  return unite#sources#file#complete_file(
        \ a:args, a:context, a:arglead, a:cmdline, a:cursorpos)
endfunction"}}}

function! unite#sources#sudo#copy_files(dest, srcs) "{{{
  " Todo
endfunction"}}}
function! unite#sources#sudo#move_files(dest, srcs) "{{{
  " Todo
endfunction"}}}
function! unite#sources#sudo#delete_files(srcs) "{{{
  " Todo
endfunction"}}}

function! unite#sources#sudo#external(args) "{{{
  let args = ['sudo'] + a:args
  let output = vimproc#system_passwd(args)
  if g:unite_source_sudo_enable_debug
    echomsg 'command_line = ' . string(args)
    echomsg 'output = ' . output
  endif

  let status = vimproc#get_last_status()
  if status && g:unite_source_sudo_enable_debug
    call unite#print_error(printf(
          \ 'Failed command_line "%s": %s',
          \ join(args), vimproc#get_last_errmsg()))
  endif

  return [status, output]
endfunction"}}}

function! s:parse_path(args) "{{{
  let path = unite#util#substitute_path_separator(
        \ unite#util#expand(join(a:args, ':')))
  let path = unite#util#substitute_path_separator(
        \ fnamemodify(path, ':p'))

  return path
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
