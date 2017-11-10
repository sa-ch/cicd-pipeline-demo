#!/bin/bash

./init.sh

if [ $(projectExist ${LOGNAME}-cicd-pipeline-demo-nexus) == 1 ]; then
  echo "project for nexus already exists - skipping setup"
  exit
fi

oc new-project ${LOGNAME}-cicd-pipeline-demo-nexus --display-name "Shared Nexus"
oc new-app sonatype/nexus3:latest
oc expose svc nexus3
oc rollout pause dc nexus3

oc patch dc nexus3 --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set resources dc nexus3 --limits=memory=2Gi --requests=memory=1Gi

echo "apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nexus-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi" | oc create -f -

oc set volume dc/nexus3 --add --overwrite --name=nexus3-volume-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc

oc set probe dc/nexus3 --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/nexus3 --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/repository/maven-public/
oc rollout resume dc nexus3

# init default repositories
# default user admin/admin123
# script src: https://raw.githubusercontent.com/wkulhanek/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
./init_nexus3.sh admin admin123 http://$(oc get route nexus3 --template='{{ .spec.host }}')
