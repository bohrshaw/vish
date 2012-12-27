vimise
========

> Vim Distribution For Personal Taste!

### Goal
Convenience, Efficiency

### Strategy
 * Be vim itself.
     Frankly to say, vanilla vim is already captible to do most of tasks quickly.
 * Embrace vim's flexibility.
     Custom to avoid some unpleasant default vim behaviors.
     Custom to personal taste of art.
     Extend with open plugins and embed them to personal vim habbits.
     Extend with your own scripts.
 * Use and study existing vim distributions like janus, spf13-vim, and excenlent vimrc files.
     Don't reinvent another wheel!

### Architecture
vimise <= vic => vil (vimrc <= vicrc => vilrc)

Description:
"vimise": the full vim distribution.
"vil": the light weight vim distribution. "vil" exists mainly for startup efficiency.
       Basically "vil" is just "vimise" without huge and less used plugins.
       While "vimise" should be installed(linked), "vil" is often used by making an alias
       like "alias vil vim -u /path/to/vilrc"
"vic": The common part shared by the other two. Basically "vic" is just "vicrc" which
       is incleded in "vimrc" and "vilrc".

### Inspired by
 * [pathogen](https://github.com/tpope/vim-pathogen) ( runtime manager )
 * [vundle](https://github.com/gmarik/vundle) ( plugin manager )
 * [janus](https://github.com/carlhuda/janus)(based on pathogen)
 * [spf13-vim](https://github.com/spf13/spf13-vim)(based on vundle)
 * [vimified](https://github.com/zaiste/vimified)(based on vundle)
 * [tpope's dotfiles](https://github.com/tpope/tpope)
 * [Drew Neil's dotfiles](https://github.com/nelstrom/dotfiles)
 * [skwp's dotfiles](https://github.com/skwp/dotfiles)
 * [dotvim](https://github.com/astrails/dotvim)
