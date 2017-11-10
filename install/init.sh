#!/bin/bash

projectExist () {  
 oc get project $1 > /dev/null 2>&1
 echo $?
}

LOGNAME=$(oc whoami > /dev/null 2>&1)
