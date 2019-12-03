#!/bin/sh
if [[ $# -eq 0 ]]; then
    SCRIPT_NAME=`basename "$0"`
    echo "Usage:"
    echo "./$SCRIPT_NAME <project-name-prefix> <project-name-suffix>"
    echo "  Openshift target project will be <project-name-prefix>-<project-name-suffix>"
    echo
    echo "Example usage:"
    echo "  ./$SCRIPT_NAME rhpam7-install demo"
    exit 0
fi

if [[ $# -ne 2 ]]; then
    echo "Illegal number of parameters"
    exit 1
fi

. ./init-properties.sh

command -v oc >/dev/null 2>&1 || {
  echo >&2 "The oc client tools need to be installed to connect to OpenShift.";
  echo >&2 "Download it from https://www.openshift.org/download.html and confirm that \"oc version\" runs.";
  exit 1;
}

function echo_header() {
  echo
  echo "########################################################################"
  echo $1
  echo "########################################################################"
}

PRJ_PREFIX=$1
PRJ_SUFFIX=$2
PRJ_DEMO_NAME=$(./support/openshift/provision.sh info $PRJ_PREFIX | awk '/Project name/{print $3}')

# Check if the project exists
oc get project $PRJ_DEMO_NAME > /dev/null 2>&1
PRJ_EXISTS=$?

if [ $PRJ_EXISTS -eq 0 ]; then
   echo_header "$PRJ_DEMO_NAME project already exists. Deleting project."
   ./support/openshift/provision.sh delete $PRJ_PREFIX
   # Wait until the project has been removed
   echo_header "Waiting for OpenShift to clean deleted project."
   sleep 20
else if [ ! $PRJ_EXISTS -eq 1 ]; then
	echo "An error occurred communicating with your OpenShift instance."
	echo "Please make sure that your logged in to your OpenShift instance with your 'oc' client."
  exit 1
  fi
fi

echo_header "Provisioning $PRJ_DEMO_NAME."
./support/openshift/provision.sh setup $PRJ_PREFIX --with-imagestreams --project-suffix $PRJ_SUFFIX
echo_header "Setup completed."
