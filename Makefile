.PHONY: docker-build docker-run add-hosts help

.DEFAULT_GOAL := help

# Help target to display available commands
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Define the image name and tag
REGISTRY:= oci://docker.io/atilarmao
REPOSITORY := atilarmao/ruby-hello
TAG := 0.0.1

docker-build: ## Target specified to build and push the docker image for linux/amd64 arch, you can specify other architectures by `make build arch=linux/arm64`.
	@if [ -z "$(arch)" ]; then \
		docker buildx build --platform linux/amd64 -t $(REPOSITORY):$(TAG) . --push; \
	else \
		docker buildx build --platform linux/amd64,$(arch) -t $(REPOSITORY):$(TAG) . --push; \
	fi

docker-run: ## Target specified to run the builded application as a standalone container being port-forwareded to port 3000 of the host.
	docker container run -d -e SECRET_KEY_BASE=6dt7Q23Q1Z6P -p 3000:3000 $(REPOSITORY):$(TAG)

helm-package: ## Targe specified to package the helm chart and push it to dockerhub.
	helm package .helm/ruby-hello --version $(TAG)
	helm push "ruby-hello-$(TAG).tgz" $(REGISTRY)

helm-run: ## Target to install the helm release for the application.
	helm install hello-app ./.helm/ruby-hello -f ./.helm/ruby-hello/values.yaml --set "env[0].name=SECRET_KEY_BASE" --set "env[0].value=6dt7Q23Q1Z6P" -n lovevery --create-namespace

helm-uninstall: ## Target to uninstall the helm release for the application.
	helm uninstall hello-app -n lovevery
	make remove-hosts

add-hosts: ## Target specified to add to /etc/hosts an entry where the app can be accessed via local.localhost in kubernetes deployments.
	@echo "Adding local.localhost to /etc/hosts"
	@IP=""
	@while [ -z "$$IP" ]; do \
		IP=$$(kubectl get ingress -n lovevery ruby-hello -o jsonpath="{.status.loadBalancer.ingress[0].ip}"); \
		sleep 2; \
	done; \
	echo "$$IP local.localhost" | sudo tee -a /etc/hosts

remove-hosts: ## Target specified to remove the local.localhost entry from /etc/hosts
	@echo "Removing local.localhost from /etc/hosts"
	@sudo sed -i '' '/local.localhost/d' /etc/hosts

