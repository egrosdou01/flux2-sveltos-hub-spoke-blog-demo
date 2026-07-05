#!/usr/bin/env bash

# This script tears down the fleet of Kubernetes clusters.

set -o errexit
set -o pipefail

CLUSTER_HUB="hub"
echo "INFO: Deleting cluster ${CLUSTER_HUB}"

kind delete cluster --name "${CLUSTER_HUB}"

CLUSTER_STAGING="staging"
echo "INFO: Deleting cluster ${CLUSTER_STAGING}"

kind delete cluster --name "${CLUSTER_STAGING}"

CLUSTER_PRODUCTION="production"
echo "INFO: Deleting cluster ${CLUSTER_PRODUCTION}"

kind delete cluster --name "${CLUSTER_PRODUCTION}"

echo "INFO: Clusters deleted successfully"
