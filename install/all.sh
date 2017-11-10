#!/bin/bash

. ./init.sh

if [ "${LOGNAME}" == "" ]; then
  echo "du dubeli, sätsch ilogge"
  exit
fi

./nexus.sh
./jenkins.sh
./sonarqube.sh
./gogs.sh