k a registry.yaml
#k d secret n2-k8s-secret -n istio-system || true
#k c secret generic n2-k8s-secret --from-file n2-k8s-config -n istio-system
#k l secret n2-k8s-secret istio/multiCluster=true -n istio-system
