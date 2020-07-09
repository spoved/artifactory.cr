#!/usr/bin/env bash

if [ -e ./test/ ];then
  rm -rf ./test/
fi

mkdir -p \
  ./test/postgresql \
  ./data/nginx \
  ./test/artifactory

docker-compose up