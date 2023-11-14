if exists('g:taskr_nvim_init') | finish | endif " so we don't init more than once 
let g:taskr_nvim_init = 1

let s:save_cpo = &cpo " save the users options
set cpo&vim " use the default vim options

" Highlighting
hi def link TaskrTask1 Identifier 
hi def link TaskrTask2 Keyword 

let &cpo = s:save_cpo " restore the options
unlet s:save_cpo

