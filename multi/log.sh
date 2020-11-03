app=${1:-helloworld}

istiod=$(k i g po -l app=istiod -o=jsonpath='{.items[0].metadata.name}')
k i lg $istiod > istiod.log
ingress=$(k i g po -l app=istio-ingressgateway -o=jsonpath='{.items[0].metadata.name}')
k i lg $ingress > ingress.log

app=$(k g po -l app=${app} -o=jsonpath='{.items[0].metadata.name}')
k lg $app -c istio-proxy > proxy.log
