param vnetName string
param vnetResourceGroup string
param location string
param subnetConfig array

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

resource subnets 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = [for subnet in subnetConfig: {
  name: subnet.name
  parent: vnet
  properties: {
    addressPrefix: subnet.addressPrefix
    delegation: subnet.delegation
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}]
