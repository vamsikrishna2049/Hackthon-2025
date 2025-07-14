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
<img width="1033" height="95" alt="image" src="https://github.com/user-attachments/assets/b06dd112-fc30-424f-aa01-3e87b1abc1f5" />

---

## Verifying the values
```bash
echo $ARM_CLIENT_ID
echo $ARM_CLIENT_SECRET
echo $ARM_TENANT_ID
echo $ARM_SUBSCRIPTION_ID
```

<img width="671" height="175" alt="image" src="https://github.com/user-attachments/assets/782f7815-c4cf-4289-afe2-2b2da9f58ce6" />

---


## Service Prinicipal Testing
```bash
 az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```
<img width="1341" height="374" alt="image" src="https://github.com/user-attachments/assets/2ea32796-3c64-4f93-9cdf-6f81fe4a23a3" />


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
