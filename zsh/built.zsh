##################
# Built Specific #
##################


##############
# kubernetes #
##############

# start kubernetes dev environment 
k8s_yesterday(){
    assume
    cd $HOME/BuiltSource/kubernetes-developer-environment/single-stack/ 
    make start_day
    cd -
}

k8s_new(){
    assume
    cd $HOME/BuiltSource/kubernetes-developer-environment/single-stack/ 
    make update_stack 
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




# AWS RDS credentials
# alias prod_db='awslogin -db=prod-cla-soa-us-east-1 prod-support'
# alias prod8_db='awslogin -db=prod-cla-soa8-us-east-1 prod-support'
# alias demo_db='awslogin -db=demo-cla-soa-us-east-1 prod-support'
# alias demo8_db='awslogin -db=demo-cla-soa8-us-east-1 prod-support'
# alias prod_bapi_db='awslogin -db=prod-cla-bapi-replica-us-east-1 prod-support'
# alias prod_bapi8_db='awslogin -db=prod-cla-bapi8-replica-us-east-1 prod-support'
# alias ops_bapi_db='awslogin -db=ops-cla-bapi-us-east-1 aws-developer'
# alias ops_bapi8_db='awslogin -db=ops-cla-bapi8-us-east-1 aws-developer'
# alias ops_db='awslogin -db=ops-cla-soa-us-east-1 aws-developer'
# alias ops8_db='awslogin -db=ops-cla-soa8-us-east-1 aws-developer'
# alias dev_db='awslogin -db=dev-cla-soa-us-east-1 aws-developer'
# alias dev8_db='awslogin -db=dev-cla-soa8-us-east-1 aws-developer'
# alias staging_db='awslogin -db=staging-cla-soa-us-east-1 aws-developer'
# alias staging8_db='awslogin -db=staging-cla-soa8-us-east-1 aws-developer'
# alias staging_bapi_db='awslogin -db=staging-cla-bapi-us-east-1 aws-developer'
# alias staging_bapi8_db='awslogin -db=staging-cla-bapi8-us-east-1 aws-developer'


# New Awslogin format 
# Dev
alias dev_bapi='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db dev-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess'
alias dev_soa='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db dev-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'
# OPS
alias ops_bapi='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db ops-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess'
alias ops_soa='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db ops-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'
# STAGING 
alias staging_bapi='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db staging-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess'
alias staging_soa='AWS_PROFILE=Built-Dev/BuiltDeveloper awslogin mysql-login --db staging-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'
#PROD
alias prod_assume='assume Built-Root/BuiltSupport_067182029689'
alias prod_bapi='prod_assume && AWS_PROFILE=Built-Root/BuiltSupport_067182029689 awslogin mysql-login --db prod-cla-bapi8-replica-us-east-1 --dbuser SamlDbReadAccess'


alias prod_soa='prod_assume && AWS_PROFILE=Built-Root/BuiltSupport_067182029689 awslogin mysql-login --db prod-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'

#Demo
alias demo_bapi='assume Built-Root/BuiltSupport_067182029689 && awslogin mysql-login --db demo-cla-bapi8-us-east-1 --dbuser SamlDbReadAccess'
alias demo_soa='assume Built-Root/BuiltSupport_067182029689 && awslogin mysql-login --db demo-cla-soa8-us-east-1 --dbuser SamlDbReadAccess'




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
