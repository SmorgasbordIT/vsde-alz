
param parLocation string
param parIdNetworkName string
param parSubnets array
param parTags object

resource resNsgs 'Microsoft.Network/networkSecurityGroups@2024-05-01' = [for i in range(0, length(parSubnets)): {
  name: parSubnets[i].nsgName
  location: parLocation
  tags: parTags
  properties: {
    securityRules: []
  }
}]

module modSubnet1 './subnet.bicep' = {
  name: 'modSubnet-1'
  scope: resourceGroup()
  dependsOn: [resNsgs]
  params: {
    subnetName: parSubnets[0].name
    addressPrefix: parSubnets[0].ipAddressRange
    nsgId: resNsgs[0].id
    routeTableId: parSubnets[0].routeTableId
    delegation: parSubnets[0].delegation
    vnetName: parIdNetworkName
  }
}

module modSubnet2 './subnet.bicep' = {
  name: 'modSubnet-2'
  scope: resourceGroup()
  dependsOn: [modSubnet1]
  params: {
    subnetName: parSubnets[1].name
    addressPrefix: parSubnets[1].ipAddressRange
    nsgId: resNsgs[1].id
    routeTableId: parSubnets[1].routeTableId
    delegation: parSubnets[1].delegation
    vnetName: parIdNetworkName
  }
}
