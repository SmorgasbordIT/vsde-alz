
param parSubnets array
param parIdNetworkName string
param parLocation string
param parTags object

resource resNsgs 'Microsoft.Network/networkSecurityGroups@2024-05-01' = [for i in range(0, length(parSubnets)): {
  name: parSubnets[i].nsgName
  location: parLocation
  tags: parTags
  properties: {
    securityRules: []
  }
}]

var batchedSubnets = [for i in range(0, length(parSubnets)): {
  name: parSubnets[i].name
  ipAddressRange: parSubnets[i].ipAddressRange
  networkSecurityGroupId: resNsgs[i].id
  routeTableId: parSubnets[i].routeTableId
  delegation: contains(parSubnets[i], 'delegation') ? parSubnets[i].delegation : ''
}]

module modSubnets './subnet.bicep' = {
  name: 'modAllSubnets'
  scope: resourceGroup()
  dependsOn: [
    resNsgs
  ]
  params: {
    subnets: batchedSubnets
    vnetName: parIdNetworkName
    location: parLocation
  }
}
