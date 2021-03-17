{{/* Generate the enabled modules config. This can be done a lot nicer once we drop Helm v2 support */}}
{{ define "enabled_modules" }}
  {{- if index .Values "modules" "text2vec-contextionary" "enabled" -}}
    {{- if index .Values "modules" "text2vec-transformers" "enabled" -}}
      {{ fail "cannot have two text2vec-* modules on at the same time" -}}
    {{- end -}}
      text2vec-contextionary
  {{- else -}}
    {{- if index .Values "modules" "text2vec-transformers" "enabled" -}}
      text2vec-transformers
    {{- end -}}
  {{- end -}}
{{- end -}}
