"""Fcitx state toggle"""
# Original work: https://github.com/lilydjwg/fcitx.vim/blob/master/plugin/fcitx.py

import os
import glob
import vim
import socket
import struct

STATE = struct.pack('i', 0)
CLOSE  = struct.pack('i', 1)
OPEN   = struct.pack('i', 1 | (1 << 16))
INT_SIZE = struct.calcsize('i')
SOCK = vim.eval('g:_fcitx_sock')

def toggle(cmd=None):
    sock = socket.socket(socket.AF_UNIX)
    sock.settimeout(0.5)
    try:
        sock.connect(SOCK)
    except (socket.error, socket.timeout):
        vim.command('echohl WarningMsg | echo "Fcitx socket connection error" | echohl NONE')
        return
    try:
        if not cmd:
            sock.send(STATE)
            return struct.unpack('i', sock.recv(INT_SIZE))[0]
        elif cmd == 'c':
            sock.send(CLOSE)
            return 1
        elif cmd == 'o':
            sock.send(OPEN)
            return 2
        else:
            raise ValueError('Unknown fcitx command')
    except (struct.error, socket.timeout):
        vim.command('echohl WarningMsg | echo "Fcitx socket error" | echohl NONE')
        return
    finally:
        sock.close()
