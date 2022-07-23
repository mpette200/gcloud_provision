# gcloud_provision
Provision a Google cloud instance for project

Note that the storage bucket needs to be created manually and not with gcloud tool.  
[https://console.cloud.google.com/storage](https://console.cloud.google.com/storage)

Can copy-paste from below. The commands are partly based upon
[https://github.com/google-github-actions/auth](https://github.com/google-github-actions/auth)

```bash

#### DEFINE VARIABLES ####
# update all variables here to match your requirements
export PROJECT_ID="birkbeck-ccp-01"
export SERVICE_ACCOUNT_NAME="my-github-05"
export POOL_NAME="github-pool-05"
export PROVIDER_NAME="github-token-provider-05"
export IAM_ROLE_STORAGE="CustomStorageTerraform05"

# The variable REPO_NAME is used to set a condition requiring
# the repository name in the JSON web token to match the value
# defined here. This is a way of ensuring that only workflows
# from this specific repository will be granted permission.
export REPO_NAME="mpette200/gcloud_provision"

#### END OF VARIABLES ####

gcloud config set project "${PROJECT_ID}"

gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}"

gcloud services enable iamcredentials.googleapis.com

gcloud iam roles create "${IAM_ROLE_STORAGE}" \
  --project="${PROJECT_ID}" \
  --permissions="storage.multipartUploads.abort,storage.multipartUploads.create,storage.multipartUploads.list,storage.multipartUploads.listParts,storage.objects.create,storage.objects.delete,storage.objects.get,storage.objects.list,storage.objects.update"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role='roles/compute.admin'

gcloud iam workload-identity-pools create "${POOL_NAME}" \
  --location="global" \

gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
  --location="global" \
  --workload-identity-pool="${POOL_NAME}" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

# save this for next command
export POOL_ID_LONG="$( \
    gcloud iam workload-identity-pools describe "${POOL_NAME}" \
    --location="global" \
    --format="value(name)" \
)"
# Important for security:
# .../attribute.repository/${REPO_NAME}
# allows access only from the specific repository
gcloud iam service-accounts add-iam-policy-binding \
  "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${POOL_ID_LONG}/attribute.repository/${REPO_NAME}"

# use this value as the workload_identity_provider in your Github Actions YAML
gcloud iam workload-identity-pools providers describe "${PROVIDER_NAME}" \
  --location="global" \
  --workload-identity-pool="${POOL_NAME}" \
  --format="value(name)"

```

Then, need to create storage bucket manually and not with gcloud tool
and set permissions to the IAM_ROLE_STORAGE defined above.  
[https://console.cloud.google.com/storage](https://console.cloud.google.com/storage)
