SHELL := /bin/bash
VERSION_TAG := $(shell git describe --always --dirty --tags)
SWARM_MANAGER := hcloud

ifeq ($(VERSION_TAG),)
$(error git describe empty! Check the git status)
endif

.PHONY: help
help: ## help message, list all command
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

.PHONY: run 
run: ## run all needed container for dev
	docker-compose up

.PHONY: deploy-prod 
deploy-prod: deploy-yml-prod ## deploy docker-compose definition and pull images
	
.PHONY: deploy-yml-prod
deploy-yml-prod: ## deploy docker-compose definition
	scp docker-compose.yml $(SWARM_MANAGER):/tmp/openpodcast.yml
	ssh $(SWARM_MANAGER) "sudo mv /tmp/openpodcast.yml /opt/stacks"
	ssh $(SWARM_MANAGER) "sudo docker stack deploy --with-registry-auth --compose-file /opt/stacks/openpodcast.yml openpodcast"