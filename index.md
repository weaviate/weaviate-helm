---
layout: default
---

## Weaviate Helm Charts
{% for helm_chart in site.data.index.entries %}
{% assign title = helm_chart[0] | capitalize %}
{% assign all_charts = helm_chart[1] | sort: 'created' | reverse %}
{% assign latest_chart = all_charts[0] %}

<h3>
  {% if latest_chart.icon %}
  <img src="{{ latest_chart.icon }}" style="width:7.0em; vertical-align: text-top; float: right;" />
  {% endif %}
  {{ title }}
</h3>

{{ site.description }}

You can add this repository to your local helm configuration as follows :

```bash
$ helm repo add {{ site.repo_name }} {{ site.url }}
$ helm repo update
```

## Charts

[Weaviate-Repo]({{ latest_chart.home }}) \| [Weaviate-Helm-Repo]({{ site.repo_url }})


Download an example `values.yml` (with the default configuration):
```bash
$ export CHART_VERSION="{{ latest_chart.version }}"
$ wget https://raw.githubusercontent.com/weaviate/weaviate-helm/v$CHART_VERSION/weaviate/values.yaml

```

Deploy
```bash
# set the desired Weaviate version compatible with the chart version
export WEAVIATE_VERSION="1.21.2"

$ helm upgrade \
  "weaviate" \
  {{ site.repo_name }}/{{ latest_chart.name }} \
  --version $CHART_VERSION \
  --install \
  --namespace "weaviate" \
  --create-namespace \
  --values ./values.yaml \
  --set "image.tag=$WEAVIATE_VERSION"
```
**NOTE 1**: Check [Weaviate Releases](https://github.com/weaviate/weaviate/releases) for the latest Weaviate version, and the [Weaviate Helm Chart Releases](https://github.com/weaviate/weaviate-helm/releases) to understand which one is compatible with that Weaviate Release. 

**NOTE 2**: Weaviate versions and Chart versions of the this remote repo, are stripped of the leading `v` to be valid [SemVer2](https://semver.org/) versions, though the GitHub releases contain the leading `v`.

Delete deployment:
```bash
$ helm --namespace weaviate uninstall weaviate
```


| Chart Version | Weaviate Version | Date |
|---------------|-------------|------|
{% for chart in all_charts -%}
{% unless chart.version contains "-" -%}
| [{{ chart.version }}]({{ chart.urls[0] }}) | {{ chart.appVersion }} | {{ chart.created | date_to_rfc822 }} | 
{% endunless -%}
{% endfor -%}

{% endfor %}