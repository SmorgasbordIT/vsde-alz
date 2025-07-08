@description('VNet with a subnet for Private Endpoints')
param vnetName string = 'vnet'
@description('Address prefix for the VNet')
param vnetAddressPrefix string = '10.100.0.0/16'
@description('Name of the subnet for the Private Endpoint')
param privateEndpointSubnetName string = 'snet-pe'
@description('Address prefix for the Private Endpoint subnet')
param privateEndpointSubnetAddressPrefix string = '10.100.1.0/24'
param subnets array = []
  
param location string = resourceGroup().location
var privateFunctionAppDnsZoneName = 'privatelink.azurewebsites.net'
resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: privateEndpointSubnetName
        properties: {
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          addressPrefix: privateEndpointSubnetAddressPrefix
        }
      }
    ]
  }
}
@batchSize(1)
resource Subnets 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = [
  for (sn, index) in subnets: {
    name: 'snet-${sn.name}'
    parent: vnet
    properties: {
      addressPrefix: sn.subnetPrefix
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'functionsDelegation'
          properties: {
            serviceName: 'Microsoft.App/environments'
          }
        }
      ]
    }
  }
]
resource privateFunctionAppDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateFunctionAppDnsZoneName
  location: 'global'
}
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateFunctionAppDnsZone
  name: '${privateFunctionAppDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}
