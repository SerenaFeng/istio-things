#!/bin/bash

function verify_result {
  echo "Verifying on ${1}"
  K8SON=${1} k t g po
  K8SON=${1} bash 4-verify.sh
}

clusters=(primary sremote xremote)

for cluster in ${clusters[@]}; do 
  verify_result ${cluster}
done

