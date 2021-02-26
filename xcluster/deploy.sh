#!/bin/bash

set -x

info=
if [[ $K8SON == ${PRIMARY} ]]; then
  info="primary cluster [$K8SON]"
else
  info="remote cluster [$K8SON]"
fi

if [[ $SHARED == true ]]; then
  info="$info, which shares the control plane with primary"
else
  info="$info, with its own control plane"
fi

echo -e "Deploying $info ......"

k c ns istio-system
k l ns istio-system topology.istio.io/network=network${CLUSTER}

cd ~/istio/mcluster/certs/

k i c secret generic cacerts --from-file=cluster${CLUSTER}/ca-cert.pem --from-file=cluster${CLUSTER}/ca-key.pem --from-file=cluster${CLUSTER}/root-cert.pem --from-file=cluster${CLUSTER}/cert-chain.pem

cd ..

#if ! ISTIO_VERSION=${ISTIO_VERSION} K8SON=${K8SON} ~/k8s/cactus/deploy/downloadIstioctl.sh; then
#  echo "Failed to deploy istioctl, please address first ..."
#  exit 1
#fi

ic x create-remote-secret --name=cluster${CLUSTER} > secret${CLUSTER}.yaml

# if shared control plane with primary, enable cluster's apiserver access in primary
[[ $SHARED == true ]] && {
  workon=${K8SON}
  K8SON=${PRIMARY}
  k a secret${CLUSTER}.yaml
  K8SON=${workon}
}

ic install -y -f cluster${CLUSTER}.yaml

../samples/multicluster/gen-eastwest-gateway.sh --mesh mesh1 --cluster cluster${CLUSTER} --network network${CLUSTER} | ic install -y -f -

[[ $K8SON == ${PRIMARY} ]] && k a ../samples/multicluster/expose-istiod.yaml

k a ../samples/multicluster/expose-services.yaml


