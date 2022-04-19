DOCKER ?= $(shell which docker)

REGISTRY ?= us-central1-docker.pkg.dev/rust-examples/pub-sub

GIT_SHA8 ?= $(shell git rev-parse--short HEAD)

.PHONY: docker-build
docker-build:
	@$(DOCKER) build -t $(REGISTRY):$(GIT_SHA8) .

.PHONY: docker-push
docker-push:
	@$(DOCKER) push $(REGISTRY):$(GIT_SHA8)

.PHONY: docker-run
docker-run:
	@$(DOCKER) run $(REGISTRY):$(GIT_SHA8)
