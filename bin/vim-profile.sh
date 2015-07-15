#!/usr/bin/env bash
#
# Check Vim start-up performance
# Related options: 'verbose' and 'verbosefile', or -V

# Invoke like `v=vim l=1 profile.sh --cmd 'let h=1' t.rb`
[[ -z "$v" ]] && v=nvim
[[ -z "$l" ]] && l=0
$v --startuptime startup.log \
  --cmd "let l = $l | profile start profile.log | profile file *" \
  -c 'profdel file * | qall!' "$@"
$v profile.log startup.log \
  -c 'call profile#tabular() | write | bnext | $'