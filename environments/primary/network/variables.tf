//=============================================================================================================
//   Network Variables
//=============================================================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

variable "vpc_config" {
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "route_table_config" {
  type = map(object({
    routes = optional(map(object({
      cidr_block       = string
      gateway          = optional(bool)
      nat_gateway      = optional(bool)
      network_firewall = optional(bool)
    })))
    subnets_names = list(string)
  }))
}


//=============================================================================================================
//   Security Groups Variables
//=============================================================================================================

variable "security_group_config" {
  type = map(object({
    ingress = optional(map(object({
      from_port                  = number
      to_port                    = number
      ip_protocol                = string
      cidr_block                 = optional(string)
      vpc_cidr                   = optional(bool)
      source_security_group_name = optional(string)
      prefix_list_ids            = optional(list(string))
    })))
    egress = optional(map(object({
      from_port                  = number
      to_port                    = number
      ip_protocol                = string
      cidr_block                 = optional(string)
      vpc_cidr                   = optional(bool)
      source_security_group_name = optional(string)
      prefix_list_ids            = optional(list(string))
    })))
    tags = optional(map(string))
  }))
}


