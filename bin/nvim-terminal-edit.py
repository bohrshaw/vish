#!/usr/bin/env python3

# https://github.com/mhinz/neovim-remote/blob/master/bin/nvr
# https://gist.github.com/tarruda/37f7a3e22996addf8921
# http://www.reddit.com/r/neovim/comments/30kvl3/ive_been_using_the_experimental_terminal_mode_and/

"""Edit a file in the host nvim instance."""
import os
import sys
from neovim import attach

args = sys.argv[1:]
if not args:
    print("Usage: {} <filename> ...".format(sys.argv[0]))
    sys.exit(1)

addr = os.environ.get("NVIM_LISTEN_ADDRESS", None)
if not addr:
    os.execvp('nvim', args)
nvim = attach("socket", path=addr)

nvim.input('<c-\\><c-n>')  # exit terminal mode
nvim.command('exe "drop {}"'.format(' '.join(
    [os.path.abspath(f).replace(' ', '\\\\ ') for f in args])))
