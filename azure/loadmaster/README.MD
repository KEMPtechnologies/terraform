# terraform-loadmaster-module

## Description

This module creates a LoadMaster deployment in Azure cloud environment. Module is automating deployment we can found describe in [Deploy LoadMaster HA in Azure](https://support.kemptechnologies.com/hc/en-us/articles/210264966-High-Availability-HA-for-Azure).
Module flexibility allows us to deploy HA pair or standalone LoadMaster unit.
Output gives us access to the private and public ip addresses of deployed instances. 
LoadMasters licensing and configuration is out of scope of this module.


## Example 1 - deploy LoadMaster HA Pair
```terraform
provider "azurerm" {
  version = "=2.0.0"
  features {}
}

locals {
  prefix           = "examples"
  location         = "West Europe"
  address_spaces   = ["192.22.0.0/16"]
  address_prefixes = "192.22.128.0/24"
  admin_username   = "bal"
  admin_password   = "exampleEEExampl123"
  vm_size          = "Standard_DS2_v2"
}

resource "azurerm_resource_group" "example" {
  name     = "${local.prefix}-rg"
  location = local.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-${local.prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = local.address_spaces
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-${local.prefix}"
  resource_group_name  = azurerm_resource_group.example.name
  address_prefix       = local.address_prefixes
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_network_security_group" "example" {
  name                = "nsg-example"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet_network_security_group_association" "str_sub_nsg" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

module "loadmaster" {
  source                 = "https://github.com/KEMPtechnologies/terraform/azure/loadmaster"

  is_ha                  = true

  location               = local.location
  prefix                 = local.prefix
  subnet_id              = azurerm_subnet.example.id
  vm_size                = local.vm_size

  resource_group_name    = azurerm_resource_group.example.name
  network_security_group = azurerm_network_security_group.example

  av_set_managed = true
  admin_username = local.admin_username
  admin_password = local.admin_password
}

output "lms_private_ip" {
  value = module.loadmaster.private_ip_addresses
}

output "lms_public_ip" {
  value = module.loadmaster.public_addresses
}
```

##  List of resources created and configured by module for HA Pair:

* Availability Set
* 2 x Azure Network Interface 
* Azure Public IP
* Azure load balancer
* Azure Network Security rules - to allow access to LM web interface
* Azure loadbalancer probes
* Azure load balancing rules
* Azure load balancing NAT rules
* Adding VMs to the backend address pool
* Create 2 x Virtual Machines with LoadMaster image from market place
* Install LoadMaster

## Example 2 - deploy LoadMaster standalone unit
```terraform
provider "azurerm" {
  version = "=2.0.0"
  features {}
}

locals {
  prefix           = "examples"
  location         = "West Europe"
  address_spaces   = ["192.22.0.0/16"]
  address_prefixes = "192.22.128.0/24"
  admin_username   = "eeExample"
  admin_password   = "exampleEEExampl123"
  vm_size          = "Standard_DS2_v2"
}

resource "azurerm_resource_group" "example" {
  name     = "${local.prefix}-rg"
  location = local.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-${local.prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = local.address_spaces
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-${local.prefix}"
  resource_group_name  = azurerm_resource_group.example.name
  address_prefix       = local.address_prefixes
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_network_security_group" "example" {
  name                = "nsg-example"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet_network_security_group_association" "str_sub_nsg" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

module "loadmaster" {
  source                 = "https://github.com/KEMPtechnologies/terraform/azure/loadmaster"

  is_ha                  = false

  location               = local.location
  prefix                 = local.prefix
  subnet_id              = azurerm_subnet.example.id
  vm_size                = local.vm_size

  resource_group_name    = azurerm_resource_group.example.name
  network_security_group = azurerm_network_security_group.example

  av_set_managed = true
  admin_username = local.admin_username
  admin_password = local.admin_password
}

output "lms_private_ip" {
  value = module.loadmaster.private_ip_addresses
}

output "lms_public_ip" {
  value = module.loadmaster.public_addresses
}
```

##  List of resources created and configured by module for standalone unit:

* Azure Public Ip address
* Azure Network Interface with Private Address
* Azure Virtual Machine
* Add WUI rule to the Network Security Group
* Install LoadMaster

### 3.2 Module configuration variables

```terraform

module "loadmaster" {
  source                 = "https://github.com/KEMPtechnologies/terraform/azure/loadmaster"

  is_ha                  = false

  location               = 
  prefix                 = 
  subnet_id              = 
  vm_size                = 

  resource_group_name    = 
  network_security_group = 

  av_set_managed = 
  admin_username = 
  admin_password = 
}

```

## Explicitly demanded variables:

* **source** - path to the module source code

* **is_ha** - switch flag for HA Pair and Standalone Unit

* **location** - Azure location for resources

* **prefix** - prefix used to unified naming convention 

* **subnet_id** - id of subnet we want to place LoadMaster pair

* **vm_size** - [Azure Virtual Machine size](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general) we want to use to deploy LoadMaster 

* **resource_group_name** - Resource group name from created in project resource group or retrieved from already created in Azure (using data.azurerm_...)

* **network_security_group** - pass the whole object of network security group resource

* **av_set_managed** - this variable configure availability set. It can be managed or unmanaged. Default set to "true"

* **admin_username** - username used to login to the LoadMaster
* **admin_password** - password used to login into LM


## Implicit variable configurations ( These parameters are set by default to provide quick LM_HA deploy. We can also overload them from module config perspective):

* **allocation_method** - (default: "Static") (Required) Defines the allocation method for  IP address. Possible values are Static or Dynamic

* **lm_market_details** - (map) Defines LoadMaster Image from marketplace
* **network_security_rules** - We can pass network security rule to configure provided network security group. That is provided by default. Default rule is opening all the ports so please consider to close it once you going for production.  

```bash
default = {
  publisher      = "kemptech"
  offer          = "vlm-azure"
  sku            = "basic-byol"
  name           = "basic-byol"
  product        = "vlm-azure"
  plan_publisher = "kemptech"
  version        = "7.2.480117992"
}
```
  To retrieve this data from marketplace we can uze Azure CLI:
  ```bash
  # Command to retrieve list of Kemp products in marketplace
    az vm image list --publisher kemp --all

  # Above command returns object (f.e):
...
  {
    "offer": "vlm-azure",
    "publisher": "kemptech",
    "sku": "basic-byol",
    "urn": "kemptech:vlm-azure:basic-byol:7.2.420016189",
    "version": "7.2.420016189"
  },
  {
    "offer": "vlm-azure",
    "publisher": "kemptech",
    "sku": "basic-byol",
    "urn": "kemptech:vlm-azure:basic-byol:7.2.430016425",
    "version": "7.2.430016425"
  },
  ...

  # To retrieve detailed data we can run example:

  az vm image show --urn kemptech:vlm-azure:basic-byol:7.2.420016189 --output json

Output:

"dataDiskImages": [],
  Microsoft.Compute/Locations/westus/Publishers/kemptech/ArtifactTypes/VMImage/Offers/vlm-azure/Skus/basic-byol/Versions/7.2.420016189",
  "location": "westus",
  "name": "7.2.420016189",
  "osDiskImage": {
    "operatingSystem": "Linux",
    "sizeInBytes": 17179869696,
    "sizeInGb": 16
  },
  "plan": {
    "name": "basic-byol",
    "product": "vlm-azure",
    "publisher": "kemptech"
  },
  "tags": null
}
  ```

* **probes** - health probes for azure loadbalancer, this can be passed as map of objects, module will iterate over and create proper health probes

```bash
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
```

* **lb_rules** - map of objects containing azure loadbalancing rules. Default is set to handle health probes and lm_https connection
```bash
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
``` 

* **nat_rules** - this variable defines nat rules responsible for routing request to proper hosting machine interface or protocol. 

```bash
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
```

## Outputs 
Terraform module is returning us object with private IP addresses and public IP address. 

```bash
lms_private_ip = {
  "examples-0-interface" = [
    "192.22.128.4",
  ]
}
lms_public_ip = public_IP_assigned_by_azure
```

To retrieve outputs data and use it in CI/CD use:

```bash
CI_VARIABLE = `terraform outup $output_variable_name`
```

## End



