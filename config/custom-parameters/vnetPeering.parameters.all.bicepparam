using '../../bicep/v0.00.4/modules/vnetPeering/vnetPeering.bicep'

var varAzUkAbbrName = readEnvironmentVariable('AZUREUK','azuk')
var varAzUkSouth    = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnk          = readEnvironmentVariable('SPACENK_ABBR','')
var varAzEnvConn    = readEnvironmentVariable('CONN_GRP_NAME','')
var varAzEnvId      = readEnvironmentVariable('ID_GRP_NAME','')
var varAzEnvtHub    = readEnvironmentVariable('ENV_HUB','')

// The Source & Destination subscription ID if it is set, otherwise use the connectivity subscription ID ("Platform only" scenario)
param parSourceSubscriptionId = ''
param parDestinationSubscriptionId = ''

// ALZ Environment formatted for Env var
var varSourceFormatted = empty(varAzEnvConn) || length(varAzEnvConn) < 4
  ? 'XXXX'
  : toUpper(substring(varAzEnvConn, 0, 4))

var varDestinationFormatted = empty(varAzEnvId) || length(varAzEnvId) < 2
  ? 'XX'
  : toUpper(substring(varAzEnvId, 0, 2))

// The Virtual Network Resource Group names of the source & destination Virtual Networks
param parSourceResourceGroupName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-${varSourceFormatted}-network-01')
param parDestinationResourceGroupName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-rg-${varDestinationFormatted}-network-01')

// Name of the source & destination of the Virtual Network we are peering
var varSourceVirtualNetworkName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-${varSnk}-${varAzEnvtHub}-vnet-01')
var varDestinationVirtualNetworkName = toUpper('${varAzUkAbbrName}${varAzUkSouth}-${varSnk}-${varDestinationFormatted}-vnet-01')

// Virtual Network ID of Virtual Network source
param parSourceVirtualNetworkId = '/subscriptions/${parSourceSubscriptionId}/resourceGroups/${parSourceResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${varSourceVirtualNetworkName}'

// Virtual Network ID of Virtual Network destination
param parDestinationVirtualNetworkId = '/subscriptions/${parDestinationSubscriptionId}/resourceGroups/${parDestinationResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${varDestinationVirtualNetworkName}}'

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
