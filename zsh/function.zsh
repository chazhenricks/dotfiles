
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


