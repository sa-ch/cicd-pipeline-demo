#!/bin/bash

./init.sh

if [ $(projectExist ${LOGNAME}-cicd-pipeline-demo-jenkins) == 1 ]; then
  echo "project for jenkins already exists - skipping setup"
  exit
fi

oc new-project ${LOGNAME}-cicd-pipeline-demo-jenkins --display-name "Shared Jenkins"
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi

# TODO: adapt slave pod config to have 2Gi mem
