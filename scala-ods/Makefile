PROJECT_NAME ?= "scala-ods"

SBT ?= "sbt"

DOCKER_WORKING_DIR ?= "$(CURDIR)/target/docker/stage"

include $(CURDIR)/../mk/tf.mk
include $(CURDIR)/../mk/docker.mk

PHONY: build
build:
	@$(SBT) docker:stage

.PHONY: deploy
deploy: build docker-build docker-push tf-apply
