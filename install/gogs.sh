#!/bin/bash

. ./init.sh

if [ "${LOGNAME}" == "" ]; then
  echo "du dubeli, sätsch ilogge"
  exit
fi

if [ $(projectExist ${LOGNAME}-cicd-pipeline-demo-gogs) != 1 ]; then
  echo "project for gogs already exists - skipping setup"
  exit
fi

oc new-project ${LOGNAME}-cicd-pipeline-demo-gogs --display-name "Shared Gogs"
oc new-app postgresql-persistent --param POSTGRESQL_DATABASE=gogs --param POSTGRESQL_USER=gogs --param POSTGRESQL_PASSWORD=gogs --param VOLUME_CAPACITY=4Gi -lapp=postgresql_gogs

oc rollout pause dc postgresql
oc patch pvc postgresql -p "metadata:
  name: postgresql
  annotations:
    volume.beta.kubernetes.io/storage-class: gluster-container"
oc rollout resume dc postgresql

oc new-app wkulhanek/gogs:11.4 -lapp=gogs

echo "apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gogs-data
  annotations:
    volume.beta.kubernetes.io/storage-class: gluster-container  
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi" | oc create -f -

oc set volume dc/gogs --add --overwrite --name=gogs-volume-1 --mount-path=/data/ --type persistentVolumeClaim --claim-name=gogs-data

# patch values in app.ini
cp config/app.ini.template config/app.ini
gogsroute=$(oc get route gogs --template='{{ .spec.host }}')
sed "s+^\(ROOT_URL.*=\) *.*$+\1 $gogsroute+g" app.ini

oc create configmap gogs --from-file=config/app.ini
oc set volume dc/gogs --add --overwrite --name=config-volume -m /opt/gogs/custom/conf/ -t configmap --configmap-name=gogs

rm config/app.ini

oc expose svc gogs
