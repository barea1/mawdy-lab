terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.55.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "fbfstterraformstate2026"
    container_name       = "tfstate"
    key                  = "mawdy-lab.tfstate"
  }
}

provider "azurerm" {
  features {}
}
