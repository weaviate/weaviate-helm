# Weaviate

[Weaviate](https://www.semi.network/products/weaviate.html) is a decentralised semantic knowledge graph.

## TL;DR

```bash
$ helm package .
$ helm install --name weaviate ./weaviate-0.0.1.tgz
```

## Introduction

This chart installs weaviate along with it's dependancies (default: JanusGraph, Cassandra, Elasticsearch) on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernets 1.8+
- PV provisioner support in the underlying infrastructure

## Configuration

The following table lists the configurable parameters of the Weaviate chart and their default values.

| Parameter                                  					| Description                                                                                 | Default                                             |
|---------------------------------------------------------------|---------------------------------------------------------------------------------------------|-----------------------------------------------------|
| `global.db`			                     					| Database to use                                                               			  | `cassandra`                                         |
| `global.index`                             					| Index storage to use   	                                                                  | `elasticsearch`                                     |
| `image.registry`                           					| Weavite image registry                                                                      | `docker.io/`                                        |
| `image.tag`	                             					| Weavite image tag                                                                        	  | `unstable`                                          |
| `importer`	                             					| Run Weaviate demo import script (as Job)                                                    | `false`                                             |
| `autoscaling.enabled`	                     					| Enable (CPU based) autoscaling for weaviate                                                 | `false`                                             |
| `autoscaling.cpuTargetPercentage`	                     		| CPU threshold for autoscaling                                                               | `70`                                          	    |
| `autoscalingreplicasMin`	                             		| Minimum number of instances of Weaviate (when autoscaling enabled)                          | `1`                                          		|
| `autoscalingreplicasMax`	                             		| Maximum number of instances of Weaviate (when autoscaling enabled)                          | `5`                                          		|
| `cassandra.deploy`	                     					| Deploy Cassandra as subchart                                                                | `true`                                          	|
| `cassandra.image.tag`	                     					| Cassandra image tag                                                                         | `3`                                          		|
| `cassandra.config.cluster_size`	                     		| The number of nodes in the Cassandra cluster.                                               | `2`                                          		|
| `cassandra.config.seed_size`	                     			| The number of seed nodes used to bootstrap new clients joining the Cassandra cluster.       | `2`                                          		|
| `cassandra.config.start_rpc`	                     			| Start the RPC interface for Cassandra                                                       | `true`                                          	|
| `cassandra.resources.requests.memory`	                     	| Cassandra Memory Requests                                                                   | `4Gi`                                          		|
| `cassandra.resources.requests.cpu`	                     	| Cassandra CPU Requests                                                                      | `2`                                          		|
| `cassandra.resources.limits.memory`	                     	| Cassandra Memory Limits                                                                     | `4Gi`                                          		|
| `cassandra.resources.limits.cpu`	                     		| Cassandra CPU Limits                                                                        | `2`                                          		|
| `elasticsearch.deploy-so`	                     				| Deploy Elasticsearch chart as a subchart                                                    | `true`                                          	|
| `elasticsearch.master.replicas`	                     		| Master node replicas for Elasticsearch                                                      | `2`                                          		|
| `elasticsearch.client.replicas`	                     		| Client node replicas for Elasticsearch                                                      | `2`                                          		|
| `elasticsearch.cluster.env`	                     			| Elasticsearch cluster environment variables                                                 | `MINIMUM_MASTER_NODES: "2"`                         |
| `janusgraph.image.repository`	                     			| JanusGraph image registry                                                                   | `creativesoftwarefdn/janusgraph-docker`             |
| `janusgraph.image.tag`	                     				| JanusGraph image tag                                                                        | `0.2.0`                                          	|
| `janusgraph.replicaCount`	                     				| JanusGraph cluster size                                                                     | `1`                                          		|
| `janusgraph.resources.requests.memory`	                    | JanusGraph memory request                                                                   | `2Gi`                                        	  	|
| `janusgraph.resources.requests.cpu`	                     	| JanusGraph cpu request                                                                      | `1`                                          		|
| `janusgraph.resources.limits.memory`	                     	| JanusGraph memory limit                                                                     | `2Gi`                                          		|
| `janusgraph.resources.limits.cpu`	                     		| JanusGraph cpu limit                                                                        | `1`                                          		|
| `janusgraph.properties.storage.backend`	                    | JanusGraph storage implementation                                                           | `cassandra`                                         |
| `janusgraph.properties.storage.directory`	                    | JanusGraph storage directory                                                                | `/db/cassandra`                                     |
| `janusgraph.properties.storage.hostname`	                    | JanusGraph storage hostname                                                                 | `weaviate-cassandra`                                |
| `janusgraph.properties.gremlin.graph`	                     	| JanusGraph Gremlin graph                                                                    | `org.janusgraph.core.JanusGraphFactory`             |
