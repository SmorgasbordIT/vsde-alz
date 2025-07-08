// hubBastion.bicep

module modBastionSubnetModule '../Subnet/hubSubnet.bicep' = {
  name: parBastionSubnetName
  scope: resourceGroup(parRgHubNetworkVnet) // Deploys to VNet's RG
  params: {
    vnetName: parHubNetworkVnetName
    subnetName: parBastionSubnetName
    addressPrefix: parBastionSubnetPrefix
    nsgId: resBastionNsg.id
  }
}




// hubSubnet.bicep

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  name: subnetName
  parent: existingVnet
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: {
      id: nsgId
    }
  }
}
