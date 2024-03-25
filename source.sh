#!/usr/bin/env bash
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function diffJson() {
  "${SCRIPT_DIR}"/js/diffJson.js "$@"
}

function toLocalDate() {
  "${SCRIPT_DIR}"/js/toLocalDate.js "$@"
}

function toUtcDate() {
  "${SCRIPT_DIR}"/js/toUtcDate.js "$@"
}

function hsi () {
    history | grep -i "$@"
}

function k8sNamespace () {
  kubectl config set-context --current --namespace=${1}
}

function k8sEksCluster() {
  kubectl config use-context "$(aws eks describe-cluster --output json --name "$(aws eks --output json list-clusters | jq -r '.clusters[0]')" | jq -r '.cluster.arn')"
}

function k8sAllResources() {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
      if [ -z "${1}" ]
      then
        OUTPUT="$(kubectl get --ignore-not-found "${i}")"
      else
        OUTPUT="$(kubectl get -n "${1}" --ignore-not-found "${i}")"
      fi

      if [ -n "${OUTPUT}" ]; then
        echo "Resource: ${i}"
        # shellcheck disable=SC2086
        echo ${OUTPUT}
        printf "\n"
      fi
    done
}

source "${SCRIPT_DIR}/bash/csvTojson.sh"
source "${SCRIPT_DIR}/bash/jsonToCsv.sh"
source "${SCRIPT_DIR}/bash/xmlToJson.sh"

source "${SCRIPT_DIR}/bash/build.sh"
source "${SCRIPT_DIR}/bash/test.sh"
source "${SCRIPT_DIR}/bash/run.sh"

source "${SCRIPT_DIR}/bash/diffDirs.sh"
source "${SCRIPT_DIR}/bash/diffSync.sh"

source "${SCRIPT_DIR}/bash/dumpDb.sh"
source "${SCRIPT_DIR}/bash/restoreDb.sh"

source "${SCRIPT_DIR}/bash/nextSemanticVersion.sh"