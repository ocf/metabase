DOCKER_REVISION ?= metabase-testing-$(USER)
DOCKER_TAG = docker-push.ocf.berkeley.edu/metabase:$(DOCKER_REVISION)
RANDOM_PORT := $(shell expr $$(( 8000 + (`id -u` % 1000) + 2 )))

MB_VERSION := v0.32.9

.PHONY: dev
dev: cook-image
	@echo "Will be accessible at http://$(shell hostname -f ):$(RANDOM_PORT)/"
	docker run --rm -p "$(RANDOM_PORT):3000" --env-file ${PWD}/config.env "$(DOCKER_TAG)"

.PHONY: cook-image
cook-image:
	git clone https://github.com/metabase/metabase --depth 1 -b $(MB_VERSION) src
	cd src; git apply ../patches/*; \
	docker build --pull -t $(DOCKER_TAG) .
	rm -rf src

.PHONY: push-image
push-image:
	docker push $(DOCKER_TAG)
