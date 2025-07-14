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

---

### 2️⃣ Create Service Principal with Contributor Role

```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription-id>"
```

✅ **Output:**

```json
{
  "appId": "client-id",
  "password": "client-secret",
  "tenant": "tenant-id"
}
```

---

### 3️⃣ (Optional) Test SP Login

```bash
az login --service-principal -u <appId> -p <password> --tenant <tenant>
az vm list-sizes --location eastus
```

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

