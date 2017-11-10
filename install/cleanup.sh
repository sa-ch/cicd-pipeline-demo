#!/bin/bash

. ./init.sh

if [ "${LOGNMAME}" == "" ]; then
  echo "du dubeli, sätsch ilogge"; exit
fi

for prj in ${LOGNAME}-cicd-pipeline-demo-jenkins \
           ${LOGNAME}-cicd-pipeline-demo-nexus \
           ${LOGNAME}-cicd-pipeline-demo-gogs \
           ${LOGNAME}-cicd-pipeline-demo-sonarcube; do

  if [ $(projectExist ${prj}) == 1 ]; then
    echo "deleting project ${prj}"
    oc delete project ${prj}
  fi

done

