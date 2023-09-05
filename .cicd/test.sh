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
  check_modules "--set modules.text2vec-cohere.enabled=true --set modules.text2vec-cohere.apiKey=apiKey --set modules.generative-cohere.enabled=true --set modules.generative-cohere.apiKey=apiKey" "value: generative-cohere,text2vec-cohere"
  check_modules "--set modules.text2vec-cohere.enabled=true --set modules.text2vec-cohere.apiKey=apiKey --set modules.generative-cohere.enabled=true --set modules.generative-cohere.apiKey=apiKey --set modules.reranker-cohere.enabled=true --set modules.reranker-cohere.apiKey=apiKey" "value: generative-cohere,text2vec-cohere,reranker-cohere"
  check_modules "--set modules.text2vec-cohere.enabled=true --set modules.text2vec-cohere.apiKey=apiKey --set modules.reranker-cohere.enabled=true --set modules.reranker-cohere.apiKey=apiKey" "value: text2vec-cohere,reranker-cohere"
  check_modules "--set modules.generative-cohere.enabled=true --set modules.generative-cohere.apiKey=apiKey" "value: generative-cohere"
  check_modules "--set modules.text2vec-palm.enabled=true" "value: text2vec-palm"
  check_modules "--set modules.generative-palm.enabled=true" "value: generative-palm"
  check_modules "--set modules.text2vec-palm.enabled=true --set modules.text2vec-palm.apiKey=apiKey --set modules.generative-palm.enabled=true --set modules.generative-palm.apiKey=apiKey" "value: generative-palm,text2vec-palm"
  check_modules "--set modules.generative-palm.enabled=true --set modules.generative-palm.apiKey=apiKey" "value: generative-palm"
  check_modules "--set modules.text2vec-contextionary.enabled=false --set modules.reranker-transformers.enabled=true" "value: reranker-transformers"
  check_modules "--set modules.text2vec-contextionary.enabled=true --set modules.text-spellcheck.enabled=true --set modules.reranker-transformers.enabled=true" "value: text2vec-contextionary,text-spellcheck,reranker-transformers"
  check_modules "--set modules.text2vec-gpt4all.enabled=true" "value: text2vec-gpt4all"
  check_modules "--set modules.text2vec-gpt4all.enabled=true --set modules.text-spellcheck.enabled=true" "value: text2vec-gpt4all,text-spellcheck"
  check_modules "--set modules.multi2vec-bind.enabled=true" "value: multi2vec-bind"
  check_modules "--set modules.multi2vec-bind.enabled=true --set modules.text-spellcheck.enabled=true" "value: text-spellcheck,multi2vec-bind"

  check_modules "--set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.azureApiKey=azureApiKey" "value: text2vec-openai"
  check_modules "--set modules.qna-openai.enabled=true --set modules.qna-openai.azureApiKey=azureApiKey" "value: qna-openai"
  check_modules "--set modules.generative-openai.enabled=true --set modules.generative-openai.azureApiKey=azureApiKey" "value: generative-openai"
  check_modules "--set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.azureApiKey=azureApiKey --set modules.qna-openai.enabled=true --set modules.qna-openai.azureApiKey=azureApiKey --set modules.generative-openai.enabled=true --set modules.generative-openai.azureApiKey=azureApiKey" "value: qna-openai,generative-openai,text2vec-openai"
  check_string_existence "--set modules.text2vec-openai.enabled=true --set modules.text2vec-openai.azureApiKey=azureApiKey" "name: AZURE_APIKEY"
  check_string_existence "--set modules.qna-openai.enabled=true --set modules.qna-openai.azureApiKey=azureApiKey" "name: AZURE_APIKEY"
  check_string_existence "--set modules.generative-openai.enabled=true --set modules.generative-openai.azureApiKey=azureApiKey" "name: AZURE_APIKEY"

  _settingPassageQueryOn="--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.passageQueryServices.passage.enabled=true --set modules.text2vec-transformers.passageQueryServices.query.enabled=true"
  check_setting_has_value "$_settingPassageQueryOn" "name: TRANSFORMERS_PASSAGE_INFERENCE_API" "value: http://transformers-inference-passage.default.svc.cluster.local:8080"
  check_setting_has_value "$_settingPassageQueryOn" "name: TRANSFORMERS_QUERY_INFERENCE_API" "value: http://transformers-inference-query.default.svc.cluster.local:8080"
  check_no_setting "$_settingPassageQueryOn" "name: TRANSFORMERS_INFERENCE_API"

  _settingPassageQueryOff="--set modules.text2vec-contextionary.enabled=false --set modules.text2vec-transformers.enabled=true"
  check_setting_has_value "$_settingPassageQueryOff" "name: TRANSFORMERS_INFERENCE_API" "value: http://transformers-inference.default.svc.cluster.local:8080"
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

  check_string_existence "--set securityContext.thisIsATest=true " "thisIsATest: true"
  check_string_existence "" "imagePullPolicy: IfNotPresent"
  check_setting_has_value "--set image.pullSecrets[0]=weaviate-image-pull-secret" "imagePullSecrets" "name: weaviate-image-pull-secret"
  check_setting_has_value "--set updateStrategy.type=OnDelete" "updateStrategy" "type: OnDelete"

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
  done

  echo "Tests successful."
)
