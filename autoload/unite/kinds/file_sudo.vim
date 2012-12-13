"=============================================================================
" FILE: file_sudo.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 27 Oct 2012.
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

" Global options definition. "{{{
"}}}

function! unite#kinds#file_sudo#define() "{{{
  return s:kind
endfunction"}}}

let s:System = vital#of('unite.vim').import('System.File')

let s:kind = {
      \ 'name' : 'file/sudo',
      \ 'default_action' : 'open',
      \ 'action_table' : {},
      \ 'parents' : ['openable', 'uri'],
      \}

" Actions "{{{
let s:kind.action_table.open = {
      \ 'description' : 'open files',
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.open.func(candidates) "{{{
  if !get(g:, 'vimfiler_as_default_explorer', 0)
    call unite#print_error('vimfiler is not default explorer.')
    call unite#print_error('Please set g:vimfiler_as_default_explorer is 1.')
    return
  endif

  for candidate in a:candidates
    call unite#util#smart_execute_command('edit', candidate.action__path)

    call unite#remove_previewed_buffer_list(
          \ bufnr(unite#util#escape_file_searching(
          \       candidate.action__path)))
  endfor
endfunction"}}}

let s:kind.action_table.cd = {
      \ 'description' : 'change vimfiler current directory',
      \ }
function! s:kind.action_table.cd.func(candidate) "{{{
  if &filetype ==# 'vimfiler'
    call vimfiler#mappings#cd(a:candidate.action__directory)
    call s:move_vimfiler_cursor(a:candidate)
  endif
endfunction"}}}

let s:kind.action_table.lcd = {
      \ 'description' : 'change vimfiler current directory',
      \ }
function! s:kind.action_table.lcd.func(candidate) "{{{
  if &filetype ==# 'vimfiler'
    call vimfiler#mappings#cd(a:candidate.action__directory)
    call s:move_vimfiler_cursor(a:candidate)
  endif
endfunction"}}}

let s:kind.action_table.narrow = {
      \ 'description' : 'narrowing candidates by directory name',
      \ 'is_quit' : 0,
      \ }
function! s:kind.action_table.narrow.func(candidate) "{{{
  if a:candidate.word =~ '^\.\.\?/'
    let word = a:candidate.word
  else
    let word = a:candidate.action__directory
  endif

  if word !~ '[\\/]$'
    let word .= '/'
  endif

  call unite#mappings#narrowing(word)
endfunction"}}}

let s:kind.action_table.vimfiler__write = {
      \ 'description' : 'save file',
      \ }
function! s:kind.action_table.vimfiler__write.func(candidate) "{{{
  let context = unite#get_context()
  let lines = split(unite#util#iconv(
        \ join(getline(context.vimfiler__line1, context.vimfiler__line2), "\n"),
        \ &encoding, &fileencoding), "\n")

  " Use temporary file.
  let tempname = tempname()

  try
    call writefile(lines, tempname)

    let filename = substitute(a:candidate.action__path, '^sudo:', '', '')

    let [status, output] = unite#sources#sudo#external(
          \ ['cp', tempname, filename])
  finally
    if filereadable(tempname)
      call delete(tempname)
    endif
  endtry
endfunction"}}}

"}}}

function! s:move_vimfiler_cursor(candidate) "{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  if has_key(a:candidate, 'action__path')
        \ && a:candidate.action__directory !=# a:candidate.action__path
    " Move cursor.
    call vimfiler#mappings#search_cursor(a:candidate.action__path)
  endif
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
