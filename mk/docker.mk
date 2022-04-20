REGISTRY ?= "us-central1-docker.pkg.dev/lukeshay-cloud-run-examples/examples/$(PROJECT_NAME)"

GIT_SHA8 ?= $(shell git rev-parse --short HEAD)

DOCKER ?= $(shell which docker)

DOCKER_WORKING_DIR ?= $(CURDIR)

.PHONY: docker-build
docker-build:
	@$(DOCKER) build -t $(REGISTRY):$(GIT_SHA8) -f $(DOCKER_WORKING_DIR)/Dockerfile $(DOCKER_WORKING_DIR)

.PHONY: docker-push
docker-push:
	@$(DOCKER) push $(REGISTRY):$(GIT_SHA8)

.PHONY: docker-run
docker-run:
	@$(DOCKER) run $(REGISTRY):$(GIT_SHA8)
