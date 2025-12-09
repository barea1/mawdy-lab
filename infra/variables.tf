# --- GENERAL ---
variable "project_name" {
  type        = string
  default     = "mawdy-lab"
  description = "Prefijo base para nombrar recursos"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Entorno de despliegue (dev, qa, prod)"
}

variable "location" {
  type        = string
  default     = "spaincentral"
  description = "Región de Azure"
}

# --- NETWORKING ---
variable "vnet_cidr" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Espacio de direcciones de la VNet"
}

variable "subnet_apps_cidr" {
  type        = list(string)
  default     = ["10.0.0.0/23"]
  description = "CIDR para la subred de Container Apps (Mínimo /23)"
}

# --- DATABASE ---
variable "sql_admin_user" {
  type      = string
  default   = "sqladmin"
  sensitive = true
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
  default   = "P@ssw0rdSegura123!" # En prod, esto vendría vacío y se pasaría por secrets
}

variable "sql_sku" {
  type        = string
  default     = "Basic"
  description = "SKU de la base de datos (Basic, S0, S1...)"
}

variable "sql_db_name" {
  type    = string
  default = "MawdyDB"
}

# --- CONTAINER REGISTRY ---
variable "acr_sku" {
  type        = string
  default     = "Basic"
  description = "SKU del registro de contenedores (Basic, Standard, Premium)"
}
