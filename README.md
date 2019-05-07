# weaviate-helm <img alt='Weaviate logo' src='https://raw.githubusercontent.com/creativesoftwarefdn/weaviate/19de0956c69b66c5552447e84d016f4fe29d12c9/docs/assets/weaviate-logo.png' width='180' align='right' />

> Deploy weaviate, the open source knowledge graph, to Kubernetes with this
> helm chart.

More information about weaviate at [creativesoftwarfdn/weaviate](https://github.com/creativesoftwarefdn/weaviate).

## Key Features
- Supports full backend stack with Janusgraph backed by Cassandra and
  Elasticsearch
- Configuration storage and distributed locking (for seamless horizontal
  scaling) through etcd
- Optional support for an Analytics Backend (Spark) to perform background
  analytics jobs
- Plenty of configuration options through values.yaml

## How to obtain and install the Chart
You can download the chart from the binaries attached to the [Releases](https://github.com/semi-technologies/weaviate-helm/releases).

To download the releases programatically you could use the following bash snippet:
```bash
export CHART_VERSION="v0.2.0"
export DOWNLOAD_URL="https://github.com/semi-technologies/weaviate-helm/releases/download/$CHART_VERSION/weaviate.tgz"
curl --fail -L -o  charts/weaviate.tgz "$DOWNLOAD_URL"
```

Once you have obtained the chart, you can helm install it:
```bash
export NAMESPACE=weaviate
export NAME=weaviate
helm upgrade \
  --values ./values.yaml \
  --install \
  --namespace "$NAMESPACE" \
  "$NAME" \
  charts/weaviate.tgz
```

## Changelog

The chart uses semantic versioning. Please see the [Releases Page](https://github.com/semi-technologies/weaviate-helm/releases) for changes.

## (for contributors) How to make new releases

1. Bump chart version in `./weaviate/Chart.yaml`
1. Create a commit
1. Create an annotated tag matching the version number in Chart.yaml (prefix
   with a `v`, such as `v1.4.3`)
1. Push commit with `git push`
1. Push tag with `git push origin --tags`
1. Wait for Travis to complete, it will create a drafted release with the
   packaged chart attached
1. Edit the draft to include useful release notes and publish when appropriate
