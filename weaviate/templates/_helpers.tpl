{{/* Generate the enabled modules config. This can be done a lot nicer once we drop Helm v2 support */}}
{{ define "enabled_modules" }}
  {{- if index .Values "modules" "text2vec-contextionary" "enabled" -}}
    {{- if index .Values "modules" "text2vec-transformers" "enabled" -}}
      {{ fail "cannot have two text2vec-* modules on at the same time" -}}
    {{- end -}}
    {{- if index .Values "modules" "qna-transformers" "enabled" -}}
      {{- if index .Values "modules" "img2vec-keras" "enabled" -}}
        text2vec-contextionary,qna-transformers,img2vec-keras
      {{- else -}}
        text2vec-contextionary,qna-transformers
      {{- end -}}
    {{- elseif index .Values "modules" "img2vec-keras" "enabled" -}}
      {{- if index .Values "modules" "qna-transformers" "enabled" -}}
        text2vec-contextionary,qna-transformers,img2vec-keras
      {{- else -}}
        text2vec-contextionary,img2vec-keras
      {{- end -}}
    {{- else -}}
      text2vec-contextionary
    {{- end -}}
  {{- else -}}
    {{- if index .Values "modules" "text2vec-transformers" "enabled" -}}
      {{- if index .Values "modules" "qna-transformers" "enabled" -}}
        {{- if index .Values "modules" "img2vec-keras" "enabled" -}}
          text2vec-transformers,qna-transformers,img2vec-keras
        {{- else -}}
          text2vec-transformers,qna-transformers
        {{- end -}}
      {{- elseif index .Values "modules" "img2vec-keras" "enabled" -}}
        {{- if index .Values "modules" "qna-transformers" "enabled" -}}
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
