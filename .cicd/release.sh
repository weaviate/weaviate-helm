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
  GH_PAGES_DIR="files-to-gh-pages"
  cd ..
  mkdir -p $GH_PAGES_DIR
  echo $(pwd)
  helm package weaviate -d $GH_PAGES_DIR
  cp README.md $GH_PAGES_DIR
  cd $GH_PAGES_DIR
  helm repo index .
  ls -ltr
)
