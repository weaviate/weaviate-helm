# Weaviate Helm Chart <img alt='Weaviate logo' src='https://raw.githubusercontent.com/weaviate/weaviate/19de0956c69b66c5552447e84d016f4fe29d12c9/docs/assets/weaviate-logo.png' width='180' align='right' />

Helm chart for Weaviate application. Weaviate can be deployed to a Kubernetes cluster using this chart.

## Usage

[Helm](https://helm.sh) must be installed in order to use the weaviate chart.
Please refer to Helm's [documentation](https://helm.sh/docs/) on how to get started.

Once Helm is set up properly, add the repo as follows:
```zsh
helm repo add weaviate https://weaviate.github.io/weaviate-helm
helm install my-weaviate weaviate/weaviate
```

Documentation can be found [here](https://weaviate.io/developers/weaviate/installation/kubernetes).

## Migration from older versions to v1.25.x and above

Weaviate `v1.25` has brought a significant change in how we bootstrap the Weaviate cluster. We have changed the `podManagementPolicy` from `OrderedReady` to `Parallel`. This change is required for the Raft-based consensus model that Weaviate now utilizes under the hood. For the Raft cluster to be properly bootstrapped, all pods in the cluster must start simultaneously.

Please note that once the Raft cluster is established, rolling updates are possible. This change will only take effect during migration from versions prior to v1.25 (or when bootstrapping a new v1.25 cluster).

If you are upgrading from a version older than v1.25 to v1.25 and above, you must first delete Weaviate's Statefulset. This is a one-time operation and will not remove your data, it is necessary to make the update of Statefulset settings possible.

Detailed information can be found in the [documentation](https://weaviate.io/developers/weaviate/more-resources/migration/weaviate-1-25).

## (for contributors) How to make new releases

1. Bump chart version in `./weaviate/Chart.yaml`
1. Create a commit
1. Create an annotated tag matching the version number in Chart.yaml (prefix
   with a `v`, such as `v1.4.3`)
1. Push commit with `git push`
1. Push tag with `git push origin --tags`
1. Wait for GH Action to complete, it will create a drafted release with the
   packaged chart attached
1. Edit the draft to include useful release notes and publish when appropriate
