#!/bin/bash
# This script is to deploy one mesh(mesh1) including 3 clusters with seperate networks,
# within the mesh DNS proxying is enabled
# primary cluster is marked as cluster1 acts as the local primary.
# sremote cluster shares the istio control plane with primary, works as cluster2.
# xremote cluster called cluster3 in istio, is the remote primary works with its own istio control plane.

set -x

function deploy_cluster {
  export K8SON=${1}
  SHARED=false
  [[ $K8SON == "primary" ]] && CLUSTER=1
  [[ $K8SON == "sremote" ]] && CLUSTER=2 SHARED=true
  [[ $K8SON == "xremote" ]] && CLUSTER=3

  export SHARED
  export CLUSTER
  bash deploy.sh
}

function deploy_verification {
  K8SON=${1}
  [[ $K8SON == "primary" ]] && CLUSTER=1
  [[ $K8SON == "sremote" ]] && CLUSTER=2
  [[ $K8SON == "xremote" ]] && CLUSTER=3
  export K8SON
  export CLUSTER

  bash 3-example.sh
}

function verify_result {
  echo "Verifying on ${1}"
  export K8SON=${1}

  echo -e "Pod ..........."
  k t g po
  echo -e "Endpoint ..............."
  bash 4-verify.sh
  echo -e "Curling ............."
  bash 5-curl.sh
  bash 5-curl.sh
  bash 5-curl.sh
}

export ISTIO_VERSION=${1}
export PRIMARY="primary"
clusters=(primary sremote xremote)

./route.sh D || true
./route.sh

for cluster in ${clusters[@]}; do 
  deploy_cluster ${cluster}
done

K8SON=primary
k a secret3.yaml

K8SON=xremote
k a secret1.yaml
k a secret2.yaml

for cluster in ${clusters[@]}; do 
  deploy_verification ${cluster}
done

for cluster in ${clusters[@]}; do
  while(true); do
    if [[ $(K8SON=${cluster} k t g po | grep -v "Running" | wc -l) == 1 ]]; then
      break
    fi
    sleep 5
  done
done

for cluster in ${clusters[@]}; do 
  verify_result ${cluster}
done

