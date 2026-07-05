# Requirements: docker, kind, kubectl

.ONESHELL:
.SHELLFLAGS += -e

.PHONY: fleet-up
fleet-up: # Start three local KinD clusters up and running
	scripts/fleet-up.sh

.PHONY: fleet-down
fleet-down: # Teardown the demo setup
	scripts/fleet-down.sh

.PHONY: flux-up
flux-up: # Bootstrap Flux on the hub cluster
	scripts/flux-up.sh

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
