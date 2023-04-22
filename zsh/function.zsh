
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


ecr_login() {
 aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 833816692833.dkr.ecr.us-east-1.amazonaws.com
}

# ############
# C9 Functions
# ############



