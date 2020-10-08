output "private_ip_addresses" {
  value = {
    for  address in azurerm_network_interface.iface:
      address.name => address.private_ip_addresses
  }
}

output "public_addresses" {
  value = azurerm_public_ip.public_ip.ip_address
}