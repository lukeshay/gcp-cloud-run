TERRAFORM ?= $(shell which terraform)

COMMIT_SHA8 ?= $(shell git rev-parse --short HEAD)

.PHONY: tf
tf:
	@cd tf && TF_VAR_commit=$(COMMIT_SHA8) $(TERRAFORM) $(CMD)

.PHONY: tf-validate
tf-validate:
	@CMD="validate" make tf

.PHONY: tf-fmt
tf-fmt:
	@CMD="fmt" make tf

.PHONY: tf-plan
tf-plan:
	@CMD="plan" make tf

.PHONY: tf-apply
tf-apply:
	@CMD="apply -auto-approve" make tf

.PHONY: tf-destroy
tf-destroy:
	@CMD="destroy -auto-approve" make tf
