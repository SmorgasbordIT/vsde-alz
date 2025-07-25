metadata name = 'ALZ Bicep - Hub Subnet Module'
metadata description = 'ALZ Bicep Module used to set up Hub Subnet'

@description('Subnet name')
param subnetName string

@description('Address prefix for the subnet')
param addressPrefix string

@description('ID of the NSG to associate')
param nsgId string

@description('ALZ Hub VNet resource group name')
param vnetName string

@description('ID of the route table to associate (optional)')
param routeTableId string = ''

@description('Delegation service name (optional)')
param delegation string = ''

// Reference the parent VNet at this module's scope
resource existingVnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: subnetName
  parent: existingVnet
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: empty(nsgId) ? null : {
      id: nsgId
    }
    routeTable: empty(routeTableId) ? null : {
      id: routeTableId
    }
    delegations: empty(delegation) ? [] : [
      {
        name: '${subnetName}-delegation'
        properties: {
          serviceName: delegation
        }
      }
    ]
  }
}
