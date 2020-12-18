# Weaviate

[Weaviate](https://www.semi.network/products/weaviate.html) is a decentralised vector search engine.

## TL;DR

```bash
$ helm package .
$ helm install --name weaviate ./weaviate-0.0.1.tgz
```

## Introduction

This chart installs weaviate along with it's dependancies (default: etcd) on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernets 1.8+
- PV provisioner support in the underlying infrastructure
