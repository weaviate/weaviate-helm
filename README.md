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
