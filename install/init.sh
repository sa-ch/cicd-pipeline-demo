#!/bin/bash

export LOGNAME=$(oc whoami 2>/dev/null)

projectExist () {  
 oc get project $1 > /dev/null 2>&1
 echo $?
}

