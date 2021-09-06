{{/* Generate the enabled modules config. This can be done a lot nicer once we drop Helm v2 support */}}
{{ define "enabled_modules" }}
  {{- if or (index .Values "modules" "text2vec-contextionary" "enabled") (index .Values "modules" "text2vec-contextionary" "inferenceUrl") -}}
    {{- if or (index .Values "modules" "text2vec-transformers" "enabled") (index .Values "modules" "text2vec-transformers" "inferenceUrl") -}}
      {{ fail "cannot have two text2vec-* modules on at the same time" -}}
    {{- end -}}
    {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
            text2vec-contextionary,qna-transformers,img2vec-neural,text-spellcheck,ner-transformers
          {{- else -}}
            text2vec-contextionary,qna-transformers,img2vec-neural,text-spellcheck
          {{- end -}}
        {{- else -}}
          {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
            text2vec-contextionary,qna-transformers,img2vec-neural,ner-transformers
          {{- else -}}
            text2vec-contextionary,qna-transformers,img2vec-neural
          {{- end -}}
        {{- end -}}
      {{- else -}}
        text2vec-contextionary,qna-transformers
      {{- end -}}
    {{- else if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
            text2vec-contextionary,img2vec-neural,qna-transformers,text-spellcheck,ner-transformers
          {{- else -}}
            text2vec-contextionary,img2vec-neural,qna-transformers,text-spellcheck
          {{- end -}}
        {{- else -}}
          {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
            text2vec-contextionary,img2vec-neural,qna-transformers,ner-transformers
          {{- else -}}
            text2vec-contextionary,img2vec-neural,qna-transformers
          {{- end -}}
        {{- end -}}
      {{- else -}}
        text2vec-contextionary,img2vec-neural
      {{- end -}}
    {{- else if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
            text2vec-contextionary,img2vec-neural,qna-transformers,ner-transformers,text-spellcheck
          {{- else -}}
            text2vec-contextionary,img2vec-neural,qna-transformers,ner-transformers
          {{- end -}}
        {{- else -}}
          text2vec-contextionary,img2vec-neural,qna-transformers
        {{- end -}}
      {{- else -}}
        text2vec-contextionary,img2vec-neural
      {{- end -}}
    {{- else if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
            text2vec-contextionary,qna-transformers,img2vec-neural,ner-transformers,text-spellcheck
          {{- else -}}
            text2vec-contextionary,qna-transformers,img2vec-neural,ner-transformers
          {{- end -}}
        {{- else -}}
          text2vec-contextionary,qna-transformers,img2vec-neural
        {{- end -}}
      {{- else -}}
        text2vec-contextionary,img2vec-neural
      {{- end -}}
    {{- else -}}
      {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
        text2vec-contextionary,text-spellcheck
      {{- else if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
        text2vec-contextionary,ner-transformers
      {{- else -}}
        text2vec-contextionary
      {{- end -}}
    {{- end -}}
  {{- else if or (index .Values "modules" "text2vec-transformers" "enabled") (index .Values "modules" "text2vec-transformers" "inferenceUrl") -}}
    {{- if or (index .Values "modules" "text2vec-transformers" "enabled") (index .Values "modules" "text2vec-transformers" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
            {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
              text2vec-transformers,qna-transformers,img2vec-neural,ner-transformers,text-spellcheck
            {{- else -}}
              text2vec-transformers,qna-transformers,img2vec-neural,ner-transformers
            {{- end -}}
          {{- else -}}
            {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
              text2vec-transformers,qna-transformers,img2vec-neural,text-spellcheck
            {{- else -}}
              text2vec-transformers,qna-transformers,img2vec-neural
            {{- end -}}
          {{- end -}}
        {{- else -}}
          text2vec-transformers,qna-transformers
        {{- end -}}
      {{- else if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
            {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
              text2vec-transformers,qna-transformers,img2vec-neural,ner-transformers,text-spellcheck
            {{- else -}}
              text2vec-transformers,qna-transformers,img2vec-neural,ner-transformers
            {{- end -}}
          {{- else -}}
            {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
              text2vec-transformers,qna-transformers,img2vec-neural,text-spellcheck
            {{- else -}}
              text2vec-transformers,qna-transformers,img2vec-neural
            {{- end -}}
          {{- end -}}
        {{- else -}}
          text2vec-transformers,img2vec-neural
        {{- end -}}
      {{- else if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
            {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
              text2vec-transformers,qna-transformers,img2vec-neural,text-spellcheck,ner-transformers
            {{- else -}}
              text2vec-transformers,qna-transformers,img2vec-neural,text-spellcheck
            {{- end -}}
          {{- else -}}
            text2vec-transformers,qna-transformers,img2vec-neural
          {{- end -}}
        {{- else -}}
          text2vec-transformers,img2vec-neural
        {{- end -}}
      {{- else if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
          {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
            {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
              text2vec-transformers,qna-transformers,img2vec-neural,text-spellcheck,ner-transformers
            {{- else -}}
              text2vec-transformers,qna-transformers,img2vec-neural,text-spellcheck
            {{- end -}}
          {{- else -}}
            text2vec-transformers,qna-transformers,img2vec-neural
          {{- end -}}
        {{- else -}}
          text2vec-transformers,qna-transformers
        {{- end -}}
      {{- else -}}
        {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
          text2vec-transformers,text-spellcheck
        {{- else if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
          text2vec-transformers,ner-transformers
        {{- else -}}
          text2vec-transformers
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- else if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
    {{- if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
          qna-transformers,img2vec-neural,text-spellcheck,ner-transformers
        {{- else -}}
          qna-transformers,img2vec-neural,text-spellcheck
        {{- end -}}
      {{- else -}}
        {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
          qna-transformers,img2vec-neural,ner-transformers
        {{- else -}}
          qna-transformers,img2vec-neural
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
        qna-transformers,ner-transformers
      {{- else if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
        qna-transformers,text-spellcheck
      {{- else -}}
        qna-transformers
      {{- end -}}  
    {{- end -}}
  {{- else if or (index .Values "modules" "img2vec-neural" "enabled") (index .Values "modules" "img2vec-neural" "inferenceUrl") -}}
    {{- if or (index .Values "modules" "qna-transformers" "enabled") (index .Values "modules" "qna-transformers" "inferenceUrl") -}}
      {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
        {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
          img2vec-neural,qna-transformers,text-spellcheck,ner-transformers
        {{- else -}}
          img2vec-neural,qna-transformers,text-spellcheck
        {{- end -}}
      {{- else -}}
        {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
          img2vec-neural,qna-transformers,ner-transformers
        {{- else -}}
          img2vec-neural,qna-transformers
        {{- end -}}
      {{- end -}}
    {{- else -}}
      {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
        img2vec-neural,ner-transformers
      {{- else if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
        img2vec-neural,text-spellcheck
      {{- else -}}
        img2vec-neural
      {{- end -}}
    {{- end -}}
  {{- else if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
    {{- if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
      text-spellcheck,ner-transformers
    {{- else -}}
      text-spellcheck
    {{- end -}}
  {{- else if or (index .Values "modules" "ner-transformers" "enabled") (index .Values "modules" "ner-transformers" "inferenceUrl") -}}
    {{- if or (index .Values "modules" "text-spellcheck" "enabled") (index .Values "modules" "text-spellcheck" "inferenceUrl") -}}
      ner-transformers,text-spellcheck
    {{- else -}}
      ner-transformers
    {{- end -}}
  {{- end -}}
{{- end -}}
