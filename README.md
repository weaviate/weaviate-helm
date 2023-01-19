# Weaviate Helm Chart <img alt='Weaviate logo' src='https://raw.githubusercontent.com/weaviate/weaviate/19de0956c69b66c5552447e84d016f4fe29d12c9/docs/assets/weaviate-logo.png' width='180' align='right' />

> Deploy weaviate, the open vector search engine, to Kubernetes with this
> helm chart.

Documentation can be found [here](https://weaviate.io/developers/weaviate/current/getting-started/installation.html#kubernetes-k8s).

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


