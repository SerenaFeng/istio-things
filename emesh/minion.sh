set -x

sudo apt -y update
sudo apt -y upgrade
sudo mkdir -p /var/run/secrets/istio
sudo cp "${HOME}"/root-cert.pem /var/run/secrets/istio/root-cert.pem

sudo  mkdir -p /var/run/secrets/tokens
sudo cp "${HOME}"/istio-token /var/run/secrets/tokens/istio-token

curl -LO https://storage.googleapis.com/istio-release/releases/1.7.3/deb/istio-sidecar.deb
sudo dpkg -i istio-sidecar.deb

sudo cp "${HOME}"/cluster.env /var/lib/istio/envoy/cluster.env
sudo cp "${HOME}"/sidecar.env /var/lib/istio/envoy/sidecar.env
sudo sh -c 'cat $(eval echo ~$SUDO_USER)/hosts-addendum >> /etc/hosts'
sudo mkdir -p /etc/istio/proxy
sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy  /var/run/secrets
