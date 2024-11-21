# Apolo deployment example: 

```zsh

# Run the job 
apolo run --pass-config ghcr.io/neuro-inc/app-deployment \
  -- install https://github.com/neuro-inc/weaviate-helm weaviate weaviate weaviate \
  --timeout=15m0s \
  --set preset_name=cpu-large \
  --set persistence.size=32Gi \
  --set ingress.enabled=true \
  --set ingress.clusterName=novoserve \
  --set ingress.grpc.enabled=true \
  --set clusterApi.username=taddeus \
  --set clusterApi.password=secretpassword \
  --set authentication.enabled=true \
  --set backups.enabled=true 


# Or Run the flow in isolated environment
apolo run --pass-config image://novoserve/apolo/taddeus/app-deployment \
  -- install https://github.com/neuro-inc/weaviate-helm weaviate weaviate weaviate \
  --timeout=15m0s \
  --set preset_name=cpu-large \
  --set persistence.size=32Gi \
  --set ingress.enabled=true \
  --set ingress.clusterName=novoserve \
  --set ingress.grpc.enabled=true \
  --set clusterApi.username=taddeus \
  --set clusterApi.password=secretpassword \
  --set authentication.enabled=true \
  --set backups.enabled=true 

```