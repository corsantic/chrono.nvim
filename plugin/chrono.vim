" plugin/regvim.vim
if exists('g:loaded_chrono') | finish | endif

" Commands
command! Chrono lua require'chrono'.toggle()
command! ChronoEnable lua require'chrono'.enable()
command! ChronoDisable lua require'chrono'.disable()

" Auto-setup
autocmd VimEnter * ++once lua require'chrono'.setup()

let g:loaded_regvim = 1
