# Installation Software's
# Azure CLI Installation
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

```bash
az login
```

```bash
az account show
```

# step-by-step Terraform installation guide for Ubuntu/Debian 
Here is a **step-by-step Terraform installation guide for Ubuntu/Debian**, based on the official HashiCorp instructions you provided:

---

### 1️⃣ Update your system and install prerequisites

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```

---

### 2️⃣ Install HashiCorp GPG key

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

---

### 3️⃣ Verify GPG key fingerprint (should show HashiCorp Security)

```bash
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

✅ You should see output with `HashiCorp Security` UID and the correct fingerprint.

---

### 4️⃣ Add the official HashiCorp apt repository

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

---

### 5️⃣ Update apt and install Terraform

```bash
sudo apt update
sudo apt-get install terraform
```

---

### 6️⃣ Verify Terraform installation

```bash
terraform -version
```



# How to get Azure RM Credentials

az account list
```bash
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "2b1beb41-ebc0-4f8d-b748-bf4917a6b194",
    "id": "61b3ba1a-d345-44f6-a043-200a4e5ae92b",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Dev(Pay-As-You-Go)",
    "state": "Enabled",
    "tenantDefaultDomain": "2312krishnap2312gmail.onmicrosoft.com",
    "tenantDisplayName": "Default Directory",
    "tenantId": "2b1beb41-ebc0-4f8d-b748-bf4917a6b194",
    "user": {
      "name": "2312krishnap2312@gmail.com",
      "type": "user"
    }
  }
]
```





# References:
Azure Provider Authentication using Service principal and a Client Secret
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
