#!/usr/bin/env bash

# This script creates a fleet of Kubernetes clusters using kind.

# Prerequisites
# - docker v29.3.1
# - kind v0.31.0
# - kubectl v1.34.6

set -o errexit
set -o pipefail

repo_root=$(git rev-parse --show-toplevel)
mkdir -p "${repo_root}/bin"

CLUSTER_VERSION="${CLUSTER_VERSION:=v1.35.0}"

CLUSTER_HUB="hub"
echo "INFO: Creating cluster ${CLUSTER_HUB}"

kind create cluster --name "${CLUSTER_HUB}" \
--image "kindest/node:${CLUSTER_VERSION}" \
--wait 5m

CLUSTER_STAGING="staging"
echo "INFO: Creating cluster ${CLUSTER_STAGING}"

kind create cluster --name "${CLUSTER_STAGING}" \
--image "kindest/node:${CLUSTER_VERSION}" \
--wait 5m

CLUSTER_PRODUCTION="production"
echo "INFO: Creating cluster ${CLUSTER_PRODUCTION}"

kind create cluster --name "${CLUSTER_PRODUCTION}" \
--image "kindest/node:${CLUSTER_VERSION}" \
--wait 5m

echo "INFO: Creating kubeconfig secrets in the hub cluster"

kubectl config use-context "kind-${CLUSTER_HUB}"

kind get kubeconfig --internal --name ${CLUSTER_STAGING} > "${repo_root}/bin/staging.kubeconfig"
kubectl --context "kind-${CLUSTER_HUB}" create ns staging --dry-run=client -o yaml | \
  kubectl --context "kind-${CLUSTER_HUB}" apply -f -
kubectl --context "kind-${CLUSTER_HUB}" create secret generic -n staging cluster-kubeconfig \
  --from-file=value="${repo_root}/bin/staging.kubeconfig" \
  --dry-run=client -o yaml | kubectl --context "kind-${CLUSTER_HUB}" apply -f -

kind get kubeconfig --internal --name ${CLUSTER_PRODUCTION} > "${repo_root}/bin/production.kubeconfig"
kubectl --context "kind-${CLUSTER_HUB}" create ns production --dry-run=client -o yaml | \
  kubectl --context "kind-${CLUSTER_HUB}" apply -f -
kubectl --context "kind-${CLUSTER_HUB}" create secret generic -n production cluster-kubeconfig \
  --from-file=value="${repo_root}/bin/production.kubeconfig" \
  --dry-run=client -o yaml | kubectl --context "kind-${CLUSTER_HUB}" apply -f -

echo "INFO: Creating Sveltos kubeconfig secrets in the hub cluster"

# Secret names follow the convention expected by the EventTrigger ConfigMap
# templates: <cluster-name>-sveltos-kubeconfig with key: kubeconfig.
kubectl --context "kind-${CLUSTER_HUB}" create ns projectsveltos --dry-run=client -o yaml | \
  kubectl --context "kind-${CLUSTER_HUB}" apply -f -

kubectl --context "kind-${CLUSTER_HUB}" create secret generic \
  -n staging staging-sveltos-kubeconfig \
  --from-file=kubeconfig="${repo_root}/bin/staging.kubeconfig" \
  --dry-run=client -o yaml | kubectl --context "kind-${CLUSTER_HUB}" apply -f -

kubectl --context "kind-${CLUSTER_HUB}" create secret generic \
  -n production production-sveltos-kubeconfig \
  --from-file=kubeconfig="${repo_root}/bin/production.kubeconfig" \
  --dry-run=client -o yaml | kubectl --context "kind-${CLUSTER_HUB}" apply -f -

echo "INFO: Clusters created successfully"
