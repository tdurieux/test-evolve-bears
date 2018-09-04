#!/usr/bin/env bash

set -e
export M2_HOME=/usr/local/maven

DOCKER_TAG=fermadeiral/test-evolve-bears:latest

if [ "$TRAVIS_PULL_REQUEST" = "true" ] && [ "$TRAVIS_BRANCH" = "pr-add-bug" ]; then

    docker pull $DOCKER_TAG

    docker run -v ${pwd}:/var/app/pr $DOCKER_TAG


else
    echo "Nothing to check."
fi