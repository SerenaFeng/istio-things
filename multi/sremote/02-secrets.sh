k c namespace istio-system
k c secret generic cacerts -n istio-system \
    --from-file=../certs/ca-cert.pem \
    --from-file=../certs/ca-key.pem \
    --from-file=../certs/root-cert.pem \
    --from-file=../certs/cert-chain.pem
