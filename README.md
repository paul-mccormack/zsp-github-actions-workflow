# Use Zero Standing Privilege Gateway with GitHub Actions

## Introduction

This repo is to test the use of Zero Standing Privilege (ZSP) Gateway with GitHub Actions. The ZSP Gateway is a tool that allows human operators, service principals and AI Agents to securely access Azure resources without requiring permanent standing privileges. The workflow will request access to the resource, and the ZSP Gateway will grant time limited access to the resource.

The Zero Standing Privilege Gateway was made by Jerrad Dahlager, More information about the ZSP Gateway and how to deploy it can be found in his GitHub repo [zsp-azure-lab](https://github.com/j-dahl7/zsp-azure-lab) and linked [blog post](https://nineliveszerotrust.com/blog/zero-standing-privilege-azure/).

Access for service principals is based on assigning the Azure IAM role directly to the service principal.<br>
Human operator access is granted by adding the user to an Entra group that has the required role assignment.<br><br>

When the function app grants access, it will start a revocation timer, which will automatically remove the access after the specified duration.  The function app will also log the access request and revocation in Log Analytics.

## Requirements

You need to have the ZSP Gateway Function App deployed and configured.

You will need to create a service principal in your Entra/Azure environment for the GitHub Actions workflow. I used my PowerShell script to create a new service principal with OIDC federated credentials, This script will create the role assignment on the target scope automatically.  I manually removed it to carry out this test.  The PowerShell script can be found [here](https://github.com/paul-mccormack/actions-entra-auth).

The Function App Identity must have User Access Administrator role applied to the scope where it will be managing access.<br>
In this test, the Function App will be managing access to my sandbox subscription.

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

## Triggering the function app to grant access

The function app is triggered by a HTTP POST request. The snips below show examples of how to trigger the function app for both human operator access and service principal access in both PowerShell and bash.

### Human Operator

> [!NOTE]
> I haven't used references to GitHub Secrets in the human operator examples below as I would expect this feature would be used by the operator in a terminal.  The human operator examples are just to show how it's done.

In bash:

```bash
curl -X POST "https://<Azure Function App URL>/api/admin-access" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: <Azure Function App key>" \
  -d '{
    "user_id": "Entra User Object ID",
    "group_id": "Entra Group Object ID",
    "duration_minutes": 10,
    "justification": "Testing123456"
  }'
```

In PowerShell:

```powershell
$uri = "https://<Azure Function App URL>/api/admin-access"
$headers = @{
    "Content-Type"="application/json"
    "x-functions-key"="<Azure Function App key>"
}
$body = @{
    "user_id"="Entra User Object ID"
    "group_id"="Entra Group Object ID"
    "duration_minutes"=10
    "justification"="Testing123456"
} | ConvertTo-Json

Invoke-WebRequest -Uri $uri -Method "POST" -Headers $headers -Body $body
```
### Service Prinicipal

In bash:

```bash
curl -X POST "${{ secrets.AZURE_FUNCTION_URL }}/api/nhi-access" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: ${{ secrets.AZURE_FUNCTION_KEY }}" \
  -d '{
    "sp_object_id": "${{ secrets.AZURE_SP_OBJECT_ID }}",
    "scope": "/subscriptions/${{ secrets.AZURE_SUBSCRIPTION_ID }}",
    "role": "Contributor",
    "duration_minutes": 10,
    "workflow_id": "github-actions"
    }'
```
In PowerShell:

```powershell
$uri = "https://${{ secrets.AZURE_FUNCTION_URL }}/api/nhi-access"
$headers = @{
    "Content-Type"="application/json"
    "x-functions-key"="${{ secrets.AZURE_FUNCTION_KEY }}"
}
$body = @{
    "sp_object_id"="${{ secrets.AZURE_SP_OBJECT_ID }}"
    "scope"="/subscriptions/${{ secrets.AZURE_SUBSCRIPTION_ID }}"
    "role"="Contributor"
    "duration_minutes"=10
    "workflow_id"="github-actions"
} | ConvertTo-Json

Invoke-WebRequest -Uri $uri -Method "POST" -Headers $headers -Body $body
```

See the worklow file in this repo for an example of how to trigger the function app to grant a service principal access: [.github/workflows/deploy.yml](.github/workflows/deploy.yml)



