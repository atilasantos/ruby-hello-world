.PHONY: build push run

# Define the image name and tag
IMAGE_NAME := atilarmao/ruby-hello
TAG := latest

# Build and push the Docker image for amd64 by default, or add other arch if specified
# Usage: make build arch=<architecture>
# Example: make build arch=linux/arm64
build:
	@if [ -z "$(arch)" ]; then \
		docker buildx build --platform linux/amd64 -t $(IMAGE_NAME):$(TAG) . --push; \
	else \
		docker buildx build --platform linux/amd64,$(arch) -t $(IMAGE_NAME):$(TAG) . --push; \
	fi

# Run the Docker container
run:
	docker container run -d -p 3000:3000 -e RAILS_MASTER_KEY=$$(cat config/master.key) $(IMAGE_NAME):$(TAG)
