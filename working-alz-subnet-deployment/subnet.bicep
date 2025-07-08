
@description('Array of subnet configurations')
param subnets array

@description('Name of the VNet')
param vnetName string

@description('Location of the deployment')
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vnetName
}

resource subnetResources 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = [for subnet in subnets: {
  name: subnet.name
  parent: vnet
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
