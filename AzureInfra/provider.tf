terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Inline Authentication Not a Better Practise - we're login using Service Principal

  #https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2
  subscription_id = "####################"
  tenant_id       = "####################"
  client_id       = "####################"
  client_secret   = "####################"
}


# Authentication test - Service Principal Working/not
output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

data "azurerm_client_config" "current" {}
