
" Modification of https://github.com/chrisbra/vim_dotfiles/blob/master/plugin/CustomFoldText.vim

function! s:strwidth(str) abort
    if exists('*strwidth')
        return strwidth(a:str)
    else
        return strlen(string(a:str))
    endif
endfunction

function! CustomFoldText(string) abort
    " get first non-blank line
    let fs = v:foldstart
    if getline(fs) =~ '^\s*$'
        let fs = nextnonblank(fs + 1)
    endif
    if fs > v:foldend
        let line = getline(v:foldstart)
    else
        let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    endif
    let pat  = matchstr(&l:cms, '^\V\.\{-}\ze%s\m')
    " remove leading comments from line
    let line = substitute(line, '^\s*' . pat . '\s*', '', '')
    " remove foldmarker from line
    let pat  = '\%(' . pat . '\)\?\s*' . split(&l:fmr, ',')[0] . '\s*\d\+'
    let line = substitute(line, pat, '', '')
    " let line = substitute(line, matchstr(&l:cms, '^.\{-}\ze%s') . '\?\s*' . split(&l:fmr,',')[0] . '\s*\d\+', '', '')

    let foldLineHead = line

    let win_size = get(g:, 'custom_foldtext_max_width', winwidth(0))
    let sign_column_size = has('signs') && !empty(sign_getplaced(bufname('%'), { 'group': '*' })[0]['signs']) ? 2 : 0
    let w = win_size - &foldcolumn - (&number ? s:strwidth(line('$')) : 0) - sign_column_size

    let foldSize = 1 + v:foldend - v:foldstart

    let foldPercentage = ''
    if has('float')
        let lineCount = line('$')
        try
            let foldPercentage = printf('[%4.1f%%] ', (foldSize * 1.0) / lineCount * 100)
        catch /^Vim\%((\a\+)\)\=:E806/	" E806: Using Float as String
            let foldPercentage = printf('[of %d lines] ', lineCount)
        endtry
    endif

    " indent foldtext corresponding to foldlevel
    let indent = repeat(' ', exists('*shiftwidth') ? shiftwidth() : &shiftwidth)
    let indent = ''

    let foldSizeStr = printf(' %4d lines ', foldSize)
    let foldLevelStr = '+' . v:folddashes
    let foldLevelStr = '' " disable fold level display

    let foldLineTail = foldSizeStr . foldPercentage . foldLevelStr . indent

    if exists('*strwidth')
        let expansionLength = w - strwidth(foldLineHead . foldLineTail)
    else
        let expansionLength = w - strlen(substitute(foldLineHead . foldLineTail, '.', 'x', 'g'))
    endif
    let expansionString = repeat(a:string, expansionLength)

    return foldLineHead . expansionString . foldLineTail
endf

set foldtext=CustomFoldText('\ ')
