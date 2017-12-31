DOCKER_REVISION ?= metabase-testing-$(USER)
DOCKER_TAG = docker-push.ocf.berkeley.edu/metabase:$(DOCKER_REVISION)
RANDOM_PORT := $(shell expr $$(( 8000 + (`id -u` % 1000) + 2 )))

MB_VERSION := v0.27.2

.PHONY: dev
dev: cook-image
	@echo "Will be accessible at http://$(shell hostname -f ):$(RANDOM_PORT)/"
	docker run --rm -p "$(RANDOM_PORT):3000" -v ${PWD}/config.env:/etc/ocf-metabase/config.env "$(DOCKER_TAG)"

.PHONY: cook-image
cook-image:
	docker build --build-arg metabase_version=$(MB_VERSION) --pull -t $(DOCKER_TAG) .

.PHONY: push-image
push-image:
	docker push $(DOCKER_TAG)
