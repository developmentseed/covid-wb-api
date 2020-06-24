#!/bin/bash

# automatically export all variables
set -a
source .env
set +a

aws cloudformation deploy --template-file cloudformation.yaml --stack-name \
$STACK_NAME --tags Project=$PROJECT --parameter-overrides \
DBUser=$DBUser DBPassword=$DBPassword \
DBName=$DBName DBUser=$DBUser DBPassword=$DBPassword \
DesiredCount=$DesiredCount \
ApiImage=$ApiImage Version=$Version \
--region $REGION --capabilities CAPABILITY_IAM \