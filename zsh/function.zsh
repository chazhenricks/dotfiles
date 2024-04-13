
# ##########
# Functions 
# ##########

sz () {
  source ~/.zshrc
  config add ~/.zshrc 
  config commit -m "update zshrc"
}

export_envs () {
  export $(grep -v '^#' .env.local | xargs)
}

wm() {
  # check if the working memory directory exists 
  if [[ ! -d "$HOME/Documents/chaz/working-memory" ]]; then
    mkdir $HOME/Documents/chaz/working-memory
  fi 
  
  cd $HOME/Documents/chaz/working-memory 
  tat
  nvim working-memory.md 
} 


ecr_login() {
 aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 833816692833.dkr.ecr.us-east-1.amazonaws.com
}

mex() {
  chmod +x $1 
}

mcd() {
  mkdir $1 && cd $_
}

# open tmux not in a session and open ito choose-tree
tst() {
  tmux attach\; choose-tree -swZ
}


replace_origin() {
  git reset --hard origin/$1
}

