#!/bin/bash

./init.sh

oc new-project ${LOGNAME}-jenkins --display-name "Shared Jenkins"
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi

# TODO: adapt slave pod config to have 2Gi mem
