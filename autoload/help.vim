" Goto a position specified with a pattern 'count' times.
function! help#goto(pattern, ...)
    let counter = v:count1
    let flag = a:0 == 0 ? '' : a:1
    while counter > 0
        " search without affecting search history
        silent call search(a:pattern, flag)
        let counter = counter - 1
    endwhile
endfunction
