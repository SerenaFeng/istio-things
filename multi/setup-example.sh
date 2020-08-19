v=${1:-v1}
op=${2:-a}

cd ../samples
k l ns default istio-injection=enabled --overwrite || true
k ${op} helloworld/helloworld.yaml -l app=helloworld
k ${op} helloworld/helloworld.yaml -l version=${v}
k ${op} sleep/sleep.yaml

k g po -w
