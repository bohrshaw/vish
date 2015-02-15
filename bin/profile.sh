# Invoke like `profile.sh --cmd \'let h=1\'
eval "vim --startuptime startup.log --cmd 'profile start profile.log |profile file *' -c 'profdel file * |qa!' $*"
vim profile.log startup.log -c 'call profile#tabular() |w'
