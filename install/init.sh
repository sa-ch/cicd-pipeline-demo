#!/bin/bash

LOGNAME=$(oc whoami)

#oc new-project ${LOGNAME}-cicd-pipeline-demo-nexus

projectExist () {  
 oc get project $1 > /dev/null 2>&1
 echo $?
}

if [ $(projectExist ${LOGNAME}-cicd-pipeline-demo-nexus) == 1 ]; then 
  oc new-project ${LOGNAME}-cicd-pipeline-demo-nexus
else
  echo gugu
fi

