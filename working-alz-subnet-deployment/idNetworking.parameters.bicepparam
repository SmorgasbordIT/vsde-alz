
param parSubnets = [
  {
    name: 'subnet1'
    ipAddressRange: '10.0.0.0/24'
    nsgName: 'nsg-subnet1'
    routeTableId: ''
    delegation: ''
  }
  {
    name: 'subnet2'
    ipAddressRange: '10.0.1.0/24'
    nsgName: 'nsg-subnet2'
    routeTableId: ''
    delegation: ''
  }
]

param parIdNetworkName = 'myVnet'
param parLocation = 'uksouth'
param parTags = {
  environment: 'dev'
  owner: 'ALZ'
}
