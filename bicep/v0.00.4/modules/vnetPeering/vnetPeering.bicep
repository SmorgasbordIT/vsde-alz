metadata name = 'ALZ Bicep - Virtual Network Peering module'
metadata description = 'Module used to set up Virtual Network Peering between Virtual Networks'

@sys.description('The Subscription for the source & destination Virtual Network is located.')
param parSourceSubscriptionId string
param parDestinationSubscriptionId string

@sys.description('Name of source and destination Resource Group where the Virtual Network is located.')
param parSourceResourceGroupName string
param parDestinationResourceGroupName string

@sys.description('Name of source Virtual Network we are peering.')
param parSourceVirtualNetworkName string

@sys.description('Name of destination virtual network we are peering.')
param parDestinationVirtualNetworkName string

@sys.description('Virtual Network ID of Virtual Network source.')
param parSourceVirtualNetworkId string

@sys.description('Virtual Network ID of Virtual Network destination.')
param parDestinationVirtualNetworkId string

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

// Derive destination RG name from VNet ID
var destRgName = split(parDestinationVirtualNetworkId, '/')[4]

// Forward Peering Module (local scope)
module modSourcePeering 'vnetPeeringSource.bicep' = {
  name: 'forwardPeering'
  params: {
    parSourceSubscriptionId: parSourceSubscriptionId
    parDestinationSubscriptionId: parDestinationSubscriptionId
    parSourceResourceGroupName: parSourceResourceGroupName
    parDestinationResourceGroupName: parDestinationResourceGroupName
    parDestinationVirtualNetworkId: parDestinationVirtualNetworkId
    parSourceVirtualNetworkName: parSourceVirtualNetworkName
    parDestinationVirtualNetworkName: parDestinationVirtualNetworkName
    parAllowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    parAllowForwardedTraffic: parAllowForwardedTraffic
    parAllowGatewayTransit: parAllowGatewayTransit
    parUseRemoteGateways: parUseRemoteGateways
    parTelemetryOptOut: parTelemetryOptOut
  }
}

// Reverse Peering Module (remote scope)
module modDestinationPeering 'vnetPeeringDestination.bicep' = {
  name: 'reversePeering'
  scope: resourceGroup(parDestinationSubscriptionId, destRgName)
  params: {
    parSourceSubscriptionId: parSourceSubscriptionId
    parDestinationSubscriptionId: parDestinationSubscriptionId
    parSourceResourceGroupName: parSourceResourceGroupName
    parDestinationResourceGroupName: parDestinationResourceGroupName
    parSourceVirtualNetworkId: resourceId(parSourceSubscriptionId, 'Microsoft.Network/virtualNetworks', parSourceVirtualNetworkName)
    parSourceVirtualNetworkName: parSourceVirtualNetworkName
    parDestinationVirtualNetworkName: parDestinationVirtualNetworkName
    parAllowVirtualNetworkAccess: parAllowVirtualNetworkAccess
    parAllowForwardedTraffic: parAllowForwardedTraffic
  }
}
