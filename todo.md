# What's next?
Make a portable vim sub-distribution. Currently vim-light has directories that
located on ~/.vim/tmp/*.

Make a :B command to jump to a existing window containing the buffer you want to
switch to, even though the target window is at a different tab.

Change to vimwiki or todo.txt to manage tasks

Carefully craft a vim-session file, like including local options to a
window(args) and buffer

Check vim crash-recovery and security related options.

Check vim syntax and spell section.

Check vim remote features(server and client mode)

Map some alt keys to vim.

Check vim remote options and upload a single vimrc to net, then use ":e
http://example.com/vimrc" to load and source my essential vimrc.

# Make the new installing and updating scripts after switching to pathogen
 - Split core configuration to vicrc.
    - config statusline
 - Craft vilrc. If pathogen not included, then the directory "vil" should just
    be removed; Else, I may create link to the subdirectories in "vim"(differently
    on unix and window, so this process would be kept in bootstrap.sh).
 - Describe bundles in details in "bundles.md", and adjust the
   "git-clone.sh" script accordingly.
 - Modify bootstrap.sh

# Project management
Task management tools wanted.(May consider tools in pure vim environment as long as
current project is small and the tool has enough power.)
Need tools for feature request, bug tracking etc.
I really should learn agile development and _practice_ to be a better developer.
