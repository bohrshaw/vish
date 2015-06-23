#!/usr/bin/env bash

# Invoke like `v=vim l=1 profile.sh`
[[ -z "$v" ]] && v=nvim
[[ -z "$l" ]] && l=0
$v --startuptime startup.log --cmd "let l=$l|profile start profile.log|profile file *" -c 'profdel file *|qa!' "$@"
$v profile.log startup.log -c 'call profile#tabular()|w|bn|$'
