PROJECT_NAME ?= "scala-ods"

SBT ?= "sbt"

DOCKER_WORKING_DIR ?= "$(CURDIR)/target/docker/stage"

include $(CURDIR)/../mk/tf.mk
include $(CURDIR)/../mk/docker.mk

PHONY: build
build:
	@$(SBT) docker:stage
