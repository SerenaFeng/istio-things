ic x create-remote-secret --name xremote > ../xmain/registry.yaml
#export SECRET_NAME=$(k get sa istio-reader-service-account -n istio-system -o jsonpath='{.secrets[].name}')
#export CA_DATA=$(k g secret ${SECRET_NAME} -n istio-system -o jsonpath="{.data['ca\.crt']}")
#export TOKEN=$(k g secret ${SECRET_NAME} -n istio-system -o jsonpath="{.data['token']}" | base64 --decode)
#export CLUSTER_NAME=$(k config view --minify=true -o jsonpath='{.clusters[].name}')
#export SERVER=$(k config view --minify=true -o jsonpath='{.clusters[].cluster.server}')
#
#envsubst < n2-k8s-config > ../xmain/n2-k8s-config

