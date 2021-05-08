{{/* Generate the enabled modules config. This can be done a lot nicer once we drop Helm v2 support */}}
{{ define "enabled_modules" }}
  {{- if or (index .Values "modules" "text2vec-contextionary" "enabled") (index .Values "modules" "text2vec-contextionary" "inferenceUrl") -}}
    {{- if or (index .Values "modules" "text2vec-transformers" "enabled") (index .Values "modules" "text2vec-transformers" "inferenceUrl") -}}
      {{ fail "cannot have two text2vec-* modules on at the same time" -}}
    {{- end -}}
    {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "img2vec-keras" "enabled") (index .Values "modules" "img2vec-keras" "inferenceUrl") -}}
        text2vec-contextionary,qna-transformers,img2vec-keras
      {{- else -}}
        text2vec-contextionary,qna-transformers
      {{- end -}}
    {{- else if or (index .Values "modules" "img2vec-keras" "enabled") (index .Values "modules" "img2vec-keras" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
        text2vec-contextionary,qna-transformers,img2vec-keras
      {{- else -}}
        text2vec-contextionary,img2vec-keras
      {{- end -}}
    {{- else -}}
      text2vec-contextionary
    {{- end -}}
  {{- else -}}
    {{- if or (index .Values "modules" "text2vec-transformers" "enabled") (index .Values "modules" "text2vec-transformers" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "img2vec-keras" "enabled") (index .Values "modules" "img2vec-keras" "inferenceUrl") -}}
          text2vec-transformers,qna-transformers,img2vec-keras
        {{- else -}}
          text2vec-transformers,qna-transformers
        {{- end -}}
      {{- else if or (index .Values "modules" "img2vec-keras" "enabled") (index .Values "modules" "img2vec-keras" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
          text2vec-transformers,qna-transformers,img2vec-keras
        {{- else -}}
          text2vec-transformers,img2vec-keras
        {{- end -}}
      {{- else -}}
        text2vec-transformers
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
