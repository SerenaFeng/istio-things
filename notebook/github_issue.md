# 1. V1_POD_IP & V2_POD_IP setting error

bugfix:

```bash
export V1_POD_IP=$(kubectl get pod -l app=httpbin,version=v1 -o jsonpath={.items..status.podIP})
export V2_POD_IP=$(kubectl get pod -l app=httpbin,version=v2 -o jsonpath={.items..status.podIP})
```
