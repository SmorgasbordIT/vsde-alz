metadata name = 'ALZ Bicep - Subnet Module'
metadata description = 'ALZ Bicep Module used to set up multiple Subnets'

@description('Array of subnet definitions (name, address, NSG ID, route table ID, delegation, etc.)')
param subnets array

@description('Name of the VNet where the subnets will be created')
param vnetName string

resource existingVnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vnetName
}

resource subnetResources 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = [for subnet in subnets: {
  name: subnet.name
  parent: existingVnet
  properties: {
    addressPrefix: subnet.ipAddressRange
    networkSecurityGroup: empty(subnet.networkSecurityGroupId) ? null : {
      id: subnet.networkSecurityGroupId
    }
    routeTable: empty(subnet.routeTableId) ? null : {
      id: subnet.routeTableId
    }
    delegations: empty(subnet.delegation) ? [] : [
      {
        name: '${subnet.name}-delegation'
        properties: {
          serviceName: subnet.delegation
        }
      }
    ]
  }
}]

output subnetIds array = [for subnet in subnetResources: subnet.id]
