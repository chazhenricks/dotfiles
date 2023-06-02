# ##########
# Aliases
# ##########

alias testsingle="npm test -- -t"
alias config='/usr/bin/git --git-dir=/Users/chaz.henricks/.cfg/ --work-tree=/Users/chaz.henricks'

alias c9="ssh cloud9"

alias szsh="source $HOME/.zshrc"
alias path="echo $PATH | tr ':' '\n'"
alias notes="cd $HOME/Documents/chaz/notes && nvim . "
alias dot="nvim $HOME/dotfiles" 



# Docker 
alias docs="docker ps --format "table {{.Names}}\t{{.Command}}\t{{.Status}}""
