# 1. connection termination after setting DestinationRule

Error response

```bash
$ curl http://${GATEWAY_URL}/productpage
istio upstream connect error or disconnect/reset before headers. reset reason: connection termination
```

tls_check result

```bash
$ istioctl authn tls-check istio-ingressgateway-6b94c84dbd-vhjt8.istio-system productpage.default.svc.cluster.local
HOST:PORT                                      STATUS     SERVER     CLIENT     AUTHN POLICY     DESTINATION RULE
productpage.default.svc.cluster.local:9080     OK         STRICT     -          /default         default/productpage
```

bugfix solution 1: set trafficPolicy when configuring DestinationRule

```yaml
trafficPolicy:
  tls:
    mode: ISTIO_MUTUAL
```

tls_check result after setting trafficPolicy

```bash
istioctl authn tls-check istio-ingressgateway-6b94c84dbd-vhjt8.istio-system productpage.default.svc.cluster.local
HOST:PORT                                      STATUS     SERVER     CLIENT           AUTHN POLICY     DESTINATION RULE
productpage.default.svc.cluster.local:9080     OK         STRICT     ISTIO_MUTUAL     /default         default/productpage
```

bugfix solution 2: disable mtls

```yaml
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "productpage"
spec:
  targets:
  - name: productpage
```

tls_check result after disabling mtls

```bash
$ istioctl authn tls-check istio-ingressgateway-6b94c84dbd-vhjt8.istio-system productpage.default.svc.cluster.local
HOST:PORT                                      STATUS     SERVER      CLIENT     AUTHN POLICY            DESTINATION RULE
productpage.default.svc.cluster.local:9080     OK         DISABLE     -          default/productpage     default/productpage
```


