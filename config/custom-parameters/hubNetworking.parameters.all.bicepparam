using '../../bicep/v0.00.4/modules/hubNetworking/hubNetworking.bicep'

param parLocation = readEnvironmentVariable('UKS_LOCATION','uksouth')

param parCompanyPrefix = readEnvironmentVariable('TOP_LEVEL_MG_PREFIX','azuk-snk')

// Read environment abbreviations for naming convention
var varAzTenantId = readEnvironmentVariable('AZURE_TENANT_ID','')
var varAzUk = readEnvironmentVariable('AZUREUK','')
var varUks  = readEnvironmentVariable('AZ_UKSOUTH','')
var varSnk  = readEnvironmentVariable('SPACENK_ABBR','')
var varAzEnvironmentHub = readEnvironmentVariable('ENV_HUB','')

// Need location formatted without spaces for private DNS zone names.
var varLocationFormatted = toLower(replace(parLocation, ' ', ''))

// Resource Groups name
//var varRgConnNet = toUpper('${varAzUk}${varUks}-rg-conn-network-01')
//var varRgConnSec = toUpper('${varAzUk}${varUks}-rg-conn-security-01')
var varRgConnDns = toUpper('${varAzUk}${varUks}-rg-conn-dns-01')

// Read environment variables for naming convention
var varHubNetworkName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-vnet-01')
var varHubSnetPepName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-pep-01')
var varDnsPrIn01         = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-dnspr-in-01')
var varDnsPrOut01        = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-dnspr-out-01')
var varHubSnetMgmtName   = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-mgmt-01')
var varAzFirewallName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-afw-01')
var varAzHubRtName       = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-rt-afw-01')
var varHubVpnGwName01    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-vpngw-01')
var varHubVpnGwName02    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-vpngw-02')
var varHubErGwName       = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-ergw-01')

// Hub networking parameters.
param parHubNetworkName = '${varHubNetworkName}'
param parHubNetworkAddressPrefix = '10.0.0.0/16'
param parDnsServerIps = []
param parDdosEnabled = false
param parDdosPlanName = 'alz-ddos-plan'

param parSubnets = [
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.0.0.0/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallManagementSubnet'
    ipAddressRange: '10.0.0.64/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet' // VPN Gateway Subnet
    ipAddressRange: '10.0.0.128/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
//  {
//    name: 'GatewaySubnet' // ExpressRoute Gateway Subnet
//    ipAddressRange: '10.0.0.160/27'
//    networkSecurityGroupId: ''
//    routeTableId: ''
//  }
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.0.0.192/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varHubSnetPepName
    ipAddressRange: '10.0.1.0/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varDnsPrIn01
    ipAddressRange: '10.0.1.64/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varDnsPrOut01
    ipAddressRange: '10.0.1.96/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varHubSnetMgmtName
    ipAddressRange: '10.0.1.128/28'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]

// Default public IP parameters.
param parPublicIpSku = 'Standard'
param parPublicIpPrefix = ''
param parPublicIpSuffix = '-pip'

// Azure Firewall parameters.
param parAzFirewallEnabled = true
param parAzFirewallName = varAzFirewallName
param parAzFirewallPoliciesName = '${varAzFirewallName}-policy'
param parAzFirewallTier = 'Standard'
param parAzFirewallIntelMode = 'Alert'
param parAzFirewallAvailabilityZones = null
param parAzFirewallDnsProxyEnabled = true
param parAzFirewallDnsServers = []

// Routing table parameters.
param parHubRouteTableName = varAzHubRtName
param parDisableBgpRoutePropagation = false

// Private DNS zone parameters.
param parPrivateDnsZonesResourceGroup = varRgConnDns
param parPrivateDnsZonesEnabled = true
param parPrivateDnsZones = [
  'privatelink-global.wvd.microsoft.com'
  'privatelink.${varLocationFormatted}.azmk8s.io'
  'privatelink.${varLocationFormatted}.backup.windowsazure.com'
  'privatelink.adf.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.azure-api.net'
  'privatelink.azure-automation.net'
  'privatelink.azurecr.io'
  'privatelink.azuredatabricks.net'
  'privatelink.azurehdinsight.net'
  'privatelink.azurewebsites.net'
  'privatelink.blob.core.windows.net'
  'privatelink.database.windows.net'
  'privatelink.datafactory.azure.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.documents.azure.com'
  'privatelink.file.core.windows.net'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.queue.core.windows.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.servicebus.windows.net'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.table.core.windows.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
  'privatelink.wvd.microsoft.com'
]

param parVpnGatewayEnabled = true
param parHubVpnGwPipActiveActiveName01 = '${varHubVpnGwName01}-pip'
param parHubVpnGwPipActiveActiveName02 = '${varHubVpnGwName02}-pip'
param parAzVpnGatewayAvailabilityZones = null
param parVpnGatewayConfig = {
  name: varHubVpnGwName01
  gatewayType: 'Vpn'
  sku: 'VpnGw2'
  vpnType: 'RouteBased'
  generation: 'Generation2'
  enableBgp: false
  activeActive: true
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: '65515'
    bgpPeeringAddress: '10.0.0.132,10.0.0.133'
    peerWeight: '5'
  }
  vpnClientConfiguration: {
    vpnClientAddressPool: {
      addressPrefixes: [
        '172.16.255.0/24'
      ]
    }
    vpnClientProtocols: [
      'OpenVPN'
    ]
    vpnAuthenticationTypes: [
      'AAD'
    ]
    vpnClientRootCertificates: []
    vpnClientRevokedCertificates: []
    vngClientConnectionConfigurations: []
    radiusServers: []
    vpnClientIpsecPolicies: []
    aadTenant: 'https://login.microsoftonline.com/${varAzTenantId}/'
    aadAudience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
    aadIssuer: 'https://sts.windows.net/${varAzTenantId}/'
  }
  ipConfigurationName: 'vnetGatewayConfig'
  ipConfigurationActiveActiveName: 'vnetGatewayConfig2'
}

param parExpressRouteGatewayEnabled = false
param parAzErGatewayAvailabilityZones = null
param parExpressRouteGatewayConfig = {
  name: varHubErGwName
  gatewayType: 'ExpressRoute'
  sku: 'Standard'
  vpnType: 'RouteBased'
  generation: 'None'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: '65515'
    bgpPeeringAddress: ''
    peerWeight: '5'
  }
  ipConfigurationName: 'vnetGatewayConfig'
  ipConfigurationActiveActiveName: 'vnetGatewayConfig2'
}

param parTags = {
  Location: ('${parLocation}')
  Environment: 'Connectivity'
  DeployedBy: 'Cloud Tech'
  CreatedBy: 'jonathan.davis@spacenk.com'
  SvcName: 'Infrastructure'
  SvcOwner: 'Infrastructure@spacenk.com'
}

param parTelemetryOptOut = false

param parGlobalResourceLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parVirtualNetworkLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parDdosLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parAzureFirewallLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parHubRouteTableLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parPrivateDNSZonesLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

param parVirtualNetworkGatewayLock = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}
