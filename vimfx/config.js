// The main config file for VimFx
//
// Open about:config and search ".vimfx"
// First, set "extensions.VimFx.config_file_directory" to
// "~/.config/vimfx"
//
// https://github.com/akhodakivskiy/VimFx/blob/master/documentation/config-file.md
// https://github.com/akhodakivskiy/VimFx/blob/master/documentation/api.md#configjs-api
// https://github.com/lydell/vim-like-key-notation
// https://github.com/lydell/dotfiles/blob/master/.vimfx/config.js

vimfx.set('hint_chars', 'fjdkslagheiworuvmbncxzqpty')
vimfx.set('prevent_autofocus', true)

let map = (command, shortcuts) => {
    vimfx.set(`mode.normal.${command}`, shortcuts)
}

// Ordered alphabetically on command names
map('click_browser_element', 'zo')
map('enter_reader_view', 'zr')
map('follow_in_focused_tab', 'go')
map('follow_in_window', 'gO')
map('follow_multiple', 'gm')
map('follow_next', ']]')
map('follow_previous', '[[')
map('history_back', 'H <backspace>')
map('history_forward', 'L <s-backspace>')
map('reload_all', 'gr')
map('reload_all_force', 'gR')
map('reload_config_file', 'zR')
map('scroll_left', '<a-h>')
map('scroll_right', '<a-l>')
map('scroll_to_mark', "` '")
map('stop_all', 'gs')
map('tab_close_other', 'gX')
map('tab_close_to_end', 'gx')
map('tab_move_backward', '<')
map('tab_move_forward', '>')
map('tab_new', '')
map('tab_restore', 'U')
map('tab_restore_list', 'gL')
map('tab_select_next', 'l gt')
map('tab_select_oldest_unvisited', 'g9')
map('tab_select_previous', 'h gT')
