#!/bin/bash

set -eou pipefail

function check_modules() {
  local helm_settings=$1
  local expected_value=$2

  check_setting_has_value "$helm_settings" "ENABLE_MODULES" "$expected_value"
}

function check_setting_has_value() {
  local helm_settings=$1
  local setting=$2
  local expected_value=$3

  echo "Test if '$setting' has value '$expected_value' using: '$helm_settings' settings"
  helm template $helm_settings "weaviate.tgz" > out.yml
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

  echo "Test if '$setting' is absent using: '$helm_settings' settings"
  helm template $helm_settings "weaviate.tgz" > out.yml
  if grep -Fq "$setting" ../weaviate/out.yml; then
    echo "error: '$setting' was found"
    exit 1
  fi
  rm -fr ../weaviate/out.yml
}

function check_creates_template() {
  local helm_settings=$1

  helm template $helm_settings "weaviate.tgz" > out.yml
  rm -fr ../weaviate/out.yml
}

(
  cd weaviate
  VERSION=$( grep 'version:' < Chart.yaml | awk '{ print $2 }')
  echo "Running tests for version $VERSION"

  # cleanup in case there is a previous release already
  rm -rf "weaviate.tgz"

  helm dependencies build
  helm lint .
  helm package .

  mv "weaviate-$VERSION.tgz" "weaviate.tgz"

  check_creates_template "--set collector_proxy.enabled=true"

  check_modules "" "value: text2vec-contextionary"
  check_modules "--set modules.text2vec-contextionary.enabled=true" "value: text2vec-contextionary"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.qna-transformers.enabled=true" "value: qna-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.img2vec-neural.enabled=true" "value: img2vec-neural"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true" "value: text2vec-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.passageQueryServices.passage.enabled=true --set modules.text2vec-transformers.passageQueryServices.query.enabled=true" "value: text2vec-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true --set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true" "value: text2vec-transformers,qna-transformers,img2vec-neural"
  check_modules "--set modules.img2vec-neural.enabled=true --set modules.qna-transformers.enabled=true" "value: text2vec-contextionary,qna-transformers,img2vec-neural"
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

  _settingPassageQueryOn="--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.passageQueryServices.passage.enabled=true --set modules.text2vec-transformers.passageQueryServices.query.enabled=true"
  check_setting_has_value "$_settingPassageQueryOn" "name: TRANSFORMERS_PASSAGE_INFERENCE_API" "value: http://transformers-inference-passage.default.svc.cluster.local:8080"
  check_setting_has_value "$_settingPassageQueryOn" "name: TRANSFORMERS_QUERY_INFERENCE_API" "value: http://transformers-inference-query.default.svc.cluster.local:8080"
  check_no_setting "$_settingPassageQueryOn" "name: TRANSFORMERS_INFERENCE_API"

  _settingPassageQueryOff="--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true"
  check_setting_has_value "$_settingPassageQueryOff" "name: TRANSFORMERS_INFERENCE_API" "value: http://transformers-inference.default.svc.cluster.local:8080"
  check_no_setting "$_settingPassageQueryOff" "name: TRANSFORMERS_PASSAGE_INFERENCE_API"
  check_no_setting "$_settingPassageQueryOff" "name: TRANSFORMERS_QUERY_INFERENCE_API"

  echo "Tests successful."
)
