using '../../bicep/v0.00.4/modules/hubBastion/hubBastion.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

param parCompanyPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

// Read environment abbreviations for naming convention
var varAzUk = readEnvironmentVariable('AZUREUK','')
var varUks  = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnk  = readEnvironmentVariable('SPACENK_ABBR','')
var varAzEnvironmentHub = readEnvironmentVariable('ENV_HUB','')

// Read environment variables for naming convention
var varHubNetworkName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-vnet-01')
var varAzBastionName     = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-bst-01')
var varAzBstSnetNsgName  = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-bst-nsg-01')

// Hub networking parameters.
param parHubNetworkName = '${varHubNetworkName}'
param parHubNetworkAddressPrefix = '10.0.0.0/16'
param parDnsServerIps = []
param parDdosEnabled = false
param parDdosPlanName = 'alz-ddos-plan'

param parSubnets = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.0.0.192/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]

// Default public IP parameters.
param parPublicIpSku = 'Standard'
param parPublicIpPrefix = ''
param parPublicIpSuffix = '-pip'

// Azure Bastion host parameters.
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
