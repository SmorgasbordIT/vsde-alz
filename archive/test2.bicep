metadata name = 'ALZ Bicep - Hub Networking Module'
metadata description = 'ALZ Bicep Module used to set up Hub Networking'

type subnetOptionsType = ({
  @description('Name of subnet.')
  name: string
  @description('IP-address range for subnet.')
  ipAddressRange: string
  @description('Id of Network Security Group to associate with subnet.')
  networkSecurityGroupId: string?
  @description('Id of Route Table to associate with subnet.')
  routeTableId: string?
  @description('Name of the delegation to create for the subnet.')
  delegation: string?
})[]

@description('The Azure Region to deploy the resources into.')
param parLocation string = resourceGroup().location

@description('Prefix value which will be prepended to all resource names.')
param parCompanyPrefix string = 'alz'

@description('Name for ID Network.')
param parIdNetworkName string = '${parCompanyPrefix}-id-${parLocation}'

@description('The IP address range for ID Network.')
param parIdNetworkAddressPrefix string = '10.10.0.0/16'

@description('The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param parSubnets subnetOptionsType = [
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.10.15.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]

@description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array = []

@description('Name of Route table to create for the default route of ID Network.')
param parIdRouteTableName string = '${parCompanyPrefix}-hub-routetable'

@description('Tags to apply to resources')
param parTags object = {}

@description('Switch to enable/disable DDoS Network Protection deployment.')
param parDdosEnabled bool = true

@description('DDoS Plan Name.')
param parDdosPlanName string = '${parCompanyPrefix}-ddos-plan'

@description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

@description('Switch to enable/disable Azure Firewall default route.')
param parAzFirewallEnabled bool = false

@description('Disable BGP route propagation on Route Table')
param parDisableBgpRoutePropagation bool = true

@description('Name of the Azure Firewall resource (required if parAzFirewallEnabled is true)')
param parAzFirewallName string = '${parCompanyPrefix}-azfw'

// Optional Azure Firewall reference (if enabled)
resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2023-02-01' existing = if (parAzFirewallEnabled) {
  name: parAzFirewallName
}

// Optional Route Table with default route to Azure Firewall
resource resHubRouteTable 'Microsoft.Network/routeTables@2024-05-01' = if (parAzFirewallEnabled) {
  name: parIdRouteTableName
  location: parLocation
  tags: parTags
  properties: {
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
    routes: [
      {
        name: 'hub-udr-default-azfw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

// DDoS Protection Plan (optional)
resource resDdosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-02-01' = if (parDdosEnabled) {
  name: parDdosPlanName
  location: parLocation
  tags: parTags
}

// VNet module
module modVnet '../virtualNetwork/vnet.bicep' = {
  name: 'mod-Vnet'
  params: {
    vnetName: parIdNetworkName
    location: parLocation
    tags: parTags
    addressPrefixes: [parIdNetworkAddressPrefix]
    dnsServers: parDnsServerIps
    enableDdosProtection: parDdosEnabled
    ddosProtectionPlan: parDdosPlanName
  }
}

// Subnet modules
module modSubnets '../subnet/subnet.bicep' = [for subnet in parSubnets: {
  name: 'modSubnet-${subnet.name}'
  scope: resourceGroup()
  dependsOn: [
    modVnet
  ]
  params: {
    subnetName: subnet.name
    addressPrefix: subnet.ipAddressRange
    nsgId: subnet.networkSecurityGroupId
    routeTableId: subnet.routeTableId
    delegation: subnet.delegation
    vnetName: parIdNetworkName
  }
}]
