#!/usr/bin/env bash

set -e
export M2_HOME=/usr/local/maven

DOCKER_TAG=fermadeiral/test-evolve-bears:latest

docker pull $DOCKER_TAG

docker run -v ${pwd}:/var/app/pr $DOCKER_TAG
