terraform {
  #  experiments = [module_variable_optional_attrs]
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.83.0"
    }
  }
  required_version = ">= 1.1.9"
}
