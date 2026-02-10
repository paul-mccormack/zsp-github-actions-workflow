# Use Zero Standing Privilege Gateway with GitHub Actions

## Introduction

This repo is being used to test out the use of Zero Standing Privilege (ZSP) Gateway with GitHub Actions. The ZSP Gateway is a tool that allows human operators and managed identities to securely access resources without having to grant permanent standing privileges. The workflow will request access to the resource, and the ZSP Gateway will grant time limited access to the resource.

The Zero Standing Privilege Gateway was made by Jerrad Dahlager, More information about the ZSP Gateway and how to deploy it can be found in his GitHub repo: [zsp-azure-lab](https://github.com/j-dahl7/zsp-azure-lab).

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
    "scope": "/subscriptions/---/resourceGroups/rg-ukw-sandbox-pmc-zsp-deploy-test",
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
    "scope"="/subscriptions/---/resourceGroups/rg-ukw-sandbox-pmc-zsp-deploy-test"
    "role"="Contributor"
    "duration_minutes"=10
    "workflow_id"="github-actions"
} | ConvertTo-Json

Invoke-WebRequest -Uri $uri -Method "POST" -Headers $headers -Body $body
```


Target Resource Group: rg-ukw-sandbox-pmc-zsp-deploy-test

Github Repo Secrets

AZURE_CLIENT_ID<br>
AZURE_TENANT_ID<br>
AZURE_SUBSCRIPTION_ID<br>
AZURE_FUNCTION_KEY<br>
AZURE_FUNCTION_URL<br>
