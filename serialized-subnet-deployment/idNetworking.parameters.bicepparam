
param parLocation = 'uksouth'
param parIdNetworkName = 'AZUKS-SNK-ID-VNET-01'
param parTags = {
  environment: 'identity'
  owner: 'infrastructure'
}

param parSubnets = [
  {
    name: 'AZUKS-SNK-ID-SNET-ADDS-01'
    ipAddressRange: '10.1.0.0/25'
    nsgName: 'NSG-ADDS-01'
    routeTableId: ''
    delegation: ''
  }
  {
    name: 'AZUKS-SNK-ID-SNET-ECS-01'
    ipAddressRange: '10.1.0.128/26'
    nsgName: 'NSG-ECS-01'
    routeTableId: ''
    delegation: ''
  }
]
