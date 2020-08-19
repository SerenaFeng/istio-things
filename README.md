# istio-things

## scripts/istiorc

Shortcuts of istio commands

## scripts/validate.go

Validate the outbound traffic rules configured by istio, by testing redirection from 127.0.0.6:15002 to 127.0.0.1:15002

## multi

Including multi-cluster deployment scripts and verifications. The testing leverages serenfeng/cactus for the kubernetes deployment.

### xmain&xremote 
It is a pair for the shared control plane and multi-networks model. The executing order is:

- xmain/01-k8s.sh
- xmain/02-cacerts.sh
- xmain/03-metallb.sh
- xmain/04-istio.sh
- xmain/05-aware-gw.sh
- xremote/01-k8s.sh
- xremote/02-cacerts.sh
- xremote/03-metallb.sh
- xremote/04-istio.sh
- xremote/05-aware-gw.sh
- **xremote/06-registry.sh**
- **xmain/06-registry.sh**
- xmain/07-example.sh
- xremote/07-example.sh
- xmain/08-verify.sh
- xmain/09-curl.sh
- xremote/8-verify.sh
- xremote/09-curl.sh

### smain&sremote 
This a couple for the shared control plane with the same network model. The model is not completed due to the connectivity failure between pods from different clusters.

### replicas 
It is for the replicated control planes. 
