variable "is_ha" {
  description = "HA switch flag. Set true to deploy Kemp LoadMaster as HA. Set false to deploy as single unit, wont deploy Azure loadbalancer."
  type        = bool
  default     = true
}

variable "prefix" {
  description = "Name prefix to unify naming for project"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure location name"
  type        = string
  default     = null
}


variable "network_security_rules" {
  description = "Network security group rules handling trafic related to LoadMaster connections"
  type = map(object({
    name                        = string
    priority                    = number
    direction                   = string
    access                      = string
    protocol                    = string
    source_port_range           = string
    source_address_prefix       = string
    destination_address_prefix  = string
    destination_port_range      = string
  }))
  default = {
    "LM_WUI" = {
      name                        = "LM_WUI"
      priority                    = 110
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "Tcp"
      source_port_range           = "*"
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
      destination_port_range      = "*"
    }
  }
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Id of subnet used by deployed LoadMaster"
  type        = string
  default     = null
}

variable "network_security_group" {
  description = "Network security group resource object"
}

variable "vm_size" {
  description = "Virtual Machnine Size to be used as Kubernetes Node"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "Admin username used to login to the nodes"
  type        = string
  default     = "bal"
}
variable "admin_password" {
  description = "Password used to login into LoadMaster nodes"
  type        = string
}

variable "av_set_managed" {
  description = "Flag is manages availability set"
  type        = bool
}


variable "azurelb_public_ip" {
  description = "Pass azure loadbalancer public ip resource object."
  default     = {}
}

variable "allocation_method" {
  description = "Public ip allocation method"
  type        = string
  default     = "Static"
}

variable "vms_public_ip" {
  description = "Pass public ip directly assigned to virtual machines."
  default     = {}
}


variable "public_ip_tags" {
  description = "Azure tags for organisational purposes."
  default     = {}
}

variable "lm_market_details" {
  default = {
    publisher      = "kemptech"
    offer          = "vlm-azure"
    sku            = "basic-byol"
    name           = "basic-byol"
    product        = "vlm-azure"
    plan_publisher = "kemptech"
    version        = "7.2.480117992"
  }
}

variable "probes" {
  description = "List of probe objects to render with name and port."
  type = map(object({
    name               = string
    protocol           = string
    port               = string
    path               = string
    interval           = string
    unhealthy_treshold = string
  }))
  default = {
    health1 = {
      name               = "health_lm_1"
      protocol           = "HTTP"
      port               = 8444
      path               = "/"
      interval           = 5
      unhealthy_treshold = 2
    }
  }
}


variable "lb_rules" {
  description = "Loadbalancer rules used in azure lb. Specificaly useful in HA mode"
  default = {
    HAPortRule = {
      name          = "LM-HAPortRule"
      protocol      = "TCP"
      frontend_port = 8444
      backend_port  = 8444
    },
    lm_https = {
      name          = "lm_https"
      protocol      = "TCP"
      frontend_port = 443
      backend_port  = 443
    }
  }
}

variable "nat_rules" {
  description = "Lm inbound nat rules"
  default = {
    ui_iface_0 = {
      iface_index   = 0
      name          = "lm_interface_0"
      protocol      = "Tcp"
      frontend_port = 8441
      backend_port  = 8443
    },
    ui_iface_1 = {
      iface_index   = 1
      name          = "lm_interface_1"
      protocol      = "Tcp"
      frontend_port = 8442
      backend_port  = 8443
    },
    ssh_0 = {
      iface_index   = 0
      name          = "ssh0_rule"
      protocol      = "Tcp"
      frontend_port = 2200
      backend_port  = 22
    },
    ssh_1 = {
      iface_index   = 1
      name          = "ssh1_rule"
      protocol      = "Tcp"
      frontend_port = 2201
      backend_port  = 22
    }
  }
}
