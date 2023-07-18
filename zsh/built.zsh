##################
# Built Specific #
##################


###########
# aliases #
###########
alias c9="ssh cloud9"


# AWS RDS credentials
alias prod_db='awslogin -db=prod-cla-soa-us-east-1 prod-support'
alias demo_db='awslogin -db=demo-cla-soa-us-east-1 prod-support'
alias prod_bapi_db='awslogin -db=prod-cla-bapi-replica-us-east-1 prod-support'
alias ops_bapi_db='awslogin -db=ops-cla-bapi-us-east-1 aws-developer'
alias ops_db='awslogin -db=ops-cla-soa-us-east-1 aws-developer'
alias dev_db='awslogin -db=dev-cla-soa-us-east-1 aws-developer'
alias staging_db='awslogin -db=staging-cla-soa-us-east-1 aws-developer'
alias staging_bapi_db='awslogin -db=staging-cla-bapi-us-east-1 aws-developer'


# AWS RDS MySQL Login
alias prod_login='awslogin -db-login=prod-cla-soa-us-east-1 prod-support'
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



################
# c9 functions #
################
reset_current  () {
        reset ${PWD##*/}
 }

reset () {
        built_service_reset $1
}

reset_db () {
        built_service_reset --include-db $1
}

seed () {
         mysql -u root -h 127.0.0.1 --port 13306 -p local_built_api < $1
 }

 dump(){
  mysql -u root -h 127.0.0.1 --port 13306 -p local_built_api < ./$1.sql
 }

 logs_current () {
        logs ${PWD##*/}
 }

 logs () {
        docker logs -f $1
 }

  ecr_login() {
 aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 833816692833.dkr.ecr.us-east-1.amazonaws.com
}

reset_inspections(){
        built_up --clean -p inspections
        built_service_reset geolocations-service

}


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
