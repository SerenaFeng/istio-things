source env.sh

echo "-1 create cluster-aware-gateway, multi-mesh only"
k a cluster-aware-gateway.yaml

echo "0 deploy metallb"
./metallb.sh

echo "1 prepare basics"
rm -fr _generates || true
mkdir _generates
k c ns ${VM_NAMESPACE}
k c sa "${SERVICE_ACCOUNT}" -n "${VM_NAMESPACE}"

echo "2 generate istio-token"
k c --raw /api/v1/namespaces/$VM_NAMESPACE/serviceaccounts/$SERVICE_ACCOUNT/token -f token-req.json | jq -j '.status.token' > "${WORK_DIR}"/_generates/istio-token

echo "3 generate root-cert.pem"
kubectl -n "${VM_NAMESPACE}" get configmaps istio-ca-root-cert -o jsonpath="{.data.root-cert\.pem}" > "${WORK_DIR}"/_generates/root-cert.pem

echo "4 generate cluster.env"
ISTIO_SERVICE_CIDR=$(echo '{"apiVersion":"v1","kind":"Service","metadata":{"name":"tst"},"spec":{"clusterIP":"1.1.1.1","ports":[{"port":443}]}}' | kubectl apply -f - 2>&1 | sed 's/.*valid IPs is //')
touch "${WORK_DIR}"/_generates/cluster.env
echo ISTIO_SERVICE_CIDR=$ISTIO_SERVICE_CIDR > "${WORK_DIR}"/_generates/cluster.env
echo "ISTIO_INBOUND_PORTS=3306,8080" >> "${WORK_DIR}"/_generates/cluster.env

echo "5 generate hosts"
source ../scripts/istiorc
i_igw
touch "${WORK_DIR}"/_generates/hosts-addendum
echo "${IGW_HOST} istiod.istio-system.svc" > "${WORK_DIR}"/_generates/hosts-addendum

echo "6 generate sidecar.env"
touch "${WORK_DIR}"/_generates/sidecar.env
echo "ISTIO_META_NETWORK=vm-network" >> "${WORK_DIR}"/_generates/sidecar.env
echo "PROV_CERT=/var/run/secrets/istio" >>"${WORK_DIR}"/_generates/sidecar.env
echo "OUTPUT_CERTS=/var/run/secrets/istio" >> "${WORK_DIR}"/_generates/sidecar.env
