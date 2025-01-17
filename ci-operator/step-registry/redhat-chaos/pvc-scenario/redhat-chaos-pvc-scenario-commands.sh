#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
set -x
cat /etc/os-release
oc config view
oc projects
python3 --version
pushd /tmp

ls -la /root/kraken
git clone https://github.com/redhat-chaos/krkn-hub.git
pushd krkn-hub/

wget -O volume_scenario.yaml https://raw.githubusercontent.com/redhat-chaos/krkn/fe892fd9bf81b1026868ec161c3eef4a0785a86d/CI/scenarios/volume_scenario.yaml

oc create -f volume_scenario.yaml  

echo "kubeconfig loc $$KUBECONFIG"
echo "Using the flattened version of kubeconfig"
oc config view --flatten > /tmp/config

export KUBECONFIG=/tmp/config
export PVC_NAME=$PVC_NAME
export POD_NAME=$POD_NAME
export FILL_PERCENTAGE=$FILL_PERCENTAGE
export DURATION=$DURATION
export KRKN_KUBE_CONFIG=$KUBECONFIG
export NAMESPACE=$TARGET_NAMESPACE
export ENABLE_ALERTS=False

./prow/pvc-scenario/prow_run.sh
rc=$?
echo "Finished running pvc scenario"
echo "Return code: $rc"
