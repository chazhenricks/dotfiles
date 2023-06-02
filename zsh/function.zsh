
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

mex() {
  chmod +x $1 
}

mcd() {
  mkdir $1 && cd $_
}


function init_built_tools() {
    colima start
    cd $HOME/BuiltSource/developer-environment
    awslogin aws-developer
    mv $HOME/.aws/aws-developer $HOME/.aws/credentials
    pipenv run built_up -p minimal
}

function prod_extract_loan() {
    cd $HOME/BuiltSource/case_sensitive/built-tools
    ./bin/built extract loan $1 -o "$1.sql"
    mv $HOME/.built/cache/$1.sql $HOME/BuiltSource/prod-extracts/$1.sql
}

function prod_extract_lender() {
    cd $HOME/BuiltSource/case_sensitive/built-tools
    ./bin/built extract lender $1 -o "$1.sql"
    mv $HOME/.built/cache/$1.sql $HOME/BuiltSource/prod-extracts/$1.sql
}

function prod_extract_user() {
    cd $HOME/BuiltSource/case_sensitive/built-tools
    ./bin/built extract user $1 -o "$1.sql"
    mv $HOME/.built/cache/$1.sql $HOME/BuiltSource/prod-extracts/$1.sql
}

load_extract() {
    mysql -u root -h 127.0.0.1 --port 13306 -p local_built_api < ./$1.sql
}
# ############
# C9 Functions
# ############



