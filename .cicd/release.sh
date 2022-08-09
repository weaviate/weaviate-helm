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

  echo "Add chart version $VERSION to GitHub Pages"
  cd ..
  mkdir -p files-to-gh-pages
  echo $(pwd)
  helm package weaviate -d files-to-gh-pages
  cp README.md files-to-gh-pages
  cd files-to-gh-pages
  helm repo index .
  ls -ltr
)
