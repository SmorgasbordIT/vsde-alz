
metadata name = 'ALZ Bicep - ID Networking Module'
metadata description = 'ALZ Bicep Module used to set up ID Networking'

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

@sys.description('Name of Route table to create for the default route of ID Network.')
param parIdRouteTableName string = '${parCompanyPrefix}-hub-routetable'

@sys.description('Switch to enable/disable BGP Propagation on route table.')
param parDisableBgpRoutePropagation bool = false

@sys.description('Tags to apply to resources')
param parTags object = {}

@sys.description('Switch to enable/disable DDoS Network Protection deployment.')
param parDdosEnabled bool = true

@sys.description('DDoS Plan Name.')
param parDdosPlanName string = '${parCompanyPrefix}-ddos-plan'

@sys.description('Switch to enable/disable Azure Firewall default route.')
param parAzFirewallEnabled bool = false

@sys.description('The Azure Firewall IP address to use for the default route (required if parAzFirewallEnabled is true)')
param parAzFirewallIpAddress string = '${parCompanyPrefix}-azfw'

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

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
          nextHopIpAddress: parAzFirewallIpAddress
        }
      }
    ]
  }
}

//DDos Protection plan will only be enabled if parDdosEnabled is true.
resource resDdosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-02-01' = if (parDdosEnabled) {
  name: parDdosPlanName
  location: parLocation
  tags: parTags
}

// Create the Virtual Network using a module
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

// Deploy subnets using module and depend on VNet creation
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
    delegation: contains(subnet, 'delegation') ? subnet.delegation : ''
    vnetName: parIdNetworkName
  }
}]
