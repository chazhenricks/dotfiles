# Plugins
plugins=(git nvm)


############
# Homebrew # 
############
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH


# Add .local/bin to path so we can execute custom scripts
export PATH=$PATH:$HOME/.local/bin 

##############
# oh-my-zsh #
##############
export ZSH="$HOME/.oh-my-zsh"

 # lolz 
 export HOMER="doh"

##########
# python #
##########
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYTHON_CONFIGURE_OPTS="--with-openssl=$(brew --prefix openssl)"
export CFLAGS="-I$(brew --prefix zlib)/include -I$(brew --prefix sqlite)/include -I$(brew --prefix bzip2)/include"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib -L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include -I/opt/homebrew/opt/llvm/include"



############
# go shit # 
# #########
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

###########
# CD Path #
###########
setopt auto_cd
cdpath=($HOME/BuiltSource $HOME/Documents/chaz $HOME/Documents $HOME)


# General ZSH Settings
HYPHEN_INSENSITIVE="true"



# Setup Spaceship
# idk why but this is big mad on my work computer - opting to use the oh-my-zsh theme instead.
ZSH_THEME="miloshadzic"


# Startup oh-my-zsh
source $ZSH/oh-my-zsh.sh

# source "/opt/homebrew/opt/spaceship/spaceship.zsh"
# ##########
# THE FUCK!?
# ##########
eval $(thefuck --alias)


# ########
# NODE SHIT
# ########

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/bzip2/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@5.7/bin:$PATH"



# ##############
# misc k8s stuff 
# ##############
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export K8s_TEAM_NAME=marketplace
