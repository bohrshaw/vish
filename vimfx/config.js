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
vimfx.set('mode.ignore.exit', '<s-escape> <a-i>')
vimfx.set('prevent_autofocus', true)
vimfx.set('scroll.last_position_mark', "'")

let map = (command, shortcuts) => {
    vimfx.set(`mode.normal.${command}`, shortcuts)
}

// Ordered alphabetically on command names
map('click_browser_element', 'o')
map('enter_mode_ignore', 'I')
map('enter_reader_view', 'yr')
map('find_links_only', ';')
map('focus_location_bar', '')
map('focus_search_bar', '')
map('follow_in_focused_tab', 't')
map('follow_in_window', 'gw')
map('follow_multiple', 'gm')
map('follow_next', ']]')
map('follow_previous', '[[')
map('history_back', 'H <backspace>')
map('history_forward', 'L <s-backspace>')
map('quote', 'i')
map('reload_all', 'gr')
map('reload_all_force', 'gR')
map('reload_config_file', 'zr zR')
map('scroll_left', '<a-h>')
map('scroll_right', '<a-l>')
map('scroll_to_mark', "` '")
map('stop_all', 'gs')
map('tab_close_other', 'go')
map('tab_close_to_end', 'gx')
map('tab_move_backward', '<')
map('tab_move_forward', '>')
map('tab_move_to_window', 'yw')
map('tab_new', '')
map('tab_new_after_current', 'T')
map('tab_restore', 'U')
map('tab_restore_list', 'gL')
map('tab_select_most_recent', 'gl gp')
map('tab_select_next', 'l gt')
map('tab_select_oldest_unvisited', 'g9')
map('tab_select_previous', 'h gT')
map('tab_toggle_pinned', 'zp')
map('window_new', '')
map('window_new_private', '')
