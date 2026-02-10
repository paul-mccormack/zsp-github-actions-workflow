# Use Zero Standing Privilege Gateway with GitHub Actions

## Introduction

This repo is being used to test out the use of Zero Standing Privilege (ZSP) Gateway with GitHub Actions. The ZSP Gateway is a tool that allows human operators and managed identities to securely access resources without having to grant permanent standing privileges. The workflow will request access to the resource, and the ZSP Gateway will grant time limited access to the resource.

The Zero Standing Privilege Gateway was made by Jerrad Dahlager, More information about the ZSP Gateway and how to deploy it can be found in his GitHub repo: [zsp-azure-lab](https://github.com/j-dahl7/zsp-azure-lab).

## Requirements

You need to have the ZSP Gateway Function App deployed and configured.

You will need to create a service principal in your Entra/Azure environment for the GitHub Actions workflow. I used my PowerShell script to create a new service principal with OIDC federated credentials, This script will create the role assignment on the target scope automatically.  I manually removed it to carry out this test.  The PowerShell script can be found [here](https://github.com/paul-mccormack/actions-entra-auth).

The Function App Identity must have User Access Administrator role applied to the scope where it will be managing access.<br>
In this test, the Function App will be managing access to the resource group "rg-ukw-sandbox-pmc-zsp-deploy-test", so it needs to have the role assignment for that resource group or the parent subscription.

## Triggering the Function App for a human operator

In bash:

```bash
curl -X POST "https://<Function app url>/api/admin-access" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: <Function app key>" \
  -d '{
    "user_id": "Entra user object ID",
    "group_id": "Entra group object ID",
    "duration_minutes": 10,
    "justification": "Testing123456"
  }'
```

In PowerShell:

```powershell
$uri = "https://<Function app url>/api/admin-access"
$headers = @{
    "Content-Type"="application/json"
    "x-functions-key"="<Function app key>"
}
$body = @{
    "user_id"="Entra user object ID"
    "group_id"="Entra group object ID"
    "duration_minutes"=10
    "justification"="Testing123456"
} | ConvertTo-Json

Invoke-WebRequest -Uri $uri -Method "POST" -Headers $headers -Body $body
```
## Triggering the Function App for a managed identity

In bash:

```bash
curl -X POST "<Function app url>/api/nhi-access" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: <Function app key>" \
  -d '{
    "sp_object_id": "<Entra service principal object ID>",
    "scope": "/subscriptions/---/resourceGroups/<Target Resource Group>",
    "role": "Contributor",
    "duration_minutes": 10,
    "workflow_id": "github-actions"
    }'
```
In PowerShell:

```powershell
$uri = "https://<Function app url>/api/nhi-access"
$headers = @{
    "Content-Type"="application/json"
    "x-functions-key"="<Function app key>"
}
$body = @{
    "sp_object_id"="<Entra service principal object ID>"
    "scope"="/subscriptions/---/resourceGroups/<Target Resource Group>"
    "role"="Contributor"
    "duration_minutes"=10
    "workflow_id"="github-actions"
} | ConvertTo-Json

Invoke-WebRequest -Uri $uri -Method "POST" -Headers $headers -Body $body
```
## GitHub Repository Setup

The following Github Repo Secrets will need to be created:

| Secret Name | Description |
|-------------|-------------|
|AZURE_CLIENT_ID | The client ID of the service principal that was created for the GitHub Actions workflow. |
|AZURE_SP_OBJECT_ID | The object ID of the service principal that was created for the GitHub Actions workflow. |
|AZURE_TENANT_ID | The tenant ID of the Entra/Azure environment. |
|AZURE_SUBSCRIPTION_ID | The ID of the target Azure subscription. |
|AZURE_FUNCTION_KEY | The function key for the ZSP Gateway Function App. |
|AZURE_FUNCTION_URL | The URL of the ZSP Gateway Function App. |
