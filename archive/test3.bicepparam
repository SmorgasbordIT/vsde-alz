using '../../bicep/v0.00.6/modules/hubBastion/hubBastion.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

param parCompanyPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

// Read environment abbreviations for naming convention
var varAzUk = readEnvironmentVariable('AZUREUK','')
var varUks  = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnk  = readEnvironmentVariable('SPACENK_ABBR','')
var varAzEnvironmentHub = readEnvironmentVariable('ENV_HUB','')

// Resource Groups name
var varRgHubNetworkVnet = toUpper('${varAzUk}${varUks}-rg-conn-network-01')

// Read environment variables for naming convention
var varHubNetworkVnetName = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-vnet-01')
var varAzBastionName      = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-bst-01')
var varAzBstSnetNsgName   = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-bst-nsg-01')

// Hub networking parameters.
param parHubNetworkVnetName = '${varHubNetworkVnetName}'
param parRgHubNetworkVnet = '${varRgHubNetworkVnet}'

// Default public IP parameters.
param parPublicIpSku = 'Standard'
param parPublicIpPrefix = ''
param parPublicIpSuffix = '-pip'

// Azure Bastion host parameters.
param parBastionSubnetPrefix = '10.0.1.0/27'
param parBastionSubnetName = 'AzureBastionSubnet'
param parAzBastionEnabled = true
param parAzBastionName = varAzBastionName
param parAzBastionSku = 'Standard'
param parAzBastionTunneling = false
param parAzBastionNsgName = varAzBstSnetNsgName
param parBastionOutboundSshRdpPorts = [
  '22'
  '3389'
]

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Connectivity'
  DeployedBy: 'Cloud Tech'
  CreatedBy: 'jonathan.davis@spacenk.com'
  SvcName: 'Infrastructure'
  SvcOwner: 'Infrastructure@spacenk.com'
}

param parTelemetryOptOut = false

param parBastionLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
