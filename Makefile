TAG=example
VERSION=0.1
IMAGE=go-server
HOST_PORT=9000
POD_PORT=80

# DB
POSTGRES_DB=dev
POSTGRES_USER=postgres-dev
POSTGRES_PASSWORD=secretPassword

#PGADMIN
PGADMIN_DEFAULT_EMAIL=live@admin.me
PGADMIN_DEFAULT_PASSWORD=1234
HOST_PGADMIN_PORT=9001
POD_PGADMIN_PORT=9001

build:
	podman build --tag $(IMAGE)\:$(VERSION) -f ./Containerfile

run:
	podman build --tag $(IMAGE)\:$(VERSION) -f ./Containerfile
	if podman pod exists ${TAG}; then \
		echo pod exists; \
	else \
		echo creating pod; \
		podman pod create --name ${TAG} -p ${HOST_PORT}\:${POD_PORT} -p ${HOST_PGADMIN_PORT}\:${POD_PGADMIN_PORT}; \
	fi
	
	podman run --pod=${TAG}                                   \
	-e PGADMIN_DEFAULT_EMAIL=${PGADMIN_DEFAULT_EMAIL}         \
	-e PGADMIN_DEFAULT_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}   \
	-e PGADMIN_LISTEN_PORT=${POD_PGADMIN_PORT}                \
	--name=pgadmin12                                          \
	-dt dpage/pgadmin4

	podman run --pod=${TAG} --name=db         \
	-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
	-e POSTGRES_USER=${POSTGRES_USER}         \
	-dt postgres\:latest

	podman run -dt --pod=${TAG} --name=app $(IMAGE)

# DEVELOPMENT
ROOT                    := $(PWD)
GO_HTML_COV             := ./coverage.html
GO_TEST_OUTFILE         := ./c.out
GOLANG_PODMAN_IMAGE     := golang\:1.19
GOLANG_PODMAN_CONTAINER := dev-go-example

#   Format according to gofmt: https://github.com/cytopia/podman-gofmt
#   Usage:
#       make fmt
#       make fmt path=src/elastic/index_setup.go
fmt:
ifdef path
	podman run --rm -v ${ROOT}\:/data cytopia/gofmt -s -w ${path}
else
	podman run --rm -v ${ROOT}\:/data cytopia/gofmt -s -w .
endif

#   Deletes container if exists
clean:
	podman rm -f ${GOLANG_PODMAN_CONTAINER} || true

test:
	podman run --rm -w /app -v ${ROOT}\:/app ${GOLANG_PODMAN_IMAGE} go test ./... -coverprofile=${GO_TEST_OUTFILE}
	podman run --rm -w /app -v ${ROOT}\:/app ${GOLANG_PODMAN_IMAGE} go tool cover -html=${GO_TEST_OUTFILE} -o ${GO_HTML_COV}

lint:
	podman run --rm -v ${ROOT}:/data cytopia/golint .

bash:
	podman run -it \
		-w /app \
		-v ${ROOT}\:/app \
		--name=${GOLANG_PODMAN_IMAGE} /bin/bash
