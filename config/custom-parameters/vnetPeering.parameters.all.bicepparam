using '../../bicep/v0.00.4/modules/vnetPeering/vnetPeering.bicep'

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUkSouth    = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnk          = readEnvironmentVariable('SPACENK_ABBR','')
var varAzEnvConn    = readEnvironmentVariable('CONN_GRP_NAME','')
var varAzEnvId      = readEnvironmentVariable('ID_GRP_NAME','')
var varAzEnvtHub    = readEnvironmentVariable('ENV_HUB','')

// Use the Hub subscription ID if it is set, otherwise use the connectivity subscription ID ("Platform only" scenario)
param parHubSubscriptionId = ''

// ALZ Environment formatted for Env var
var varConnFormatted = empty(varAzEnvConn) || length(varAzEnvConn) < 4
  ? 'XXXX'
  : toUpper(substring(varAzEnvConn, 0, 4))

var varIdFormatted = empty(varAzEnvId) || length(varAzEnvId) < 2
  ? 'XX'
  : toUpper(substring(varAzEnvId, 0, 2))

// The Hub Virtual Network Resource Group name
var varSourceResourceGroupName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-${varConnFormatted}-network-01')

// The Hub Virtual Network name
var varHubNetworkName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-${varSnk}-${varAzEnvtHub}-vnet-01')

// Name of the source Virtual Network we are peering
var varSourceVirtualNetworkName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-vnet-${varAzEnvtHub}-01')

// Name of the destination Virtual Network we are peering
var varDestinationVirtualNetworkName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-vnet-${varIdFormatted}-01')

// Virtual Network ID of Virtual Network destination
param parDestinationVirtualNetworkId = '/subscriptions/${parHubSubscriptionId}/resourceGroups/${varSourceResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${varHubNetworkName}'

// Name of source Virtual Network we are peering
param parSourceVirtualNetworkName = varSourceVirtualNetworkName

// Name of destination virtual network we are peering
param parDestinationVirtualNetworkName = varDestinationVirtualNetworkName

// Switch to enable/disable Virtual Network Access for the Network Peer
param parAllowVirtualNetworkAccess = true

// Switch to enable/disable forwarded traffic for the Network Peer
param parAllowForwardedTraffic = true

// Switch to enable/disable gateway transit for the Network Peer
param parAllowGatewayTransit = false

// Switch to enable/disable remote gateway for the Network Peer
param parUseRemoteGateways = false

// Set Parameter to true to Opt-out of deployment telemetry
param parTelemetryOptOut = false
