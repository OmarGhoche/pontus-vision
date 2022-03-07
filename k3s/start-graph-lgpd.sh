#!/bin/bash
DIR="$( cd "$(dirname "$0")" ; pwd -P )"
cd $DIR

./create-env-secrets.sh
if [[ -z ${PV_HOSTNAME} ]]; then
  export PV_HOSTNAME=$(hostname)
fi
if [[ -z ${PV_STORAGE_BASE} ]]; then
  export PV_STORAGE_BASE=${DIR}/storage
fi
if [[ $0 =~ lgpd ]]; then 
  export PV_IMAGE_SUFFIX=-pt
  export PV_MODE=lgpd
else
  export PV_IMAGE_SUFFIX=
  export PV_MODE=gdpr
endif


export PV_HELM_FILE=./helm/values-resolved.yaml
envsubst ./helm/custom-values.yaml > $PV_HELM_FILE

./create-storage-dirs.sh

helm template -s templates/graphdb.yaml -f ./helm/values-lgpd-resolved.yaml pv ./helm/pv | k3s kubectl apply -f -
