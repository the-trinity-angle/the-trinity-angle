APP_NAME := astro-starlight
IMAGE_NAME := $(APP_NAME):dev
CONTAINER_NAME := $(APP_NAME)
PORT := 4321

.PHONY: build run clean rebuild shell init

build:
	podman build \
		-t $(IMAGE_NAME) \
		-f container/Containerfile \
		.

init: build
	podman run --rm -it \
		-v "$$(pwd):/site:Z" \
		-w /site \
		$(IMAGE_NAME) \
		sh -lc 'npm create astro@latest docs -- --template starlight'

run:
	podman rm -f $(CONTAINER_NAME) 2>/dev/null || true
	podman run --rm -it \
		--name $(CONTAINER_NAME) \
		-p $(PORT):4321 \
		-v "$$(pwd)/docs:/site/docs:Z" \
		$(IMAGE_NAME)

shell:
	podman run --rm -it \
		-v "$$(pwd)/docs:/site/docs:Z" \
		$(IMAGE_NAME) \
		sh

clean:
	podman rm -f $(CONTAINER_NAME) 2>/dev/null || true
	podman rmi -f $(IMAGE_NAME) 2>/dev/null || true

rebuild: clean build
