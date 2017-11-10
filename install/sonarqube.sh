#!/bin/bash

. ./init.sh

if [ "${LOGNMAME}" != "" ]; then
  echo "du dubeli, sätsch ilogge"
fi

if [ $(projectExist ${LOGNAME}-cicd-pipeline-demo-sonarqube) == 1 ]; then
  echo "project for sonarqube already exists - skipping setup"
  exit
fi

oc new-project ${LOGNAME}-cicd-pipeline-demo-sonarqube --display-name "Shared Sonarqube"
oc new-app postgresql-persistent --param POSTGRESQL_USER=sonar --param POSTGRESQL_PASSWORD=sonar --param POSTGRESQL_DATABASE=sonar --param VOLUME_CAPACITY=4Gi -lapp=sonarqube_db

# img src: https://github.com/wkulhanek/docker-openshift-sonarqube.git
# default: admin/admin
oc new-app wkulhanek/sonarqube:6.5 -e SONARQUBE_JDBC_USERNAME=sonar -e SONARQUBE_JDBC_PASSWORD=sonar -e SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar -lapp=sonarqube
oc expose service sonarqube --port=9000
oc rollout pause dc sonarqube

echo "apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sonarqube-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi" | oc create -f -
oc set volume dc/sonarqube --add --overwrite --name=sonarqube-volume-1 --mount-path=/opt/sonarqube/data/ --type persistentVolumeClaim --claim-name=sonarqube-pvc

oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok
oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about
oc set resources dc/sonarqube --limits=memory=2Gi --requests=memory=1Gi
oc rollout resume dc sonarqube
