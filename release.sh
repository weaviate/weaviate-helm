#!/bin/bash

set -eou pipefail

(
  cd weaviate
  VERSION=$( grep 'version:' < Chart.yaml | awk '{ print $2 }')
  echo "Running pipeline for version $VERSION"

  # cleanup in case there is a previous release already
  rm -rf "weaviate.tgz"

  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
  helm repo add elastic https://helm.elastic.co
  helm dependencies build
  helm lint .
  helm package .

  mv "weaviate-$VERSION.tgz" "weaviate.tgz"
)
