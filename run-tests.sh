#!/bin/bash
echo "WORKSPACE in run-tests.sh: ${WORKSPACE}"
docker run \
    -v ${WORKSPACE}:/tests \
    golang:1.16.6-alpine3.14 \
    /tests/scripts/test_in_docker.sh
