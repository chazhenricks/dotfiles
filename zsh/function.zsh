
# ##########
# Functions 
# ##########
pull_notes(){
  cd ~/Documents/obsidian-notes
  git checkout main
  git pull origin main
  cd -
}
push_notes(){
  cd ~/Documents/obsidian-notes
  git add . 
  git commit -m "sync notes" 
  git push origin main
  cd -
}


sz () {
  source ~/.zshrc
  config add ~/.zshrc 
  config commit -m "update zshrc"
}

# source all panes in a tmux session
tzsh() {
  tmux list-panes -s -F '#{pane_id}' | xargs -I {} tmux send-keys -t {} 'source ~/.zshrc' Enter
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


k8s_auth(){
  make k8s.search_v2.reindex.auth_tenants
  make k8s.search_v2.reindex.auth_roles
  make k8s.search_v2.reindex.auth_groups
  make k8s.search_v2.reindex.auth_users
}


dev_k9s(){
  kubectl config use-context arn:aws:eks:us-east-1:833816692833:cluster/dev
}

chaz_k9s(){
  kubectl config use-context workstation 
}

copy_password(){

  output=$(cat)

  password=$(echo "$output" | grep "Password:" | awk -F ' ' '{print $2}')

  if command -v pbcopy &> /dev/null; then
      echo -n "$password" | pbcopy
      echo "Password copied to clipboard!"
  else
      echo "Clipboard command not found. Install pbcopy."
      exit 1
  fi
}
