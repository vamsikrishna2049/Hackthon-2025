# 🛡️ Terraform Authentication with Azure Service Principal (Client Secret)

## 🔹 Recommended Scenarios

* **CI/CD Pipelines**: Use Service Principal with Client Secret or Managed Identity
* **Local Testing**: Use Azure CLI authentication

---

## ✅ Service Principal Creation Steps

### 1️⃣ Login and Get Subscription ID

```bash
az login
az account list --output table
az account set --subscription "<subscription-id>"
```

<img width="1197" height="143" alt="image" src="https://github.com/user-attachments/assets/267f882f-921d-4b5d-97e1-7960ef687270" />


---

### 2️⃣ Create Service Principal with Contributor Role

```bash
az ad sp create-for-rbac --name="ServicePrinicipalName" --role="Contributor" --scopes="/subscriptions/<subscription-id>"
```

✅ **Output:**

```json
{
  "appId": "client-id",
  "displayName": "ServicePrinicipalName"
  "password": "client-secret",
  "tenant": "tenant-id"
}
```

### Refer the below Image
<img width="1460" height="283" alt="image" src="https://github.com/user-attachments/assets/9a7f2e0e-a5ea-4e3a-a788-1989ab8306a5" />

---

## 🛡️ Environment Variables for Terraform Authentication

```bash
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_TENANT_ID="<tenant>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
```

---

## 🛠️ Sample Terraform Provider Configuration

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

---

## 📝 Optional: Inline Provider Auth (Not Recommended)

```hcl
provider "azurerm" {
  features {}
  client_id       = "<client-id>"
  client_secret   = var.client_secret
  tenant_id       = "<tenant-id>"
  subscription_id = "<subscription-id>"
}
```

---

