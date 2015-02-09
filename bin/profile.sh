vim --startuptime startup.log --cmd 'profile start profile.log |profile file *' -c 'profdel file * |qa!'
vim profile.log startup.log -c 'call profile#tabular() |w'
