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
  #https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBladeV2
  subscription_id = "61b3ba1a-d345-44f6-a043-200a4e5ae92b"

  tenant_id = "b1beb41-ebc0-4f8d-b748-bf4917a6b194"

  client_id = "0a4663e-10ff-4298-8948-8c0ef5c4b861"

  client_secret = "p-o8Q~4TxH5UFdEk-x82vGddWeWsG6IkSF9nBdcB"
}
