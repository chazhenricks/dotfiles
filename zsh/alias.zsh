# ##########
# Aliases
# ##########

alias testsingle="npm test -- -t"
alias config='/usr/bin/git --git-dir=/Users/chaz.henricks/.cfg/ --work-tree=/Users/chaz.henricks'

alias c9="ssh cloud9"

alias szsh="source $HOME/.zshrc"



# AWS RDS credentials
alias prod_db='awslogin -db=prod-cla-soa-us-east-1 prod-support'
alias ops_bapi_db='awslogin -db=ops-cla-bapi-us-east-1 aws-developer'
alias ops_db='awslogin -db=ops-cla-soa-us-east-1 aws-developer'
alias dev_db='awslogin -db=dev-cla-soa-us-east-1 aws-developer'
alias staging_db='awslogin -db=staging-cla-soa-us-east-1 aws-developer'
alias staging_bapi_db='awslogin -db=staging-cla-bapi-us-east-1 aws-developer'

# AWS RDS MySQL Login
alias prod_login='awslogin -db-login=prod-cla-soa-us-east-1 prod-support'
alias ops_login='awslogin -db-login=ops-cla-soa-us-east-1 aws-developer'
alias dev_login='awslogin -db-login=dev-cla-soa-us-east-1 aws-developer'
alias staging_login='awslogin -db-login=staging-cla-soa-us-east-1 aws-developer'


# Docker 
alias docs="docker ps --format "table {{.Names}}\t{{.Command}}\t{{.Status}}""
