# Plugins
plugins=(git nvm)


############
# Homebrew # 
############
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH

##############
# oh-my-zsh #
##############
export ZSH="$HOME/.oh-my-zsh"


##########
# python #
##########
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYTHON_CONFIGURE_OPTS="--with-openssl=$(brew --prefix openssl)"
export CFLAGS="-I$(brew --prefix zlib)/include -I$(brew --prefix sqlite)/include -I$(brew --prefix bzip2)/include"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

###########
# CD Path #
###########
setopt auto_cd
cdpath=($HOME/Documents/BuiltSource $HOME/Documents/chaz $HOME/Documents)


# General ZSH Settings

ZSH_THEME="spaceship"
HYPHEN_INSENSITIVE="true"

source $ZSH/oh-my-zsh.sh

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
