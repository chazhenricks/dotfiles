# Plugins
plugins=(git nvm)


############
# Homebrew # 
############
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH=$HOME/bin:/opt/homebrew/bin:/usr/local/bin:$PATH


# Add .local/bin to path so we can execute custom scripts
export PATH=$PATH:$HOME/.local/bin 

# sets the defailt editor to be neovim 
export EDITOR=nvim

# set the term if in tmux
export TERM=xterm-256color
if [[ -n "$TMUX" ]]; then
  export TERM=tmux-256color
fi

# set the Mason directory in the path so we can use LSPs in the terminal if need be 
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"




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
export CFLAGS="-I$(brew --prefix zlib)/include -I$(brew --prefix sqlite)/include -I$(brew --prefix bzip2)/include -I$(brew --prefix libffi)/include"
export LDFLAGS="-L$(brew --prefix zlib)/lib -L$(brew --prefix bzip2)/lib -L/opt/homebrew/opt/llvm/lib -L$(brew --prefix libffi)/lib"
export CPPFLAGS="-I$(brew --prefix zlib)/include -I$(brew --prefix bzip2)/include -I/opt/homebrew/opt/llvm/include"
export PKG_CONFIG_PATH="$(brew --prefix libffi)/lib/pkgconfig:/opt/homebrew/opt/llvm/lib/pkgconfig:$PKG_CONFIG_PATH "



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
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/bzip2/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@5.7/bin:$PATH"



# ####################
# Glow Markdown Viewer
# ####################
export GLAMOUR_STYLE='../glow-style.json'


# #########
# pomodoro 
# #########
