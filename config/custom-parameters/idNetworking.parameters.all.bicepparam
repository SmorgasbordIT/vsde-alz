using '../../bicep/v0.00.4/modules/coreNetworking/idNetworking.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

param parCompanyPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

// Read environment abbreviations for naming convention
var varAzUk = readEnvironmentVariable('AZUREUK','')
var varUks  = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnk  = readEnvironmentVariable('SPACENK_ABBR','')
var varAzEnvironmentId = readEnvironmentVariable('ID_GRP_NAME','')

// ALZ Identity formatted for Env var
var varIdFormatted = empty(varAzEnvironmentId) || length(varAzEnvironmentId) < 2
  ? 'XX'
  : toUpper(substring(varAzEnvironmentId, 0, 2))

// Read environment variables for naming convention
var varIdNetworkName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-vnet-01')
var varIdSnetAddsName   = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-snet-adds-01')
var varIdSnetEcsName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-snet-ecs-01')
var varIdSnetPepBakName = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-snet-pep-bak-01')
var varIdSnetPepAkvName = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-snet-pep-akv-01')
var varIdSnetIdName     = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-snet-pep-id-01')
var varIdSnetMgmtName   = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-snet-mgmt-01')
var varAzIdRtName       = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-rt-afw-01')

// Network Security Group names.
var varIdNsgAddsName   = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-nsg-adds-01')
var varIdNsgEcsName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-nsg-ecs-01')
var varIdNsgPepBakName = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-nsg-pep-bak-01')
var varIdNsgPepAkvName = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-nsg-pep-akv-01')
var varIdNsgIdName     = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-nsg-pep-id-01')
var varIdNsgMgmtName   = toUpper('${varAzUk}${varUks}-${varSnk}-${varIdFormatted}-nsg-mgmt-01')

// ID networking parameters.
param parIdNetworkName = '${varIdNetworkName}'
param parIdNetworkAddressPrefix = '10.1.0.0/16'
param parDnsServerIps = []
param parDdosEnabled = false
param parDdosPlanName = 'alz-ddos-plan'

param parSubnets = [
  {
    name: varIdSnetAddsName
    ipAddressRange: '10.1.0.0/25'
    nsgName: varIdNsgAddsName
    networkSecurityGroupId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    name: varIdSnetEcsName
    ipAddressRange: '10.1.0.128/26'
    nsgName: varIdNsgEcsName
    networkSecurityGroupId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    name: varIdSnetPepBakName
    ipAddressRange: '10.1.1.0/26'
    nsgName: varIdNsgPepBakName
    networkSecurityGroupId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    name: varIdSnetPepAkvName
    ipAddressRange: '10.1.1.64/26'
    nsgName: varIdNsgPepAkvName
    networkSecurityGroupId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    name: varIdSnetIdName
    ipAddressRange: '10.1.1.128/26'
    nsgName: varIdNsgIdName
    networkSecurityGroupId: ''
    routeTableId: ''
    delegation: ''
  }
  {
    name: varIdSnetMgmtName
    ipAddressRange: '10.1.1.192/26'
    nsgName: varIdNsgMgmtName
    networkSecurityGroupId: ''
    routeTableId: ''
    delegation: ''
  }
]

// Azure Firewall parameters.
param parAzFirewallEnabled = true
param parAzFirewallIpAddress = '10.0.0.4'

// Routing table parameters.
param parIdRouteTableName = varAzIdRtName
param parDisableBgpRoutePropagation = false

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Identity'
  DeployedBy: 'Cloud Tech'
  CreatedBy: 'jonathan.davis@spacenk.com'
  SvcName: 'Infrastructure'
  SvcOwner: 'Infrastructure@spacenk.com'
}

param parTelemetryOptOut = false
