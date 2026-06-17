//==========================================================================================================================================
//                                                         /modules/rds/variables.tf
//==========================================================================================================================================

variable "vpc_id" {
  type = string
}

variable "rds_identifier" {
  type = string
}

variable "rds" {
  type = object({
    # Engine
    engine_version = string
    # Compute & Performance
    instance_class = string
    multi_az       = bool
    # Security & Network
    security_group_id = string
    subnets_ids       = list(string)
    # Database Setup
    username    = string # Master admin user name
    db_name     = string
    db_username = string # wordpress database username - it will be created using (Lambda / bastion host)
  })
}
