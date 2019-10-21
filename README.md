# weaviate-helm <img alt='Weaviate logo' src='https://raw.githubusercontent.com/semi-technologies/weaviate/19de0956c69b66c5552447e84d016f4fe29d12c9/docs/assets/weaviate-logo.png' width='180' align='right' />

> Deploy weaviate, the open source knowledge graph, to Kubernetes with this
> helm chart.

More information about weaviate at [semi-technologies/weaviate](https://github.com/semi-technologies/weaviate).

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
export CHART_VERSION="v0.8.0"
export DOWNLOAD_URL="https://github.com/semi-technologies/weaviate-helm/releases/download/$CHART_VERSION/weaviate.tgz"
curl --fail -L -o  charts/weaviate.tgz "$DOWNLOAD_URL"
```

Once you have obtained the chart, you can helm install it. The following
assumes that you have created your own `values.yaml`. While you can install
weaviate without a custom `values.yaml`, we **strongly** recommend that you
overwrite at least the `image.tag` value. Otherwise a chart upgrade could lead
to an unexpected Weaviate update.

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

## etcd Disaster Recovery

### Why is this necessary?
The weaviate chart depends on the bitnami `etcd` chart to provision `etcd` in
the namespace. `etcd` is a vital component to Weaviate as it provides
abilites for distributed RW locking as well as consistent configuration for
critical areas.

Unfortunately, without *disaster recovery* enabled, the `etcd` cluster can end
up in a deadlock situation without a possiblity to recover. If a majority of
`etcd` pods become unavailable, it's impossible for new members to join. So
especially with small cluster sizes, such as three pods, it only takes the
simultaneous death of two pods for the cluster to be unrecoverable.

As a mitigation for this disaster scenario, the `etcd` chart (>= `v3.0.0`)
provides a *disaster recovery* option, where the etcd cluster can be resurected
without a minimum number of pods. For this a snapshot is created at a regular
interval, which can then be read back to bootstrap a "new" cluster.

### When should this feature be enabled?

We recommend this feature to be enabled in any scenario where Weaviate should
be able to survive cluster node upgrades,  cluster auto-scaling or random node
deaths (as they are quite common on Kubernetes).

### Why is not enabled by default if it's so important?

This snapshotting process requires an nfs volume. This in turn requires an nfs
provisioner, such as `@stable/nfs-server-provisioner`. Since we cannot assume
that the provisioner is present on a random cluster, the chart has to default
to `etcd.disasterRecovery.enabled: false` (see `values.yaml`). Nevertheless, we
recommend turning this on in most cases.

Unfortunately bundling an nfs provisioner with Weaviate is impossible because
of the different lifecycles. The provisioner should be deployed before weaviate
is deployed and only removed after Weaviate is removed. Otherwise - if the
provisioner were to be torn down with weaviate - it would be impossible to
destroy the volumes it created when deploying Weaviate.

### How can I turn it on?

#### Step 1: Make sure the cluster supports nfs volumes

The easiest way to do so is to deploy `@stable/nfs-server-provisioner` into
the `default` namespace. For example, run:

```bash
NFS_VERSION="0.3.0"
helm upgrade \
  --install \
  --namespace default \
  --version "$NFS_VERSION" \
  nfs-server-provisioner \
  stable/nfs-server-provisioner \
  --set persistence.enabled=true \
  --set persistence.size=10Gi
```

#### Step 2: Turn on disaster recovery

In your `values.yaml` set `etcd.disasterRecovery.enabled` to `true`, then
deploy Weaviate normally with your `values.yaml`.

Alternatively, if you don't want to use a `values.yaml`, include `--set
etcd.disasterRecover.enabled=true` in your `helm install` or `helm upgrade`
command.

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
