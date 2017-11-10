#!/bin/bash

export LOGNAME=$(oc whoami > /dev/null 2>&1)

projectExist () {  
 oc get project $1 > /dev/null 2>&1
 echo $?
}

