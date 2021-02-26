#!/bin/bash

ns=${1:-istio-system}

clusters=(primary sremote xremote)

for cluster in ${clusters[@]}; do
  set -x
  K8SON=${cluster} k d ns ${ns} --wait=false
  set +x
done

