variable "postgresql_user" {
 type        = string
 description = "Username for postgress access"
 default     = "sonar"
 sensitive   = true
}

variable "postgresql_password" {
 type        = string
 description = "Password for postgress access"
 default     = "sonar_password"
 sensitive   = true
}

variable "sonarqube_user" {
 type        = string
 description = "Username for sonarqube access"
 default     = "user"
 sensitive   = true
}

variable "sonarqube_password" {
 type        = string
 description = "Password for sonarqube access"
 default     = "password"
 sensitive   = true
}

variable "sonarqube_database" {
 type        = string
 description = "Database to use with Sonarqube"
 default     = "sonarqube"
 sensitive   = false
}

variable "db_port"{
    type = number
    description = "Port to connect to the database"
    default = 5432
    sensitive = false

}