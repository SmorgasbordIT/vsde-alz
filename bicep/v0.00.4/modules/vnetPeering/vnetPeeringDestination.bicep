metadata name = 'ALZ Bicep - Virtual Network Peering Destination module'
metadata description = 'Module used to set up Virtual Network Peering from destination to source Virtual Networks.'

@sys.description('The Subscription for the source & destination Virtual Network is located.')
param parSourceSubscriptionId string
param parDestinationSubscriptionId string

@sys.description('Name of source and destination Resource Group where the Virtual Network is located.')
param parSourceResourceGroupName string
param parDestinationResourceGroupName string

@sys.description('Virtual Network ID of Virtual Network source.')
param parSourceVirtualNetworkId string

@sys.description('Name of source Virtual Network we are peering.')
param parSourceVirtualNetworkName string

@sys.description('Name of destination virtual network we are peering.')
param parDestinationVirtualNetworkName string

@sys.description('Switch to enable/disable Virtual Network Access for the Network Peer.')
param parAllowVirtualNetworkAccess bool = true

@sys.description('Switch to enable/disable forwarded traffic for the Network Peer.')
param parAllowForwardedTraffic bool = true

@sys.description('Switch to enable/disable gateway transit for the Network Peer.')
param parAllowGatewayTransit bool = false

@sys.description('Switch to enable/disable remote gateway for the Network Peer.')
param parUseRemoteGateways bool = false

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

// Customer Usage Attribution Id
var varCuaId = 'ab8e3b12-b0fa-40aa-8630-e3f7699e2142'

// Derive destination RG name from VNet ID
resource sourceVnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  scope: resourceGroup(parSourceSubscriptionId, parSourceResourceGroupName)
  name: parSourceVirtualNetworkName
}

resource resVirtualNetworkPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-05-01' = {
  name: '${parDestinationVirtualNetworkName}/${parDestinationVirtualNetworkName}_PCX_${parSourceVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    allowForwardedTraffic: parAllowForwardedTraffic
    allowGatewayTransit: parAllowGatewayTransit
    useRemoteGateways: parUseRemoteGateways
    remoteVirtualNetwork: {
      id: sourceVnet.id
    }
  }
}

// Optional Deployment for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varCuaId}-${uniqueString(resourceGroup().location)}'
  params: {}
}
