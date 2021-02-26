#!/bin/bash

echo "Deploy verification on ${K8SON} - ${CLUSTER}"

k c ns sample
k l ns sample istio-injection=enabled
k t a helloworld.yaml -l service=helloworld
k t a helloworld.yaml -l version=v${CLUSTER}
k t a ../samples/sleep/sleep.yaml

