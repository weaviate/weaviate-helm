#!/bin/bash

set -eou pipefail

COUNTER=0

function check_modules() {
  local helm_settings=$1
  local expected_value=$2

  check_setting_has_value "$helm_settings" "ENABLE_MODULES" "$expected_value"
}

function check_setting_has_value() {
  local helm_settings=$1
  local setting=$2
  local expected_value=$3

  echo "$COUNTER: Test if '$setting' has value '$expected_value' using: '$helm_settings' settings"
  let COUNTER=COUNTER+1
  helm template $helm_settings weaviate . > out.yml
  res=$(grep -F -C 1 "${setting}" < ../weaviate/out.yml)
  if [[ $res != *$expected_value* ]]
  then
    echo "error: '$expected_value' was not found"
    exit 1
  fi
  rm -fr ../weaviate/out.yml
}

function check_no_setting() {
  local helm_settings=$1
  local setting=$2

  echo "$COUNTER: Test if '$setting' is absent using: '$helm_settings' settings"
  let COUNTER=COUNTER+1
  helm template $helm_settings weaviate . > out.yml
  if grep -Fq "$setting" ../weaviate/out.yml; then
    echo "error: '$setting' was found"
    exit 1
  fi
  rm -fr ../weaviate/out.yml
}

function check_string_existence() {
  local helm_settings=$1
  local expected_value=$2

  echo "$COUNTER: Test if '$expected_value' is present using: '$helm_settings' settings"
  let COUNTER=COUNTER+1
  helm template $helm_settings weaviate . > out.yml
  res=$(grep -F "${expected_value}" < ../weaviate/out.yml)
  if [[ $res != *$expected_value* ]]
  then
    echo "error: '$expected_value' was not found"
    exit 1
  fi
  rm -fr ../weaviate/out.yml
}

function check_creates_template() {
  local helm_settings=$1

  helm template $helm_settings weaviate . > out.yml
  rm -fr ../weaviate/out.yml
}

(
  cd weaviate
  VERSION=$( grep 'version:' < Chart.yaml | awk '{ print $2 }')
  echo "Running tests for version $VERSION"

  helm dependencies build
  helm lint .

  check_no_setting "" "name: ENABLE_MODULES"
  check_setting_has_value "" "name: DEFAULT_VECTORIZER_MODULE" "value: none"
  check_no_setting "" "serviceAccountName"
  check_setting_has_value "--set serviceAccountName=my-service-account-test" "serviceAccountName" "my-service-account-test"
  check_setting_has_value "--set modules.default_vectorizer_module=text2vec-openai" "name: DEFAULT_VECTORIZER_MODULE" "value: text2vec-openai"
  check_modules "--set modules.text2vec-contextionary.enabled=true" "value: text2vec-contextionary"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.qna-transformers.enabled=true" "value: qna-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.img2vec-neural.enabled=true" "value: img2vec-neural"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true" "value: text2vec-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.passageQueryServices.passage.enabled=true --set modules.text2vec-transformers.passageQueryServices.query.enabled=true" "value: text2vec-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true" "value: text2vec-transformers,qna-transformers,img2vec-neural"
  check_modules "--set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true" "value: qna-transformers,img2vec-neural"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.qna-transformers.enabled=true --set modules.img2vec-neural.enabled=true" "value: qna-transformers,img2vec-neural"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=true" "value: text2vec-transformers,qna-transformers,img2vec-neural,ner-transformers,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=true" "value: text2vec-contextionary,qna-transformers,img2vec-neural,ner-transformers,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text-spellcheck.enabled=true" "value: text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.ner-transformers.enabled=true" "value: ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.ner-transformers.enabled=true --set modules.text-spellcheck.enabled=true" "value: ner-transformers,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=false" "value: text2vec-contextionary,qna-transformers,img2vec-neural,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=false --set modules.ner-transformers.enabled=true" "value: text2vec-contextionary,qna-transformers,img2vec-neural,ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=false" "value: text2vec-transformers,qna-transformers,img2vec-neural,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=false --set modules.ner-transformers.enabled=true" "value: text2vec-transformers,qna-transformers,img2vec-neural,ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=false" "value: qna-transformers,img2vec-neural,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=false --set modules.ner-transformers.enabled=true" "value: qna-transformers,img2vec-neural,ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=false --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=false" "value: img2vec-neural,text-spellcheck"
  check_modules "--set modules.ner-transformers.enabled=true --set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=false --set modules.text-spellcheck.enabled=false" "value: img2vec-neural,ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=false" "value: qna-transformers,text-spellcheck"
  check_modules "--set modules.ner-transformers.enabled=true --set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=false" "value: qna-transformers,ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.text-spellcheck.enabled=true" "value: text2vec-contextionary,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.ner-transformers.enabled=true" "value: text2vec-contextionary,ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.text-spellcheck.enabled=true" "value: text2vec-transformers,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.ner-transformers.enabled=true" "value: text2vec-transformers,ner-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=true" "value: text2vec-transformers,qna-transformers,ner-transformers,text-spellcheck"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.multi2vec-clip.enabled=true" "value: multi2vec-clip"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=true --set modules.multi2vec-clip.enabled=true" "value: text2vec-transformers,qna-transformers,ner-transformers,text-spellcheck,multi2vec-clip"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=true --set modules.multi2vec-clip.enabled=true --set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.apiKey=apiKey" "value: text2vec-transformers,qna-transformers,ner-transformers,text-spellcheck,multi2vec-clip,text2vec-openai"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=true --set modules.text-spellcheck.enabled=true --set modules.ner-transformers.enabled=true --set modules.multi2vec-clip.enabled=true --set modules.text2vec-openai.enabled=true" "value: text2vec-transformers,qna-transformers,ner-transformers,text-spellcheck,multi2vec-clip,text2vec-openai"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=false --set modules.text-spellcheck.enabled=false --set modules.ner-transformers.enabled=false --set modules.multi2vec-clip.enabled=false --set modules.text2vec-openai.enabled=true" "value: text2vec-openai"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=false --set modules.img2vec-neural.enabled=false --set modules.qna-transformers.enabled=false --set modules.text-spellcheck.enabled=false --set modules.ner-transformers.enabled=false --set modules.multi2vec-clip.enabled=false --set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.apiKey=apiKey" "value: text2vec-openai"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.sum-transformers.enabled=true" "value: text2vec-contextionary,sum-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.ref2vec-centroid.enabled=true" "value: text2vec-contextionary,ref2vec-centroid"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.text2vec-cohere.enabled=true" "value: text2vec-contextionary,text2vec-cohere"
  check_modules "--set modules.text2vec-cohere.enabled=true" "value: text2vec-cohere"
  check_modules "--set modules.text2vec-huggingface.enabled=true" "value: text2vec-huggingface"
  check_modules "--set modules.ref2vec-centroid.enabled=true" "value: ref2vec-centroid"
  check_modules "--set modules.qna-openai.enabled=true" "value: qna-openai"
  check_modules "--set modules.qna-openai.enabled=true --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true" "value: qna-transformers,qna-openai,img2vec-neural"
  check_modules "--set modules.qna-openai.enabled=true --set modules.qna-openai.apiKey=apiKey --set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.apiKey=apiKey" "value: qna-openai,text2vec-openai"
  check_modules "--set modules.generative-openai.enabled=true" "value: generative-openai"
  check_modules "--set modules.qna-openai.enabled=true --set modules.qna-openai.apiKey=apiKey --set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.apiKey=apiKey --set modules.generative-openai.enabled=true --set modules.generative-openai.apiKey=apiKey" "value: qna-openai,generative-openai,text2vec-openai"
  check_modules "--set modules.qna-openai.enabled=true --set modules.qna-openai.apiKey=apiKey --set modules.generative-openai.enabled=true --set modules.generative-openai.apiKey=apiKey" "value: qna-openai,generative-openai"
  check_modules "--set modules.generative-cohere.enabled=true" "value: generative-cohere"
  check_modules "--set modules.reranker-cohere.enabled=true" "value: reranker-cohere"
  check_modules "--set modules.multi2vec-cohere.enabled=true" "value: multi2vec-cohere"
  check_modules "--set modules.text2vec-cohere.enabled=true --set modules.text2vec-cohere.apiKey=apiKey --set modules.generative-cohere.enabled=true --set modules.generative-cohere.apiKey=apiKey" "value: generative-cohere,text2vec-cohere"
  check_modules "--set modules.text2vec-cohere.enabled=true --set modules.text2vec-cohere.apiKey=apiKey --set modules.generative-cohere.enabled=true --set modules.generative-cohere.apiKey=apiKey --set modules.reranker-cohere.enabled=true --set modules.reranker-cohere.apiKey=apiKey" "value: generative-cohere,text2vec-cohere,reranker-cohere"
  check_modules "--set modules.text2vec-cohere.enabled=true --set modules.text2vec-cohere.apiKey=apiKey --set modules.reranker-cohere.enabled=true --set modules.reranker-cohere.apiKey=apiKey" "value: text2vec-cohere,reranker-cohere"
  check_modules "--set modules.text2vec-cohere.enabled=true --set modules.text2vec-cohere.apiKey=apiKey --set modules.multi2vec-cohere.enabled=true --set modules.multi2vec-cohere.apiKey=apiKey" "value: multi2vec-cohere,text2vec-cohere"
  check_modules "--set modules.generative-cohere.enabled=true --set modules.generative-cohere.apiKey=apiKey" "value: generative-cohere"
  check_modules "--set modules.text2vec-palm.enabled=true" "value: text2vec-palm"
  check_modules "--set modules.generative-palm.enabled=true" "value: generative-palm"
  check_modules "--set modules.text2vec-palm.enabled=true --set modules.text2vec-palm.apiKey=apiKey --set modules.generative-palm.enabled=true --set modules.generative-palm.apiKey=apiKey" "value: generative-palm,text2vec-palm"
  check_modules "--set modules.generative-palm.enabled=true --set modules.generative-palm.apiKey=apiKey" "value: generative-palm"
  check_modules "--set modules.text2vec-google.enabled=true" "value: text2vec-google"
  check_modules "--set modules.generative-google.enabled=true" "value: generative-google"
  check_modules "--set modules.text2vec-google.enabled=true --set modules.text2vec-google.apiKey=apiKey --set modules.generative-google.enabled=true --set modules.generative-google.apiKey=apiKey" "value: generative-google,text2vec-google"
  check_modules "--set modules.generative-google.enabled=true --set modules.generative-google.apiKey=apiKey" "value: generative-google"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.reranker-transformers.enabled=true" "value: reranker-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.text-spellcheck.enabled=true --set modules.reranker-transformers.enabled=true" "value: text2vec-contextionary,text-spellcheck,reranker-transformers"
  check_modules "--set modules.text2vec-gpt4all.enabled=true" "value: text2vec-gpt4all"
  check_modules "--set modules.text2vec-gpt4all.enabled=true --set modules.text-spellcheck.enabled=true" "value: text2vec-gpt4all,text-spellcheck"
  check_modules "--set modules.text2vec-model2vec.enabled=true" "value: text2vec-model2vec"
  check_modules "--set modules.text2vec-model2vec.enabled=true --set modules.text-spellcheck.enabled=true" "value: text2vec-model2vec,text-spellcheck"
  check_modules "--set modules.multi2vec-bind.enabled=true" "value: multi2vec-bind"
  check_modules "--set modules.multi2vec-bind.enabled=true --set modules.text-spellcheck.enabled=true" "value: text-spellcheck,multi2vec-bind"
  check_modules "--set modules.text2vec-jinaai.enabled=true" "value: text2vec-jinaai"
  check_modules "--set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=apiKey" "value: text2vec-jinaai"
  check_modules "--set modules.reranker-jinaai.enabled=true" "value: reranker-jinaai"
  check_modules "--set modules.reranker-jinaai.enabled=true --set modules.reranker-jinaai.apiKey=apiKey" "value: reranker-jinaai"
  check_modules "--set modules.multi2vec-jinaai.enabled=true" "value: multi2vec-jinaai"
  check_modules "--set modules.multi2vec-jinaai.enabled=true --set modules.multi2vec-jinaai.apiKey=apiKey" "value: multi2vec-jinaai"
  check_modules "--set modules.multi2multivec-jinaai.enabled=true" "value: multi2multivec-jinaai"
  check_modules "--set modules.multi2multivec-jinaai.enabled=true --set modules.multi2multivec-jinaai.apiKey=apiKey" "value: multi2multivec-jinaai"
  check_modules "--set modules.text2multivec-jinaai.enabled=true" "value: text2multivec-jinaai"
  check_modules "--set modules.text2multivec-jinaai.enabled=true --set modules.text2multivec-jinaai.apiKey=apiKey" "value: text2multivec-jinaai"
  check_modules "--set modules.text2colbert-jinaai.enabled=true" "value: text2colbert-jinaai"
  check_modules "--set modules.text2colbert-jinaai.enabled=true --set modules.text2colbert-jinaai.apiKey=apiKey" "value: text2colbert-jinaai"
  check_modules "--set modules.text2vec-aws.enabled=true" "value: text2vec-aws"
  check_modules "--set modules.multi2vec-aws.enabled=true" "value: multi2vec-aws"
  check_modules "--set modules.generative-aws.enabled=true" "value: generative-aws"
  check_modules "--set modules.text2vec-aws.enabled=true --set modules.generative-aws.enabled=true" "value: generative-aws,text2vec-aws"
  check_modules "--set modules.multi2vec-aws.enabled=true --set modules.generative-aws.enabled=true" "value: generative-aws,multi2vec-aws"
  check_modules "--set modules.generative-anyscale.enabled=true" "value: generative-anyscale"
  check_modules "--set modules.generative-anyscale.enabled=true --set modules.generative-anyscale.apiKey=apiKey" "value: generative-anyscale"
  check_modules "--set modules.text2vec-voyageai.enabled=true" "value: text2vec-voyageai"
  check_modules "--set modules.multi2vec-voyageai.enabled=true" "value: multi2vec-voyageai"
  check_modules "--set modules.generative-mistral.enabled=true" "value: generative-mistral"
  check_modules "--set modules.generative-mistral.enabled=true --set modules.generative-mistral.apiKey=apiKey" "value: generative-mistral"
  check_modules "--set modules.multi2vec-palm.enabled=true" "value: multi2vec-palm"
  check_modules "--set modules.multi2vec-palm.enabled=true --set modules.multi2vec-palm.apiKey=apiKey --set modules.generative-palm.enabled=true --set modules.generative-palm.apiKey=apiKey" "value: generative-palm,multi2vec-palm"
  check_modules "--set modules.reranker-voyageai.enabled=true" "value: reranker-voyageai"
  check_modules "--set modules.reranker-voyageai.enabled=true --set modules.reranker-voyageai.apiKey=apiKey" "value: reranker-voyageai"
  check_modules "--set modules.multi2vec-voyageai.enabled=true --set modules.multi2vec-voyageai.apiKey=apiKey" "value: multi2vec-voyageai"
  check_modules "--set modules.text2vec-voyageai.enabled=true --set modules.text2vec-voyageai.apiKey=apiKey --set modules.reranker-voyageai.enabled=true --set modules.reranker-voyageai.apiKey=apiKey" "value: text2vec-voyageai,reranker-voyageai"
  check_modules "--set modules.multi2vec-voyageai.enabled=true --set modules.multi2vec-voyageai.apiKey=apiKey --set modules.reranker-voyageai.enabled=true --set modules.reranker-voyageai.apiKey=apiKey" "value: multi2vec-voyageai,reranker-voyageai"
  check_modules "--set modules.text2vec-voyageai.enabled=true --set modules.text2vec-voyageai.apiKey=apiKey --set modules.reranker-voyageai.enabled=true --set modules.reranker-voyageai.apiKey=apiKey --set modules.multi2vec-voyageai.enabled=true --set modules.multi2vec-voyageai.apiKey=apiKey" "value: multi2vec-voyageai,text2vec-voyageai,reranker-voyageai"
  check_modules "--set modules.text2vec-ollama.enabled=true" "value: text2vec-ollama"
  check_modules "--set modules.generative-ollama.enabled=true" "value: generative-ollama"
  check_modules "--set modules.generative-ollama.enabled=true --set modules.text2vec-ollama.enabled=true" "value: generative-ollama,text2vec-ollama"
  check_modules "--set modules.text2vec-octoai.enabled=true" "value: text2vec-octoai"
  check_modules "--set modules.generative-octoai.enabled=true" "value: generative-octoai"
  check_modules "--set offload.s3.enabled=true" "value: offload-s3"
  check_modules "--set usage.s3.enabled=true" "value: usage-s3"
  check_modules "--set usage.gcs.enabled=true" "value: usage-gcs"
  check_modules "--set modules.generative-anthropic.enabled=true" "value: generative-anthropic"
  check_modules "--set modules.generative-anthropic.enabled=true --set modules.generative-anthropic.apiKey=apiKey" "value: generative-anthropic"
  check_modules "--set modules.generative-friendliai.enabled=true" "value: generative-friendliai"
  check_modules "--set modules.generative-friendliai.enabled=true --set modules.generative-friendliai.token=token" "value: generative-friendliai"
  check_modules "--set modules.text2vec-databricks.enabled=true" "value: text2vec-databricks"
  check_modules "--set modules.generative-databricks.enabled=true" "value: generative-databricks"
  check_modules "--set modules.text2vec-mistral.enabled=true" "value: text2vec-mistral"
  check_modules "--set modules.generative-nvidia.enabled=true" "value: generative-nvidia"
  check_modules "--set modules.reranker-nvidia.enabled=true" "value: reranker-nvidia"
  check_modules "--set modules.multi2vec-nvidia.enabled=true" "value: multi2vec-nvidia"
  check_modules "--set modules.text2vec-nvidia.enabled=true --set modules.text2vec-nvidia.apiKey=apiKey --set modules.generative-nvidia.enabled=true --set modules.generative-nvidia.apiKey=apiKey" "value: generative-nvidia,text2vec-nvidia"
  check_modules "--set modules.text2vec-nvidia.enabled=true --set modules.text2vec-nvidia.apiKey=apiKey --set modules.generative-nvidia.enabled=true --set modules.generative-nvidia.apiKey=apiKey --set modules.reranker-nvidia.enabled=true --set modules.reranker-nvidia.apiKey=apiKey" "value: generative-nvidia,text2vec-nvidia,reranker-nvidia"
  check_modules "--set modules.text2vec-nvidia.enabled=true --set modules.text2vec-nvidia.apiKey=apiKey --set modules.reranker-nvidia.enabled=true --set modules.reranker-nvidia.apiKey=apiKey" "value: text2vec-nvidia,reranker-nvidia"
  check_modules "--set modules.text2vec-nvidia.enabled=true --set modules.text2vec-nvidia.apiKey=apiKey --set modules.multi2vec-nvidia.enabled=true --set modules.multi2vec-nvidia.apiKey=apiKey" "value: multi2vec-nvidia,text2vec-nvidia"
  check_modules "--set modules.generative-nvidia.enabled=true --set modules.generative-nvidia.apiKey=apiKey" "value: generative-nvidia"
  check_modules "--set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.azureApiKey=azureApiKey" "value: text2vec-openai"
  check_modules "--set modules.qna-openai.enabled=true --set modules.qna-openai.azureApiKey=azureApiKey" "value: qna-openai"
  check_modules "--set modules.generative-openai.enabled=true --set modules.generative-openai.azureApiKey=azureApiKey" "value: generative-openai"
  check_modules "--set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.azureApiKey=azureApiKey --set modules.qna-openai.enabled=true --set modules.qna-openai.azureApiKey=azureApiKey --set modules.generative-openai.enabled=true --set modules.generative-openai.azureApiKey=azureApiKey" "value: qna-openai,generative-openai,text2vec-openai"
  check_modules "--set modules.generative-xai.enabled=true" "value: generative-xai"
  check_modules "--set modules.generative-xai.enabled=true --set modules.generative-xai.apiKey=apiKey" "value: generative-xai"
  check_string_existence "--set modules.generative-xai.enabled=true --set modules.generative-xai.apiKey=apiKey" "name: XAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.azureApiKey=azureApiKey" "name: AZURE_APIKEY"
  check_string_existence "--set modules.qna-openai.enabled=true --set modules.qna-openai.azureApiKey=azureApiKey" "name: AZURE_APIKEY"
  check_string_existence "--set modules.generative-openai.enabled=true --set modules.generative-openai.azureApiKey=azureApiKey" "name: AZURE_APIKEY"
  check_string_existence "--set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=jinaaiApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2colbert-jinaai.enabled=true --set modules.text2colbert-jinaai.apiKey=jinaaiApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2multivec-jinaai.enabled=true --set modules.text2multivec-jinaai.apiKey=jinaaiApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.multi2vec-jinaai.enabled=true --set modules.multi2vec-jinaai.apiKey=jinaaiApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.multi2multivec-jinaai.enabled=true --set modules.multi2multivec-jinaai.apiKey=jinaaiApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set grpcService.enabled=true" "containerPort: 50051"
  check_string_existence "--set grpcService.enabled=true --set grpcService.name=weaviate-grpc-service-custom-name" "name: weaviate-grpc-service-custom-name"
  check_string_existence "--set grpcService.name=weaviate-grpc-defult-service-custom-name" "name: weaviate-grpc-defult-service-custom-name"
  check_string_existence "--set modules.text2vec-aws.enabled=true --set modules.text2vec-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.text2vec-aws.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_ACCESS_KEY_ID"
  check_string_existence "--set modules.text2vec-aws.enabled=true --set modules.text2vec-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.text2vec-aws.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_SECRET_ACCESS_KEY"
  check_string_existence "--set modules.multi2vec-aws.enabled=true --set modules.multi2vec-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.multi2vec-aws.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_ACCESS_KEY_ID"
  check_string_existence "--set modules.multi2vec-aws.enabled=true --set modules.multi2vec-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.multi2vec-aws.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_SECRET_ACCESS_KEY"
  check_string_existence "--set modules.generative-aws.enabled=true --set modules.generative-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.generative-aws.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_ACCESS_KEY_ID"
  check_string_existence "--set modules.generative-aws.enabled=true --set modules.generative-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.generative-aws.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_SECRET_ACCESS_KEY"
  check_string_existence "--set modules.generative-aws.enabled=true --set modules.generative-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.generative-aws.secrets.AWS_SECRET_ACCESS_KEY=secret --set modules.text2vec-aws.enabled=true" "name: AWS_ACCESS_KEY_ID"
  check_string_existence "--set modules.generative-aws.enabled=true --set modules.generative-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.generative-aws.secrets.AWS_SECRET_ACCESS_KEY=secret --set modules.text2vec-aws.enabled=true" "name: AWS_SECRET_ACCESS_KEY"
  check_string_existence "--set offload.s3.enabled=true --set offload.s3.secrets.AWS_ACCESS_KEY_ID=key --set offload.s3.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_ACCESS_KEY_ID"
  check_string_existence "--set offload.s3.enabled=true --set offload.s3.secrets.AWS_ACCESS_KEY_ID=key --set offload.s3.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_SECRET_ACCESS_KEY"
  check_string_existence "--set backups.s3.enabled=true --set modules.generative-aws.enabled=true --set modules.generative-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.generative-aws.secrets.AWS_SECRET_ACCESS_KEY=secret --set modules.text2vec-aws.enabled=true" "name: weaviate-aws"
  check_string_existence "--set backups.s3.enabled=true --set modules.generative-aws.enabled=true --set backups.s3.secrets.AWS_ACCESS_KEY_ID=key --set backups.s3.secrets.AWS_SECRET_ACCESS_KEY=secret --set modules.text2vec-aws.enabled=true" "name: backup-s3"
  check_string_existence "--set modules.text2vec-aws.enabled=true --set modules.text2vec-aws.envSecrets.AWS_ACCESS_KEY_ID=key --set modules.text2vec-aws.envSecrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_ACCESS_KEY_ID"
  check_string_existence "--set modules.text2vec-aws.enabled=true --set modules.text2vec-aws.envSecrets.AWS_ACCESS_KEY_ID=key --set modules.text2vec-aws.envSecrets.AWS_SECRET_ACCESS_KEY=secret" "name: AWS_SECRET_ACCESS_KEY"
  check_string_existence "--set modules.generative-anyscale.enabled=true --set modules.generative-anyscale.apiKey=apiKey" "name: ANYSCALE_APIKEY"
  check_string_existence "--set modules.text2vec-voyageai.enabled=true --set modules.text2vec-voyageai.apiKey=voyageaiApiKey" "name: VOYAGEAI_APIKEY"
  check_string_existence "--set modules.generative-mistral.enabled=true --set modules.generative-mistral.apiKey=apiKey" "name: MISTRAL_APIKEY"
  check_string_existence "--set modules.multi2vec-palm.enabled=true --set modules.multi2vec-palm.apiKey=palmApiKey" "name: PALM_APIKEY"
  check_string_existence "--set modules.reranker-voyageai.enabled=true --set modules.reranker-voyageai.apiKey=voyageaiApiKey" "name: VOYAGEAI_APIKEY"
  check_string_existence "--set modules.text2vec-voyageai.enabled=true --set modules.text2vec-voyageai.apiKey=voyageaiApiKey --set modules.reranker-voyageai.enabled=true --set modules.reranker-voyageai.apiKey=voyageaiApiKey" "name: VOYAGEAI_APIKEY"
  check_string_existence "--set modules.text2vec-octoai.enabled=true --set modules.text2vec-octoai.apiKey=octoaiApiKey" "name: OCTOAI_APIKEY"
  check_string_existence "--set modules.generative-octoai.enabled=true --set modules.generative-octoai.apiKey=octoaiApiKey" "name: OCTOAI_APIKEY"
  check_string_existence "--set modules.generative-octoai.enabled=true --set modules.generative-octoai.apiKey=octoaiApiKey --set modules.text2vec-octoai.enabled=true --set modules.text2vec-octoai.apiKey=octoaiApiKey" "name: OCTOAI_APIKEY"
  check_string_existence "--set offload.s3.enabled=true --set modules.generative-aws.enabled=true --set modules.generative-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.generative-aws.secrets.AWS_SECRET_ACCESS_KEY=secret --set modules.text2vec-aws.enabled=true" "name: weaviate-aws"
  check_string_existence "--set offload.s3.enabled=true --set modules.generative-aws.enabled=true --set modules.generative-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.generative-aws.secrets.AWS_SECRET_ACCESS_KEY=secret --set modules.multi2vec-aws.enabled=true" "name: weaviate-aws"
  check_string_existence "--set offload.s3.enabled=true --set modules.generative-aws.enabled=true --set offload.s3.secrets.AWS_ACCESS_KEY_ID=key --set offload.s3.secrets.AWS_SECRET_ACCESS_KEY=secret --set modules.text2vec-aws.enabled=true" "name: weaviate-aws"
  check_string_existence "--set modules.multi2vec-aws.enabled=true --set modules.multi2vec-aws.secrets.AWS_ACCESS_KEY_ID=key --set modules.multi2vec-aws.secrets.AWS_SECRET_ACCESS_KEY=secret" "name: weaviate-aws"
  check_string_existence "--set offload.s3.enabled=true --set modules.generative-aws.enabled=true --set offload.s3.envSecrets.AWS_ACCESS_KEY_ID=key-secret-name --set offload.s3.envSecrets.AWS_SECRET_ACCESS_KEY=secret --set modules.text2vec-aws.enabled=true" "name: key-secret-name"
  check_string_existence "--set offload.s3.enabled=true --set modules.generative-aws.enabled=true --set offload.s3.envconfig.OFFLOAD_S3_BUCKET=/custom-bucket --set modules.text2vec-aws.enabled=true" "name: OFFLOAD_S3_BUCKET"
  check_string_existence "--set offload.s3.enabled=true --set modules.generative-aws.enabled=true --set offload.s3.envconfig.OFFLOAD_S3_PATH=/custom-path --set modules.text2vec-aws.enabled=true" "name: OFFLOAD_S3_PATH"
  check_string_existence "--set usage.s3.enabled=true" "name: USAGE_S3_BUCKET"
  check_string_existence "--set usage.gcs.enabled=true" "name: USAGE_GCS_BUCKET"
  check_string_existence "--set usage.s3.enabled=true --set usage.s3.envconfig.USAGE_S3_PREFIX=billing" "name: USAGE_S3_PREFIX"
  check_string_existence "--set usage.gcs.enabled=true --set usage.gcs.envconfig.USAGE_GCS_PREFIX=gcs/billing" "name: USAGE_GCS_PREFIX"
  check_string_existence "--set usage.s3.enabled=true --set usage.s3.envconfig.USAGE_SCRAPE_INTERVAL=2h" "name: USAGE_SCRAPE_INTERVAL"
  check_string_existence "--set usage.gcs.enabled=true --set usage.gcs.envconfig.USAGE_SCRAPE_INTERVAL=30s" "name: USAGE_SCRAPE_INTERVAL"
  check_string_existence "--set initContainers.ensureFileOwnershipContainer.enabled=true --set containerSecurityContext.runAsUser=1000 --set containerSecurityContext.fsGroup=2000" "name: ensure-file-ownership"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.generative-anthropic.enabled=true --set modules.generative-anthropic.apiKey=azureApiKey" "name: ANTHROPIC_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.text2colbert-jinaai.enabled=true --set modules.text2colbert-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.text2multivec-jinaai.enabled=true --set modules.text2multivec-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.reranker-jinaai.enabled=true --set modules.reranker-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.reranker-jinaai.enabled=true --set modules.reranker-jinaai.apiKey=JinaAIApiKey --set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.reranker-jinaai.enabled=true --set modules.reranker-jinaai.apiKey=JinaAIApiKey --set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=JinaAIApiKey --set modules.text2colbert-jinaai.enabled=true --set modules.text2colbert-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.reranker-jinaai.enabled=true --set modules.reranker-jinaai.apiKey=JinaAIApiKey --set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=JinaAIApiKey --set modules.text2multivec-jinaai.enabled=true --set modules.text2multivec-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.multi2vec-jinaai.enabled=true --set modules.multi2vec-jinaai.apiKey=JinaAIApiKey --set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.multi2vec-jinaai.enabled=true --set modules.multi2vec-jinaai.apiKey=JinaAIApiKey --set modules.reranker-jinaai.enabled=true --set modules.reranker-jinaai.apiKey=JinaAIApiKey --set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.multi2vec-jinaai.enabled=true --set modules.multi2vec-jinaai.apiKey=JinaAIApiKey --set modules.multi2multivec-jinaai.apiKey=JinaAIApiKey --set modules.text2vec-jinaai.enabled=true --set modules.text2vec-jinaai.apiKey=JinaAIApiKey" "name: JINAAI_APIKEY"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.generative-friendliai.enabled=true --set modules.generative-friendliai.token=FriendliToken" "name: FRIENDLI_TOKEN"
  check_string_existence "--set modules.text2vec-databricks.enabled=true --set modules.text2vec-databricks.token=databricksToken" "name: DATABRICKS_TOKEN"
  check_string_existence "--set modules.generative-databricks.enabled=true --set modules.generative-databricks.token=databricksToken" "name: DATABRICKS_TOKEN"
  check_string_existence "--set modules.generative-databricks.enabled=true --set modules.generative-databricks.token=databricksToken --set modules.text2vec-databricks.enabled=true --set modules.text2vec-databricks.token=databricksToken" "name: DATABRICKS_TOKEN"
  check_string_existence "--set modules.text2vec-mistral.enabled=true --set modules.text2vec-mistral.apiKey=mistralApiKey" "name: MISTRAL_APIKEY"
  check_string_existence "--set modules.generative-mistral.enabled=true --set modules.generative-mistral.apiKey=mistralApiKey --set modules.text2vec-mistral.enabled=true --set modules.text2vec-mistral.apiKey=mistralApiKey" "name: MISTRAL_APIKEY"
  check_string_existence "--set modules.multi2vec-cohere.enabled=true --set modules.multi2vec-cohere.apiKey=apiKey" "name: COHERE_APIKEY"
  check_string_existence "--set modules.multi2vec-nvidia.enabled=true --set modules.multi2vec-nvidia.apiKey=apiKey" "name: NVIDIA_APIKEY"
  check_string_existence "--set modules.text2vec-nvidia.enabled=true --set modules.text2vec-nvidia.apiKey=apiKey" "name: NVIDIA_APIKEY"
  check_string_existence "--set modules.reranker-nvidia.enabled=true --set modules.reranker-nvidia.apiKey=apiKey" "name: NVIDIA_APIKEY"
  check_string_existence "--set modules.generative-nvidia.enabled=true --set modules.generative-nvidia.apiKey=apiKey" "name: NVIDIA_APIKEY"

  check_setting_has_value "--set replicas=3 --set env.RAFT_BOOTSTRAP_EXPECT=3" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=3 --set env.RAFT_BOOTSTRAP_EXPECT=3" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=8 --set env.RAFT_BOOTSTRAP_EXPECT=3" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=8 --set env.RAFT_BOOTSTRAP_EXPECT=3" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=1 --set env.RAFT_BOOTSTRAP_EXPECT=1" "name: RAFT_JOIN" "value: \"weaviate-0\""
  check_setting_has_value "--set replicas=1 --set env.RAFT_BOOTSTRAP_EXPECT=1" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"1\""
  check_setting_has_value "--set replicas=4 --set env.RAFT_BOOTSTRAP_EXPECT=4" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"4\""
  check_setting_has_value "--set replicas=4 --set env.RAFT_BOOTSTRAP_EXPECT=4" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2,weaviate-3\""
  check_setting_has_value "--set replicas=10 --set env.RAFT_BOOTSTRAP_EXPECT=4" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2,weaviate-3\""
  check_setting_has_value "--set replicas=10 --set env.RAFT_JOIN=weaviate-100" "name: RAFT_JOIN" "value: \"weaviate-100\""
  check_setting_has_value "--set replicas=10 --set env.RAFT_JOIN=weaviate-100" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"1\""
  check_setting_has_value "--set replicas=10 --set env.RAFT_JOIN=weaviate-100 --set env.RAFT_BOOTSTRAP_EXPECT=1" "name: RAFT_JOIN" "value: \"weaviate-100\""
  check_setting_has_value "--set replicas=100 --set env.RAFT_JOIN=weaviate-100\,weaviate-200" "name: RAFT_JOIN" "value: \"weaviate-100,weaviate-200\""
  check_setting_has_value "--set replicas=100 --set env.RAFT_JOIN=weaviate-100\,weaviate-200" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"2\""

  check_setting_has_value "--set replicas=8 --set env.RAFT_BOOTSTRAP_EXPECT=5" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2,weaviate-3,weaviate-4\""
  check_setting_has_value "--set replicas=8 --set env.RAFT_BOOTSTRAP_EXPECT=8" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2,weaviate-3,weaviate-4,weaviate-5,weaviate-6,weaviate-7\""
  check_setting_has_value "--set replicas=100 --set env.RAFT_BOOTSTRAP_EXPECT=1" "name: RAFT_JOIN" "value: \"weaviate-0\""
  check_setting_has_value "--set replicas=8 --set env.RAFT_JOIN=weaviate-100\,weaviate-200" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"2\""
  check_setting_has_value "--set replicas=100 --set env.RAFT_JOIN=weaviate-100" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"1\""
  check_setting_has_value "--set replicas=100 --set env.RAFT_JOIN=weaviate-100 --set env.RAFT_BOOTSTRAP_EXPECT=1" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"1\""
  check_setting_has_value "--set replicas=200 --set env.RAFT_JOIN=weaviate-100\,weaviate-200\,weaviate-300 --set env.RAFT_BOOTSTRAP_EXPECT=3" "name: RAFT_JOIN" "value: \"weaviate-100,weaviate-200,weaviate-300\""

  check_setting_has_value "--set replicas=1" "name: RAFT_JOIN" "value: \"weaviate-0\""
  check_setting_has_value "--set replicas=1" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"1\""
  check_setting_has_value "--set replicas=2" "name: RAFT_JOIN" "value: \"weaviate-0\""
  check_setting_has_value "--set replicas=2" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"1\""
  check_setting_has_value "--set replicas=3" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=3" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=4" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=4" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=5" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=5" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=6" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=6" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=7" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=7" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=8" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=8" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=9" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2\""
  check_setting_has_value "--set replicas=9" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=10" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2,weaviate-3,weaviate-4\""
  check_setting_has_value "--set replicas=10" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"5\""
  check_setting_has_value "--set replicas=11" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2,weaviate-3,weaviate-4\""
  check_setting_has_value "--set replicas=11" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"5\""
  check_setting_has_value "--set replicas=100" "name: RAFT_JOIN" "value: \"weaviate-0,weaviate-1,weaviate-2,weaviate-3,weaviate-4\""
  check_setting_has_value "--set replicas=100" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"5\""

  check_setting_has_value "--set replicas=9 --set env.RAFT_METADATA_ONLY_VOTERS=true" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""
  check_setting_has_value "--set replicas=9 --set env.RAFT_METADATA_ONLY_VOTERS=true" "name: RAFT_METADATA_ONLY_VOTERS" "value: \"true\""
  check_setting_has_value "--set replicas=3 --set env.RAFT_METADATA_ONLY_VOTERS=false" "name: RAFT_BOOTSTRAP_EXPECT" "value: \"3\""

  _settingPassageQueryOn="--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.passageQueryServices.passage.enabled=true --set modules.text2vec-transformers.passageQueryServices.query.enabled=true"
  check_setting_has_value "$_settingPassageQueryOn" "name: TRANSFORMERS_PASSAGE_INFERENCE_API" "value: http://transformers-inference-passage.default.svc.cluster.local.:8080"
  check_setting_has_value "$_settingPassageQueryOn" "name: TRANSFORMERS_QUERY_INFERENCE_API" "value: http://transformers-inference-query.default.svc.cluster.local.:8080"
  check_no_setting "$_settingPassageQueryOn" "name: TRANSFORMERS_INFERENCE_API"

  _settingPassageQueryOff="--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true"
  check_setting_has_value "$_settingPassageQueryOff" "name: TRANSFORMERS_INFERENCE_API" "value: http://transformers-inference.default.svc.cluster.local.:8080"
  check_no_setting "$_settingPassageQueryOff" "name: TRANSFORMERS_PASSAGE_INFERENCE_API"
  check_no_setting "$_settingPassageQueryOff" "name: TRANSFORMERS_QUERY_INFERENCE_API"

  check_setting_has_value "--set backups.filesystem.enabled=true" "name: BACKUP_FILESYSTEM_PATH" "value: \"/tmp/backups\""
  check_setting_has_value "--set backups.s3.enabled=true" "name: BACKUP_S3_BUCKET" "value: \"weaviate-backups\""
  check_setting_has_value "--set backups.s3.enabled=true --set backups.s3.envconfig.BACKUP_S3_PATH=custom/path" "name: BACKUP_S3_PATH" "value: \"custom/path\""
  check_setting_has_value "--set backups.gcs.enabled=true" "name: BACKUP_GCS_BUCKET" "value: \"weaviate-backups\""
  check_setting_has_value "--set backups.gcs.enabled=true --set backups.gcs.envconfig.BACKUP_GCS_PATH=custom/path" "name: BACKUP_GCS_PATH" "value: \"custom/path\""
  check_setting_has_value "--set backups.azure.enabled=true" "name: BACKUP_AZURE_CONTAINER" "value: \"weaviate-backups\""
  check_setting_has_value "--set backups.azure.enabled=true --set backups.azure.envconfig.BACKUP_AZURE_PATH=custom/path" "name: BACKUP_AZURE_PATH" "value: \"custom/path\""

  check_string_existence "--set initContainers.sysctlInitContainer.enabled=true " "name: configure-sysctl"
  check_string_existence "--set initContainers.extraInitContainers[0].name=test-init-container " "name: test-init-container"
  check_string_existence "--set initContainers.sysctlInitContainer.enabled=false --set initContainers.extraInitContainers[0].name=test-init-container " "name: test-init-container"

  check_string_existence "--set extraVolumes[0].name=test-extra-volume" "name: test-extra-volume"
  check_string_existence "--set extraVolumeMounts[0].name=test-extra-volumemount" "name: test-extra-volumemount"

  check_string_existence "--set securityContext.thisIsATest=true " "thisIsATest: true"
  check_string_existence "--set containerSecurityContext.allowPrivilegeEscalation=false " "allowPrivilegeEscalation: false"
  check_string_existence "" "imagePullPolicy: IfNotPresent"
  check_setting_has_value "--set image.pullSecrets[0]=weaviate-image-pull-secret" "imagePullSecrets" "name: weaviate-image-pull-secret"
  check_string_existence "--set updateStrategy.type=OnDelete" "type: OnDelete"
  check_setting_has_value "--set updateStrategy.rollingUpdate.maxUnavailable=10%" "rollingUpdate" "maxUnavailable: 10%"
  check_string_existence "--set priorityClassName=critical" "priorityClassName: critical"
  check_string_existence "--set globalPriorityClassName=high" "priorityClassName: high"

  DEPLOYMENT_MODULES=(
    "text2vec-contextionary"
    "text2vec-transformers"
    "text2vec-transformers.passageQueryServices.passage"
    "text2vec-transformers.passageQueryServices.query"
    "text2vec-gpt4all"
    "multi2vec-clip"
    "multi2vec-bind"
    "qna-transformers"
    "img2vec-neural"
    "text-spellcheck"
    "ner-transformers"
    "sum-transformers"
    "reranker-transformers"
    "text2vec-model2vec"
  )

  for module in "${DEPLOYMENT_MODULES[@]}"
  do
  no_dots_module=$(echo $module | tr . -)
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.livenessProbe.initialDelaySeconds=988888888888" "initialDelaySeconds: 988888888888"
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.livenessProbe.periodSeconds=988888888888" "periodSeconds: 988888888888"
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.livenessProbe.timeoutSeconds=988888888888" "timeoutSeconds: 988888888888"
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.readinessProbe.initialDelaySeconds=988888888888" "initialDelaySeconds: 988888888888"
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.readinessProbe.periodSeconds=988888888888" "periodSeconds: 988888888888"
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.imagePullPolicy=$no_dots_module" "imagePullPolicy: $no_dots_module"
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.securityContext.thisIsATestFrom$no_dots_module-context=true" "thisIsATestFrom$no_dots_module-context: true"
  check_setting_has_value "--set modules.$module.enabled=true --set modules.$module.imagePullSecrets[0]=$no_dots_module-pullSecrets" "imagePullSecrets" "name: $no_dots_module-pullSecrets"
  check_setting_has_value "--set modules.$module.enabled=true --set modules.$module.strategy.type=$no_dots_module-strategy" "strategy" "type: $no_dots_module-strategy"
  check_string_existence "--set modules.$module.enabled=true --set modules.$module.priorityClassName=$no_dots_module" "priorityClassName: $no_dots_module"
  check_string_existence "--set modules.$module.enabled=true --set globalPriorityClassName=high" "priorityClassName: high"
  done

  _settingScrapePromMetrics="--set env.PROMETHEUS_MONITORING_ENABLED=true --set serviceMonitor.enabled=true"
  check_setting_has_value "$_settingScrapePromMetrics" "name: metrics" "containerPort: 2112"
  check_setting_has_value "$_settingScrapePromMetrics" "apiVersion: monitoring.coreos.com/v1" "kind: ServiceMonitor"
  check_setting_has_value "--set env.PROMETHEUS_MONITORING_ENABLED=true --set serviceMonitor.enabled=false" "name: metrics" "containerPort: 2112"
  check_no_setting "--set env.PROMETHEUS_MONITORING_ENABLED=false --set serviceMonitor.enabled=true" "kind: ServiceMonitor"
  check_no_setting "--set env.PROMETHEUS_MONITORING_ENABLED=false --set serviceMonitor.enabled=false" "kind: ServiceMonitor"

  check_string_existence "--set readinessProbe.probeType=exec --set readinessProbe.probe.exec.command={test-probe-cmd}" "exec:"
  check_string_existence "--set readinessProbe.probeType=exec --set readinessProbe.probe.exec.command={test-probe-cmd}" "command:"
  check_string_existence "--set readinessProbe.probeType=exec --set readinessProbe.probe.exec.command={test-probe-cmd}" "test-probe-cmd"

  echo "Tests successful."
)
