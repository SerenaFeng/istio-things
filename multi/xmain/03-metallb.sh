#!/bin/bash
pushd ../metallb
k a namespace.yaml
k a secret.yaml
k a metallb.yaml
popd
k a metallb-config.yaml

k lb g po -w
