{{/* Generate the enabled modules config. This can be done a lot nicer once we drop Helm v2 support */}}
{{ define "enabled_modules" }}
  {{- $modules := list -}}
  {{- if or (index .Values "modules" "text2vec-contextionary" "enabled") (index .Values "modules" "text2vec-contextionary" "inferenceUrl") -}}
    {{ $modules = append $modules "text2vec-contextionary" }}
  {{- end -}}
  {{- if or (index .Values "modules" "text2vec-transformers" "enabled") (index .Values "modules" "text2vec-transformers" "inferenceUrl") -}}
    {{ $modules = append $modules "text2vec-transformers" }}
  {{- else if or (index .Values "modules" "text2vec-transformers" "passageQueryServices" "passage" "enabled") (index .Values "modules" "text2vec-transformers" "passageQueryServices" "passage" "inferenceUrl") -}}
    {{ $modules = append $modules "text2vec-transformers" }}
  {{- else if or (index .Values "modules" "text2vec-transformers" "passageQueryServices" "query" "enabled") (index .Values "modules" "text2vec-transformers" "passageQueryServices" "query" "inferenceUrl") -}}
    {{ $modules = append $modules "text2vec-transformers" }}
  {{- end -}}
  {{- if or (index .Values "modules" "text2vec-gpt4all" "enabled") (index .Values "modules" "text2vec-gpt4all" "inferenceUrl") -}}
    {{ $modules = append $modules "text2vec-gpt4all" }}
  {{- end -}}
  {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
    {{ $modules = append $modules "qna-transformers" }}
  {{- end -}}
  {{- if (index .Values "modules" "qna-openai" "enabled") -}}
    {{ $modules = append $modules "qna-openai" }}
  {{- end -}}
  {{- if (index .Values "modules" "generative-openai" "enabled") -}}
    {{ $modules = append $modules "generative-openai" }}
  {{- end -}}
  {{- if (index .Values "modules" "generative-cohere" "enabled") -}}
    {{ $modules = append $modules "generative-cohere" }}
  {{- end -}}
  {{- if (index .Values "modules" "generative-palm" "enabled") -}}
    {{ $modules = append $modules "generative-palm" }}
  {{- end -}}
  {{- if (index .Values "modules" "generative-aws" "enabled") -}}
    {{ $modules = append $modules "generative-aws" }}
  {{- end -}}
  {{- if (index .Values "modules" "generative-anyscale" "enabled") -}}
    {{ $modules = append $modules "generative-anyscale" }}
  {{- end -}}
  {{- if (index .Values "modules" "generative-mistral" "enabled") -}}
    {{ $modules = append $modules "generative-mistral" }}
  {{- end -}}
  {{- if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
    {{ $modules = append $modules "img2vec-neural" }}
  {{- end -}}
  {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
    {{ $modules = append $modules "ner-transformers" }}
  {{- end -}}
  {{- if or (index .Values "modules" "sum-transformers" "enabled") (index .Values "modules" "sum-transformers" "inferenceUrl") -}}
    {{ $modules = append $modules "sum-transformers" }}
  {{- end -}}
  {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
    {{ $modules = append $modules "text-spellcheck" }}
  {{- end -}}
  {{- if or (index .Values "modules" "multi2vec-clip" "enabled") (index .Values "modules" "multi2vec-clip" "inferenceUrl") -}}
    {{ $modules = append $modules "multi2vec-clip" }}
  {{- end -}}
  {{- if or (index .Values "modules" "multi2vec-bind" "enabled") (index .Values "modules" "multi2vec-bind" "inferenceUrl") -}}
    {{ $modules = append $modules "multi2vec-bind" }}
  {{- end -}}
  {{- if (index .Values "modules" "multi2vec-palm" "enabled") -}}
    {{ $modules = append $modules "multi2vec-palm" }}
  {{- end -}}
  {{- if (index .Values "modules" "text2vec-openai" "enabled") -}}
    {{ $modules = append $modules "text2vec-openai" }}
  {{- end -}}
  {{- if (index .Values "modules" "text2vec-huggingface" "enabled") -}}
    {{ $modules = append $modules "text2vec-huggingface" }}
  {{- end -}}
  {{- if (index .Values "modules" "text2vec-cohere" "enabled") -}}
    {{ $modules = append $modules "text2vec-cohere" }}
  {{- end -}}
  {{- if (index .Values "modules" "text2vec-palm" "enabled") -}}
    {{ $modules = append $modules "text2vec-palm" }}
  {{- end -}}
  {{- if (index .Values "modules" "text2vec-jinaai" "enabled") -}}
    {{ $modules = append $modules "text2vec-jinaai" }}
  {{- end -}}
  {{- if (index .Values "modules" "text2vec-aws" "enabled") -}}
    {{ $modules = append $modules "text2vec-aws" }}
  {{- end -}}
  {{- if (index .Values "modules" "text2vec-voyageai" "enabled") -}}
    {{ $modules = append $modules "text2vec-voyageai" }}
  {{- end -}}
  {{- if (index .Values "modules" "ref2vec-centroid" "enabled") -}}
    {{ $modules = append $modules "ref2vec-centroid" }}
  {{- end -}}
  {{- if (index .Values "modules" "reranker-cohere" "enabled") -}}
    {{ $modules = append $modules "reranker-cohere" }}
  {{- end -}}
  {{- if (index .Values "modules" "reranker-transformers" "enabled") -}}
    {{ $modules = append $modules "reranker-transformers" }}
  {{- end -}}
  {{- if (index .Values "backups" "filesystem" "enabled") -}}
    {{ $modules = append $modules "backup-filesystem" }}
  {{- end -}}
  {{- if (index .Values "backups" "s3" "enabled") -}}
    {{ $modules = append $modules "backup-s3" }}
  {{- end -}}
  {{- if (index .Values "backups" "gcs" "enabled") -}}
    {{ $modules = append $modules "backup-gcs" }}
  {{- end -}}
  {{- if (index .Values "backups" "azure" "enabled") -}}
    {{ $modules = append $modules "backup-azure" }}
  {{- end -}}
  {{- if gt (len $modules) 0 -}}
          - name: ENABLE_MODULES
            value: {{ join "," $modules }}
  {{- end -}}
{{- end -}}


{{/* 
Return Image pull secret Names
Usage:
{{- include "image.pullSecrets" (dict "pullSecrets" path_to_image_pullSecrets) | nindent 6 }}
*/}}
{{- define "image.pullSecrets" -}}
  {{- $pullSecrets := list -}}

  {{- if .pullSecrets -}}
    {{- range .pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
Cluster API Secrets
*/}}
{{- define "cluster_api.secret" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace "weaviate-cluster-api-basic-auth" -}}
{{- if $secret -}}
{{/*
   Reusing value of secret if exist
*/}}
username: {{ $secret.data.username }}
password: {{ $secret.data.password }}
{{- else -}}
{{/*
    add new data
*/}}
username: {{ randAlphaNum 32 | b64enc | quote }}
password: {{ randAlphaNum 32 | b64enc | quote }}
{{- end -}}
{{- end -}}


{{/* 
Return PriorityClassName
Usage:
{{- include "pod.priorityClassName" ( dict "global" .Values.path.to.global.priorityClassName "priorityClassName" .Values.path.to.priorityClassName) | nindent 6 }}
*/}}
{{- define "pod.priorityClassName" -}}
  {{- $priorityClassName := "" -}}

  {{- if .global -}}
    {{- $priorityClassName = .global -}}
  {{- else if .priorityClassName -}}
    {{- $priorityClassName = .priorityClassName -}}
  {{- end -}}

  {{- if (not (empty $priorityClassName)) -}}
    {{- printf "priorityClassName: %s" $priorityClassName -}}
  {{- end -}}
{{- end -}}
