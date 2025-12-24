variable "github_token" {
  description = "Token GitHub personnel pour l’authentification"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "Nom d’utilisateur ou organisation GitHub"
  type        = string
}