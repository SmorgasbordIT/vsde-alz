@description('Name of the Virtual Network')
param vnetName string

@description('Location for the VNet')
param location string

@description('Address space for the VNet')
param addressPrefixes array

@description('DNS server IP addresses')
param dnsServers array

@description('Resource tags')
param tags object

@description('Enable DDoS Protection')
param enableDdosProtection bool

@description('DDoS Protection Plan name')
param ddosProtectionPlan string

resource resVnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection ? {
      id: resourceId('Microsoft.Network/ddosProtectionPlans', ddosProtectionPlan)
    } : null
  }
}

output vnetName string = resVnet.name
