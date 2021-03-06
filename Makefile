# Makefile for a standard repo with associated container

##### These variables need to be adjusted in most repositories #####

# This repo's root import path (under GOPATH).
#PKG := github.com/drud/repo_name

# Docker repo for a push
DOCKER_REPO ?= drud/nginx-proxy

# Upstream repo used in the Dockerfile
UPSTREAM_REPO ?= jwilder/nginx-proxy:0.4.0

# Top-level directories to build
#SRC_DIRS := files drudapi secrets utils


# VERSION can be set by
  # Default: git tag
  # make command line: make VERSION=0.9.0
# It can also be explicitly set in the Makefile as commented out below.

# This version-strategy uses git tags to set the version string
# VERSION can be overridden on make commandline: make VERSION=0.9.1 push
VERSION := $(shell git describe --tags --always --dirty)
#
# This version-strategy uses a manual value to set the version string
#VERSION := 1.2.3

# Each section of the Makefile is included from standard components below.
# If you need to override one, import its contents below and comment out the
# include. That way the base components can easily be updated as our general needs
# change.
#include build-tools/makefile_components/base_build_go.mak
include build-tools/makefile_components/base_build_python-docker.mak
include build-tools/makefile_components/base_container.mak
include build-tools/makefile_components/base_push.mak
#include build-tools/makefile_components/base_test_go.mak
include build-tools/makefile_components/base_test_python.mak

test: container
	@docker stop nginx-proxy-test || true
	@docker rm nginx-proxy-test || true
	docker run -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro --name nginx-proxy-test -d $(DOCKER_REPO):$(VERSION)
	sleep 5 && curl -I localhost | grep 503  # Make sure we get a 503 from nginx by default