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

// Read environment variables for naming convention
var varHubNetworkName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-vnet-01')
var varHubSnetPepName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-pep-01')
var varDnsPrIn01         = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-dnspr-in-01')
var varDnsPrOut01        = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-dnspr-out-01')
var varHubSnetMgmtName   = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-mgmt-01')
var varAzBastionName     = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-bst-01')
var varAzBstSnetNsgName  = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-snet-bst-nsg-01')
var varAzFirewallName    = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-afw-01')
var varAzHubRtName       = toUpper('${varAzUk}${varUks}-${varSnk}-${varAzEnvironmentHub}-rt-afw-01')
var varHubVpnGwName      = toLower('${varAzEnvironmentHub}-vpngw-01')
var varHubErGwName       = toLower('${varAzEnvironmentHub}-ergw-01')

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
    name: 'GatewaySubnet'
    ipAddressRange: '10.0.0.128/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.0.0.160/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.0.0.192/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varHubSnetPepName
    ipAddressRange: '10.0.0.240/26'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varDnsPrIn01
    ipAddressRange: '10.0.1.4/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varDnsPrOut01
    ipAddressRange: '10.0.1.36/27'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: varHubSnetMgmtName
    ipAddressRange: '10.0.1.68/28'
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

// Azure Firewall parameters.
param parAzFirewallEnabled = true
param parAzFirewallName = varAzFirewallName
param parAzFirewallPoliciesName = '${varAzFirewallName}-policy'
param parAzFirewallTier = 'Standard'
param parAzFirewallIntelMode = 'Alert'
param parAzFirewallAvailabilityZones = null
param parAzFirewallDnsProxyEnabled = true
param parAzFirewallDnsRequireProxyForNetworkRules = true
param parAzFirewallDnsServers = []

// Routing table parameters.
param parHubRouteTableName = varAzHubRtName
param parDisableBgpRoutePropagation = false

// Private DNS zone parameters.
param parPrivateDnsZonesEnabled = true
param parPrivateDnsZones = [
  '${varLocationFormatted}.data.privatelink.azurecr.io'
  'privatelink-global.wvd.microsoft.com'
  'privatelink.${varLocationFormatted}.backup.windowsazure.com'
  'privatelink.${varLocationFormatted}.azmk8s.io'
  'privatelink.${varLocationFormatted}.azurecontainerapps.io'
  'privatelink.${varLocationFormatted}.kusto.windows.net'
  'privatelink.adf.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.analysis.windows.net'
  'privatelink.analytics.cosmos.azure.com'
  'privatelink.api.adu.microsoft.com'
  'privatelink.api.azureml.ms'
  'privatelink.attest.azure.net'
  'privatelink.azconfig.io'
  'privatelink.azure-api.net'
  'privatelink.azure-automation.net'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.azure-devices.net'
  'privatelink.azurecr.io'
  'privatelink.azuredatabricks.net'
  'privatelink.azurehdinsight.net'
  'privatelink.azurehealthcareapis.com'
  'privatelink.azureiotcentral.com'
  'privatelink.azurestaticapps.net'
  'privatelink.azuresynapse.net'
  'privatelink.azurewebsites.net'
  'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.database.windows.net'
  'privatelink.datafactory.azure.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.dicom.azurehealthcareapis.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.directline.botframework.com'
  'privatelink.documents.azure.com'
  'privatelink.dp.kubernetesconfiguration.azure.com'
  'privatelink.eventgrid.azure.net'
  'privatelink.fhir.azurehealthcareapis.com'
  'privatelink.file.core.windows.net'
  'privatelink.grafana.azure.com'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.guestconfiguration.azure.com'
  'privatelink.his.arc.azure.com'
  'privatelink.managedhsm.azure.net'
  'privatelink.mariadb.database.azure.com'
  'privatelink.media.azure.net'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.monitor.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.notebooks.azure.net'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.pbidedicated.windows.net'
  'privatelink.postgres.cosmos.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.queue.core.windows.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.search.windows.net'
  'privatelink.service.signalr.net'
  'privatelink.servicebus.windows.net'
  'privatelink.services.ai.azure.com'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.sql.azuresynapse.net'
  'privatelink.table.core.windows.net'
  'privatelink.table.cosmos.azure.com'
  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.token.botframework.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
  'privatelink.webpubsub.azure.com'
  'privatelink.workspace.azurehealthcareapis.com'
  'privatelink.wvd.microsoft.com'
]

param privateLinkPrivateDnsZonesToExclude = [
  '${varLocationFormatted}.data.privatelink.azurecr.io'
  'privatelink.${varLocationFormatted}.azurecontainerapps.io'
  'privatelink.${varLocationFormatted}.kusto.windows.net'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.analysis.windows.net'
  'privatelink.analytics.cosmos.azure.com'
  'privatelink.api.adu.microsoft.com'
  'privatelink.api.azureml.ms'
  'privatelink.attest.azure.net'
  'privatelink.azconfig.io'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.azure-devices.net'
  'privatelink.azurehealthcareapis.com'
  'privatelink.azureiotcentral.com'
  'privatelink.azurestaticapps.net'
  'privatelink.azuresynapse.net'
  'privatelink.batch.azure.com'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.dev.azuresynapse.net'
  'privatelink.dicom.azurehealthcareapis.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.directline.botframework.com'
  'privatelink.dp.kubernetesconfiguration.azure.com'
  'privatelink.eventgrid.azure.net'
  'privatelink.fhir.azurehealthcareapis.com'
  'privatelink.grafana.azure.com'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.guestconfiguration.azure.com'
  'privatelink.his.arc.azure.com'
  'privatelink.managedhsm.azure.net'
  'privatelink.mariadb.database.azure.com'
  'privatelink.media.azure.net'
  'privatelink.monitor.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.notebooks.azure.net'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.openai.azure.com'
  'privatelink.pbidedicated.windows.net'
  'privatelink.postgres.cosmos.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.search.windows.net'
  'privatelink.service.signalr.net'
  'privatelink.services.ai.azure.com'
  'privatelink.sql.azuresynapse.net'
  'privatelink.table.cosmos.azure.com'
  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.token.botframework.com'
  'privatelink.webpubsub.azure.com'
  'privatelink.workspace.azurehealthcareapis.com'
]

param parVpnGatewayEnabled = false
param parAzVpnGatewayAvailabilityZones = null
param parVpnGatewayConfig = {
  name: varHubVpnGwName
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
  ipConfigurationName: 'AZUKS-SNK-HUB-VPNGW-AA-01'
  ipConfigurationActiveActiveName: 'AZUKS-SNK-HUB-VPNGW-AA-02'
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
  ipConfigurationName: 'AZUKS-SNK-HUB-ERGW-AA-01'
  ipConfigurationActiveActiveName: 'AZUKS-SNK-HUB-ERGW-AA-02'
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

param parBastionLock = {
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
