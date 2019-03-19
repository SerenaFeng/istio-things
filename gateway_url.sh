
ingw=$(kubectl get svc istio-ingressgateway -n istio-system | tail -1 | awk '{print $4}')

[[ $ingw =~ (pending|none) ]] && {

  INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

  INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o 'jsonpath={.items[0].status.hostIP}')
} || {
  INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
}

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
