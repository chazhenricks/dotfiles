##################
# Built Specific #
##################


##############
# kubernetes #
##############

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export K8S_TEAM_NAME="built-chain"
export K8S_SHARED_STACK="built-chain"
export K8S_NAMESPACE_OVERRIDE="chahen"
export NS=$(whoami | awk -F. '{print substr($1, 1, 3) substr($2, 1, 3)}')
export NAMESPACE="chahen"
export K8S_NAMESPACE="chahen"
export GRANTED_NO_KEYRING=true
export K9S_SKIN="everforest-dark"


# start kubernetes dev environment 
k8s_yesterday(){
    assume
    AWS_PROFILE=built_dev_eks/BuiltAdmin aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 833816692833.dkr.ecr.us-east-1.amazonaws.com
    make start_day
}

k8s_new(){
    assume
    AWS_PROFILE=built_dev_eks/BuiltAdmin aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 833816692833.dkr.ecr.us-east-1.amazonaws.com
    # cd $HOME/BuiltSource/kubernetes-developer-environment/single-stack/ 
    # git checkout main 
    # git pull && say 'git pull succeeded' || say 'FUCK! git pull failed' 
    @kubectl --namespace $NAMESPACE scale deployments -l "app.kubernetes.io/managed-by=Helm" --replicas=1 2>/dev/null || true
    @kubectl --namespace $NAMESPACE scale deployments -l type=flink-native-kubernetes --replicas=1 2>/dev/null || true
    helmfile deps && say 'helmfile deps succeeded' || say 'FUCK! helmfile deps failed'  
    helmfile apply && say 'helmfile apply succeeded' || reapply
    make frontend-sync profile=built_dev_eks/BuiltAdmin && say 'frontend sync complete' || say 'oh my god, frontend sync failed'
  }


k8s_fe(){
  if [ -n "$1" ]; then 
    echo "running: make frontend-upload profile=built_dev_eks/BuiltAdmin repo=$1 static_files_path=/Users/chaz.henricks/BuiltSource/$1/dist"
    make frontend-upload profile=built_dev_eks/BuiltAdmin repo=$1 static_files_path=/Users/chaz.henricks/BuiltSource/$1/dist
  else 
    echo "running: make frontend-sync profile=built_dev_eks/BuiltAdmin"
    make frontend-sync profile=built_dev_eks/BuiltAdmin 
  fi
}

reapply(){
  helmfile apply && say 'shit yeah helmfile apply succeded' || say 'fuck helmfile apply failed'
}

reload_auth(){
  cd ~/BuiltSource/kubernetes-developer-environment/single-stack/
  make auth-init ROOT_PATH=~/BuiltSource/
  make auth-load
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
  kubectl get managed | grep 'chahen'
}

k8s_mysql_password(){
kubectl get secret mysql-creds --namespace $(kubectl config view --minify --output 'jsonpath={..namespace}') -o yaml | yq .data.MYSQL_PASSWORD | base64 -d
}

k8s_endpoints(){
  kubectl describe ingress --namespace chahen | grep -i host -A3
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





# New Awslogin format 
# THIS REFRESH COMMAND DOESNT WORK VERY WELL. 
# alias refresh_db_creds='granted sso generate --sso-region us-east-1 --source aws-sso https://d-9067662d10.awsapps.com/start/\# > ~/.aws/config'

alias dev_bapi='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db dev-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess'
alias dev_soa='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db dev-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'

# OPS
alias ops_bapi='granted sso login --sso-start-url https://d-9067662d10.awsapps.com/start/# --sso-region us-east-1 && AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db ops-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess | copy_password'
alias ops_soa='granted sso login --sso-start-url https://d-9067662d10.awsapps.com/start/# --sso-region us-east-1 && AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db ops-cla-soa8-us-east-1 --dbuser SamlDbReadAccess | copy_password'

# STAGING 
alias staging_assume='assume AWS_PROFILE=Built-Dev/BuiltDeveloper'
alias staging_bapi='staging_assume && AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db staging-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess'
alias staging_soa='staging_assume && AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db staging-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'

#PROD
alias prod_bapi='AWS_PROFILE=Built-Root/ProdReadOnly aws sso login && AWS_PROFILE=Built-Root/ProdReadOnly awslogin mysql-login --db prod-cla-bapi8-replica-us-east-1 --dbuser SamlDbReadAccess | copy_password'
alias prod_soa='AWS_PROFILE=Built-Root/ProdReadOnly aws sso login  && AWS_PROFILE=Built-Root/ProdReadOnly awslogin mysql-login --db prod-cla-soa8-us-east-1 --dbuser SamlDbReadAccess | copy_password'
alias prod_soa_write='AWS_PROFILE=ProdReadWrite aws sso login  && AWS_PROFILE=ProdReadWrite awslogin mysql-login --db prod-cla-soa8-us-east-1 --dbuser SamlDbReadWriteAccess | copy_password'

#Demo
alias demo_bapi='assume Built-Root/BuiltSupport_067182029689 && awslogin mysql-login --db demo-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess | copy_password'
alias demo_soa='assume Built-Root/BuiltSupport_067182029689 && awslogin mysql-login --db demo-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'

# PMU
alias pmu_bapi='AWS_PROFILE=built_uat/BuiltDeveloperReadOnly awslogin mysql-login --db pmu-cla-bapi8-us-east-2 --dbuser SamlDbReadAccess | copy_password'
alias pmu_soa='AWS_PROFILE=built_uat/BuiltDeveloperReadOnly awslogin mysql-login --db pmu-cla-soa8-us-east-2 --dbuser SamlDbReadAccess | copy_password'




# AWS RDS MySQL Login
alias prod_login='awslogin -db-login=prod-cla-soa-us-east-1 prod-support'
alias prod8_login='awslogin -db-login=prod-cla-soa-us-east-1 prod-support'
alias ops_login='awslogin -db-login=ops-cla-soa-us-east-1 aws-developer'
alias dev_login='awslogin -db-login=dev-cla-soa-us-east-1 aws-developer'


#############
# functions #
#############

# daily aws login helper
dev () {
	awslogin aws-developer
	cp ~/.aws/aws-developer ~/.aws/credentials
}

prod_aws () {
	awslogin aws-developer
	cp ~/.aws/aws-developer ~/.aws/credentials
}


# run php unit tests  
phpDebugFile(){
    vendor/bin/phpunit ./tests/$1 -c ./tests/api --no-coverage $2
}

# AWS RDS MySQL Dumps
function dump_ops () {
    database=$1
    password=$2
    mysqldump $database \
     --result-file=/Users/alex.martin/BuiltSource/dump.sql \
     --host=ops-cla-soa-us-east-1.ce8wli86taiy.us-east-1.rds.amazonaws.com \
     --port=3306 \
     --ssl-ca=/var/folders/pw/p76xjcn926v2hfbs4sry3b700000gr/T//rds-combined-ca-bundle.pem \
     --enable-cleartext-plugin \
     --user=SamlDbReadAccess \
     --password=$password \
     --skip-add-locks \
     --skip-lock-tables \
     --column-statistics=0
}


####################
# Cloud 9 Specific #
####################

#############
# c9 alises #
#############

alias vars="built_c9_vars"
alias ra="built_service_reset apache"
alias bcpi="built_up --clean -p inspections"
alias db='mysql --host=127.0.0.1 --port=13306 --user=root --password=Trousdale1!'
alias rib="docker system prune && sudo service docker restart && pip install --upgrade -i https://infrastructure.getbuilt.com/nexus/repository/pypi/simple built-developer-environment && built_up --clean -p inspections"
alias docs="docker ps --format 'table {{.Names}}\t{{.Command}}\t{{.Status}}'"
alias ripa="built_service_reset inspections-product-api"
alias ris="built_service_reset inspections-service"
alias risd="built_service_reset --include-db inspections-service"



## inspections api spec ---

# Reset ownership of apispec of inPAPI
ownership-inspections() {
  sudo chown -R 501:1000 $(make -s get_ownership_files)
  sudo chmod -R 777 $(make -s get_ownership_files)
}
refresh-main() {
  local main_path="./src/main.ts"
  local temp="$(cat $main_path)"
  echo $temp > $main_path
}
ownership-inPapi() {
  if [[ $PWD = *"inspections-product-api" ]]; then
    ownership-inspections
    echo "update inPAPI permissions"
    refresh-main
    echo "refreshed inPAPI"
  fi
}
## end inspections api spec ---



############
# php shit #
############

BUILT_API_PATH="~/BuiltSource/case_sensitive/built-api"
phpDebugFile(){
    cd $BUILT_API_PATH/public
    docker exec -t built-api vendor/bin/phpunit ./tests/$1 -c ./tests/api --no-coverage $2
}






###############
# Inspections #
###############

alias rr="~/BuiltSource/inspections-product-api/Makefiles/scripts/rerunner.sh"
