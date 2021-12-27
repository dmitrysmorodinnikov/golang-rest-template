.PHONY: all
all: setup build lint test.unit

assign-vars = $(if $(1),$(1),$(shell grep '$(2): ' application.yml | tail -n1| cut -d':' -f2 | cut -d' ' -f2))

APP=golang-rest-template
APP_PACKAGES=$(shell go list ./...)
APP_EXECUTABLE="./out/$(APP)"
UNIT_TEST_PACKAGES=$(shell go list ./... | grep -v "/it")
INTEGRATION_TEST_PATH?=./it

build-deps:
	go mod tidy

compile:
	mkdir -p out/
	go build -o $(APP_EXECUTABLE)

setup:
	export GO111MODULE=on
	if [ ! -e $(shell go env GOPATH)/bin/golangci-lint ] ; then curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(shell go env GOPATH)/bin v1.39.0 ; fi;

build: build-deps compile

install:
	go install ./...

lint: setup
	GO111MODULE=on golangci-lint run --disable-all \
	--enable=staticcheck --enable=unused --enable=gosimple --enable=structcheck --enable=varcheck --enable=ineffassign \
	--enable=deadcode --enable=stylecheck --enable=unconvert --enable=gofmt \
	--enable=unparam --enable=nakedret --enable=gochecknoinits --enable=depguard --enable=gocyclo --enable=misspell \
	--enable=megacheck --enable=goimports --enable=golint --enable=govet --enable=gocritic \
	--enable=exportloopref --enable=rowserrcheck \
	--exclude='Using the variable on range scope \`tt\` in function literal' \
	--deadline=5m --no-config

copy-config:
	cp application.yml.sample application.yml

test.unit: copy-config
	go test $(UNIT_TEST_PACKAGES) -p 1 -count 1 -timeout 30s -race -failfast --cover ./...

test.integration: copy-config
	go test $(INTEGRATION_TEST_PATH) -v -count=1

run: build copy-config
	go run main.go start $(filepath)

docker.start:
	docker build -t golang-rest-template . && docker run -d --name golang-rest-template golang-rest-template && docker exec -it golang-rest-template /bin/bash