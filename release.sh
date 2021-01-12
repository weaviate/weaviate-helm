#!/bin/bash

set -eou pipefail

(
  cd weaviate
  VERSION=$( grep 'version:' < Chart.yaml | awk '{ print $2 }')
  echo "Running pipeline for version $VERSION"

  # cleanup in case there is a previous release already
  rm -rf "weaviate.tgz"

  helm dependencies build
  helm lint .
  helm package .

  mv "weaviate-$VERSION.tgz" "weaviate.tgz"
)
