
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
# start kubernetes dev environment 
k8s_up(){
    assume
    kubectl --namespace $(whoami | sed 's/\./-/g') scale deployments -l "app.kubernetes.io/managed-by=Helm" --replicas=1
    cd $HOME/BuiltSource/kubernetes-developer-environment/single-stack/
    make dms.start
    cd -
}

# destroy a pod 
k8s_destroy() {
helmfile destroy -l name=$1
}

# apply a pod
k8s_apply(){
helmfile apply -l name=$1
}

k8s_managed(){
  kubectl get managed | grep 'chaz-henricks'
}

k8s_mysql_password(){
  kubectl get secret --namespace $(whoami | sed 's/\./-/g') mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo
}

k8s_endpoints(){
  kubectl describe ingress --namespace $(whoami | sed 's/\./-/g') | grep -i host -A3
}
function kick_pod() {
    set -e -o pipefail

    LABEL=$1
    LABEL_KEY=${2:-app.kubernetes.io/name}

    usage() {
        echo "Usage: $0 <label> [label-key]"
        echo "  label: the value of the label to delete"
        echo "  label-key: the label key to delete (default: app.kubernetes.io/name)"
    }

    if [[ -z $LABEL ]]; then
        >&2 echo "You must provide a label to delete"
        usage;
        exit 1;
    fi

    POD=$(kubectl get pods -l app.kubernetes.io/name=$LABEL -o name)
    if [[ -z $POD ]]; then
        >&2 echo "No pod found with label key: $LABEL_KEY=$LABEL"

        # get all pods' label values with label key
        AVAILABLE_LABELS=$(kubectl get pods -o json | jq -r ".items[].metadata.labels[\"$LABEL_KEY\"]" | sort -u)
        if [[ -z $AVAILABLE_LABELS ]]; then
            >&2 echo "No labels found with label key: $LABEL_KEY"
        else
            echo "Available pod labels with label key: $LABEL_KEY"
            PREFIX="  + "
            while IFS= read -r label; do
                echo "${PREFIX}${label}"
            done <<< "$AVAILABLE_LABELS"
        fi
        exit 0;
    fi

    echo "Deleting pod with label: $LABEL_KEY=$LABEL ..."
    kubectl delete $POD
    exit 0;
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



