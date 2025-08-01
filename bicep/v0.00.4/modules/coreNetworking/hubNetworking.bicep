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

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. The lock settings of the service.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')

  @description('Optional. Notes about this lock.')
  notes: string?
}

@sys.description('The Azure Region to deploy the resources into.')
param parLocation string = resourceGroup().location

@sys.description('Prefix value which will be prepended to all resource names.')
param parCompanyPrefix string = 'alz'

@sys.description('Name for Hub Network.')
param parHubNetworkName string = '${parCompanyPrefix}-hub-${parLocation}'

@sys.description('''Global Resource Lock Configuration used for all resources deployed in this module.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parGlobalResourceLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('The IP address range for Hub Network.')
param parHubNetworkAddressPrefix string = '10.10.0.0/16'

@sys.description('The name, IP address range, network security group, route table and delegation serviceName for each subnet in the virtual networks.')
param parSubnets subnetOptionsType = [
  {
    name: 'AzureBastionSubnet'
    ipAddressRange: '10.10.15.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'GatewaySubnet'
    ipAddressRange: '10.10.252.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallSubnet'
    ipAddressRange: '10.10.254.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
  {
    name: 'AzureFirewallManagementSubnet'
    ipAddressRange: '10.10.253.0/24'
    networkSecurityGroupId: ''
    routeTableId: ''
  }
]

@sys.description('Array of DNS Server IP addresses for VNet.')
param parDnsServerIps array = []

@sys.description('''Resource Lock Configuration for Virtual Network.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parVirtualNetworkLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Public IP Address SKU.')
@allowed([
  'Basic'
  'Standard'
])
param parPublicIpSku string = 'Standard'

@sys.description('Optional Prefix for Public IPs. Include a succedent dash if required. Example: prefix-')
param parPublicIpPrefix string = ''

@sys.description('Optional Suffix for Public IPs. Include a preceding dash if required. Example: -suffix')
param parPublicIpSuffix string = '-PublicIP'

@sys.description('Switch to enable/disable DDoS Network Protection deployment.')
param parDdosEnabled bool = true

@sys.description('DDoS Plan Name.')
param parDdosPlanName string = '${parCompanyPrefix}-ddos-plan'

@sys.description('''Resource Lock Configuration for DDoS Plan.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parDdosLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Switch to enable/disable Azure Firewall deployment.')
param parAzFirewallEnabled bool = true

@sys.description('Azure Firewall Name.')
param parAzFirewallName string = '${parCompanyPrefix}-azfw-${parLocation}'

@sys.description('Set this to true for the initial deployment as one firewall policy is required. Set this to false in subsequent deployments if using custom policies.')
param parAzFirewallPoliciesEnabled bool = true

@sys.description('Azure Firewall Policies Name.')
param parAzFirewallPoliciesName string = '${parCompanyPrefix}-azfwpolicy-${parLocation}'

@description('The operation mode for automatically learning private ranges to not be SNAT.')
param parAzFirewallPoliciesAutoLearn string = 'Disabled'
@allowed([
  'Disabled'
  'Enabled'
])
@description('Private IP addresses/IP ranges to which traffic will not be SNAT.')
param parAzFirewallPoliciesPrivateRanges array = []

@sys.description('Azure Firewall Tier associated with the Firewall to deploy.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param parAzFirewallTier string = 'Standard'

@sys.description('The Azure Firewall Threat Intelligence Mode. If not set, the default value is Alert.')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param parAzFirewallIntelMode string = 'Alert'

@sys.description('Optional List of Custom Public IPs, which are assigned to firewalls ipConfigurations.')
param parAzFirewallCustomPublicIps array = []

@allowed([
  '1'
  '2'
  '3'
])
@sys.description('Availability Zones to deploy the Azure Firewall across. Region must support Availability Zones to use. If it does not then leave empty.')
param parAzFirewallAvailabilityZones array = []

@allowed([
  '1'
  '2'
  '3'
])
@sys.description('Availability Zones to deploy the VPN/ER PIP across. Region must support Availability Zones to use. If it does not then leave empty. Ensure that you select a zonal SKU for the ER/VPN Gateway if using Availability Zones for the PIP.')
param parAzErGatewayAvailabilityZones array = []

@allowed([
  '1'
  '2'
  '3'
])
@sys.description('Availability Zones to deploy the VPN/ER PIP across. Region must support Availability Zones to use. If it does not then leave empty. Ensure that you select a zonal SKU for the ER/VPN Gateway if using Availability Zones for the PIP.')
param parAzVpnGatewayAvailabilityZones array = []

@sys.description('Switch to enable/disable Azure Firewall DNS Proxy.')
param parAzFirewallDnsProxyEnabled bool = true

@sys.description('Array of custom DNS servers used by Azure Firewall')
param parAzFirewallDnsServers array = []

@sys.description(''' Resource Lock Configuration for Azure Firewall.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parAzureFirewallLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Name of Route table to create for the default route of Hub.')
param parHubRouteTableName string = '${parCompanyPrefix}-hub-routetable'

@sys.description('Switch to enable/disable BGP Propagation on route table.')
param parDisableBgpRoutePropagation bool = false

@sys.description('''Resource Lock Configuration for Hub Route Table.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parHubRouteTableLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Switch to enable/disable Private DNS Zones deployment.')
param parPrivateDnsZonesEnabled bool = true

@sys.description('Resource Group Name for Private DNS Zones.')
param parPrivateDnsZonesResourceGroup string = resourceGroup().name

@sys.description('Array of DNS Zones to provision and link to  Hub Virtual Network. Default: All known Azure Private DNS Zones, baked into underlying AVM module see: https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/network/private-link-private-dns-zones#parameter-privatelinkprivatednszones')
param parPrivateDnsZones array = []

@sys.description('Resource ID of Failover VNet for Private DNS Zone VNet Failover Links')
param parVirtualNetworkIdToLinkFailover string = ''

@sys.description('Array of Resource IDs of VNets to link to Private DNS Zones. Hub VNet is automatically included by module.')
param parVirtualNetworkResourceIdsToLinkTo array = []

@sys.description('''Resource Lock Configuration for Private DNS Zone(s).

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parPrivateDNSZonesLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Switch to enable/disable VPN virtual network gateway deployment.')
param parVpnGatewayEnabled bool = true

@sys.description('VPN Gateway Public IP names for an active-active gateway.')
param parHubVpnGwPipActiveActiveName01 string = ''
param parHubVpnGwPipActiveActiveName02 string = ''

@sys.description('VPN Gateway Public IP names for an point-to-site.')
param parHubVpnGwPipPointToSiteName01 string = ''

//ASN must be 65515 if deploying VPN & ER for co-existence to work: https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-coexist-resource-manager#limits-and-limitations
@sys.description('Configuration for VPN virtual network gateway to be deployed.')
param parVpnGatewayConfig object = {
  name: '${parCompanyPrefix}-Vpn-Gateway'
  gatewayType: 'Vpn'
  sku: 'VpnGw1'
  vpnType: 'RouteBased'
  generation: 'Generation1'
  enableBgp: false
  activeActive: false
  enableBgpRouteTranslationForNat: false
  enableDnsForwarding: false
  bgpPeeringAddress: ''
  bgpsettings: {
    asn: 65515
    bgpPeeringAddress: ''
    peerWeight: 5
  }
  vpnClientConfiguration: {}
  ipConfigurationName: 'vnetGatewayConfig'
  ipConfigurationActiveActiveName: 'vnetGatewayConfig2'
}

@sys.description('Switch to enable/disable ExpressRoute virtual network gateway deployment.')
param parExpressRouteGatewayEnabled bool = true

@sys.description('Configuration for ExpressRoute virtual network gateway to be deployed.')
param parExpressRouteGatewayConfig object = {
  name: '${parCompanyPrefix}-ExpressRoute-Gateway'
  gatewayType: 'ExpressRoute'
  sku: 'ErGw1AZ'
  vpnType: 'RouteBased'
  vpnGatewayGeneration: 'None'
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

@sys.description('''Resource Lock Configuration for ExpressRoute Virtual Network Gateway.

- `kind` - The lock settings of the service which can be CanNotDelete, ReadOnly, or None.
- `notes` - Notes about this lock.

''')
param parVirtualNetworkGatewayLock lockType = {
  kind: 'None'
  notes: 'This lock was created by the ALZ Bicep Hub Networking Module.'
}

@sys.description('Tags you would like to be applied to all resources in this module.')
param parTags object = {}

@sys.description('Set Parameter to true to Opt-out of deployment telemetry.')
param parTelemetryOptOut bool = false

var varSubnetMap = map(range(0, length(parSubnets)), i => {
  name: parSubnets[i].name
  ipAddressRange: parSubnets[i].ipAddressRange
  networkSecurityGroupId: parSubnets[i].?networkSecurityGroupId ?? ''
  routeTableId: parSubnets[i].?routeTableId ?? ''
  delegation: parSubnets[i].?delegation ?? ''
})

var varSubnetProperties = [
  for subnet in varSubnetMap: {
    name: subnet.name
    properties: {
      addressPrefix: subnet.ipAddressRange

      delegations: (empty(subnet.delegation))
        ? null
        : [
            {
              name: subnet.delegation
              properties: {
                serviceName: subnet.delegation
              }
            }
          ]

      routeTable: (empty(subnet.routeTableId))
        ? null
        : {
            id: subnet.routeTableId
          }
    }
  }
]

var varVpnGwConfig = ((parVpnGatewayEnabled) && (!empty(parVpnGatewayConfig))
  ? parVpnGatewayConfig
  : json('{"name": "noconfigVpn"}'))

var varErGwConfig = ((parExpressRouteGatewayEnabled) && !empty(parExpressRouteGatewayConfig)
  ? parExpressRouteGatewayConfig
  : json('{"name": "noconfigEr"}'))

var varGwConfig = [
  varVpnGwConfig
  varErGwConfig
]

// Customer Usage Attribution Id Telemetry
var varCuaid = '2686e846-5fdc-4d4f-b533-16dcb09d6e6c'

// ZTN Telemetry
var varZtnP1CuaId = '3ab23b1e-c5c5-42d4-b163-1402384ba2db'
var varZtnP1Trigger = (parDdosEnabled && parAzFirewallEnabled && (parAzFirewallTier == 'Premium')) ? true : false

var varAzFirewallUseCustomPublicIps = length(parAzFirewallCustomPublicIps) > 0

//DDos Protection plan will only be enabled if parDdosEnabled is true.
resource resDdosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2023-02-01' = if (parDdosEnabled) {
  name: parDdosPlanName
  location: parLocation
  tags: parTags
}

// Create resource lock if parDdosEnabled is true and parGlobalResourceLock.kind != 'None' or if parDdosLock.kind != 'None'
resource resDDoSProtectionPlanLock 'Microsoft.Authorization/locks@2020-05-01' = if (parDdosEnabled && (parDdosLock.kind != 'None' || parGlobalResourceLock.kind != 'None')) {
  scope: resDdosProtectionPlan
  name: parDdosLock.?name ?? '${resDdosProtectionPlan.name}-lock'
  properties: {
    level: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.kind : parDdosLock.kind
    notes: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.?notes : parDdosLock.?notes
  }
}

resource resHubVnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: parHubNetworkName
  location: parLocation
  tags: parTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        parHubNetworkAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: parDnsServerIps
    }
    subnets: varSubnetProperties
    enableDdosProtection: parDdosEnabled
    ddosProtectionPlan: (parDdosEnabled)
      ? {
          id: resDdosProtectionPlan.id
        }
      : null
  }
}

// Create a virtual network resource lock if parGlobalResourceLock.kind != 'None' or if parVirtualNetworkLock.kind != 'None'
resource resVirtualNetworkLock 'Microsoft.Authorization/locks@2020-05-01' = if (parVirtualNetworkLock.kind != 'None' || parGlobalResourceLock.kind != 'None') {
  scope: resHubVnet
  name: parVirtualNetworkLock.?name ?? '${resHubVnet.name}-lock'
  properties: {
    level: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.kind : parVirtualNetworkLock.kind
    notes: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.?notes : parVirtualNetworkLock.?notes
  }
}

resource resGatewaySubnetRef 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = if (parVpnGatewayEnabled || parExpressRouteGatewayEnabled) {
  parent: resHubVnet
  name: 'GatewaySubnet'
}

module modGatewayPublicIp '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/publicIp/publicIp.bicep' = [
  for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
    name: 'deploy-Gateway-Public-IP-${i}'
    params: {
      parLocation: parLocation
      parAvailabilityZones: toLower(gateway.gatewayType) == 'expressroute'
      ? (contains(toLower(gateway.sku), 'az') && empty(parAzErGatewayAvailabilityZones)
          ? ['1', '2']
          : parAzErGatewayAvailabilityZones)
      : (toLower(gateway.gatewayType) == 'vpn'
          ? (contains(toLower(gateway.sku), 'az') && empty(parAzVpnGatewayAvailabilityZones)
              ? ['1', '2']
              : parAzVpnGatewayAvailabilityZones)
          : [])
      parPublicIpName: parHubVpnGwPipActiveActiveName01
      parPublicIpProperties: {
        publicIpAddressVersion: 'IPv4'
        publicIpAllocationMethod: 'Static'
      }
      parPublicIpSku: {
        name: parPublicIpSku
      }
      parResourceLockConfig: (parGlobalResourceLock.kind != 'None')
        ? parGlobalResourceLock
        : parVirtualNetworkGatewayLock
      parTags: parTags
      parTelemetryOptOut: parTelemetryOptOut
    }
  }
]

// If the gateway is active-active, create a second public IP
module modGatewayPublicIpActiveActive '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/publicIp/publicIp.bicep' = [
  for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr') && gateway.activeActive) {
    name: 'deploy-Gateway-Public-IP-ActiveActive-${i}'
    params: {
      parLocation: parLocation
      parAvailabilityZones: toLower(gateway.gatewayType) == 'expressroute'
      ? (contains(toLower(gateway.sku), 'az') && empty(parAzErGatewayAvailabilityZones)
          ? ['1', '2']
          : parAzErGatewayAvailabilityZones)
      : (toLower(gateway.gatewayType) == 'vpn'
          ? (contains(toLower(gateway.sku), 'az') && empty(parAzVpnGatewayAvailabilityZones)
              ? ['1', '2']
              : parAzVpnGatewayAvailabilityZones)
          : [])
      parPublicIpName: parHubVpnGwPipActiveActiveName02
      parPublicIpProperties: {
        publicIpAddressVersion: 'IPv4'
        publicIpAllocationMethod: 'Static'
      }
      parPublicIpSku: {
        name: parPublicIpSku
      }
      parResourceLockConfig: (parGlobalResourceLock.kind != 'None')
        ? parGlobalResourceLock
        : parVirtualNetworkGatewayLock
      parTags: parTags
      parTelemetryOptOut: parTelemetryOptOut
    }
  }
]

// If the gateway is going to have a point-to-site config, create a third public IP
module modGatewayPublicIpPointToSite '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/publicIp/publicIp.bicep' = [
  for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr') && (toLower(gateway.gatewayType) == 'vpn') && !empty(gateway.vpnClientConfiguration)) {
    name: 'deploy-Gateway-Public-IP-PointToSite-${i}'
    params: {
      parLocation: parLocation
      parAvailabilityZones: toLower(gateway.gatewayType) == 'expressroute'
      ? (contains(toLower(gateway.sku), 'az') && empty(parAzErGatewayAvailabilityZones)
          ? ['1', '2']
          : parAzErGatewayAvailabilityZones)
      : (toLower(gateway.gatewayType) == 'vpn'
          ? (contains(toLower(gateway.sku), 'az') && empty(parAzVpnGatewayAvailabilityZones)
              ? ['1', '2']
              : parAzVpnGatewayAvailabilityZones)
          : [])
      parPublicIpName: parHubVpnGwPipPointToSiteName01
      parPublicIpProperties: {
        publicIpAddressVersion: 'IPv4'
        publicIpAllocationMethod: 'Static'
      }
      parPublicIpSku: {
        name: parPublicIpSku
      }
      parResourceLockConfig: (parGlobalResourceLock.kind != 'None')
        ? parGlobalResourceLock
        : parVirtualNetworkGatewayLock
      parTags: parTags
      parTelemetryOptOut: parTelemetryOptOut
    }
  }
]

//Minumum subnet size is /27 supporting documentation https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsub
resource resGateway 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = [
  for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr')) {
    name: gateway.name
    location: parLocation
    tags: parTags
    properties: {
      activeActive: gateway.activeActive
      enableBgp: gateway.enableBgp
      allowRemoteVnetTraffic: (toLower(gateway.gatewayType) == 'expressroute') ? gateway.allowRemoteVnetTraffic : null
      enableBgpRouteTranslationForNat: gateway.enableBgpRouteTranslationForNat
      enableDnsForwarding: gateway.enableDnsForwarding
      bgpSettings: (gateway.enableBgp) ? gateway.bgpSettings : null
      gatewayType: gateway.gatewayType
      vpnGatewayGeneration: (toLower(gateway.gatewayType) == 'vpn') ? gateway.generation : 'None'
      sku: {
        name: gateway.sku
        tier: gateway.sku
      }

      // Conditionally include vpnType only for VPN gateways
        ...(toLower(gateway.gatewayType) == 'vpn' ? {
          vpnType: gateway.vpnType
        } : {})

      vpnClientConfiguration: (toLower(gateway.gatewayType) == 'vpn')
        ? {
            vpnClientAddressPool: gateway.vpnClientConfiguration.?vpnClientAddressPool ?? ''
            vpnClientProtocols: gateway.vpnClientConfiguration.?vpnClientProtocols ?? ''
            vpnAuthenticationTypes: gateway.vpnClientConfiguration.?vpnAuthenticationTypes ?? ''
            aadTenant: gateway.vpnClientConfiguration.?aadTenant ?? ''
            aadAudience: gateway.vpnClientConfiguration.?aadAudience ?? ''
            aadIssuer: gateway.vpnClientConfiguration.?aadIssuer ?? ''
            vpnClientRootCertificates: gateway.vpnClientConfiguration.?vpnClientRootCertificates ?? ''
            radiusServerAddress: gateway.vpnClientConfiguration.?radiusServerAddress ?? ''
            radiusServerSecret: gateway.vpnClientConfiguration.?radiusServerSecret ?? ''
          }
        : null

      ipConfigurations: concat(
        // Primary IP configuration
        [
          {
            id: resHubVnet.id
            name: gateway.ipConfigurationName
            properties: {
              publicIPAddress: {
                id: modGatewayPublicIp[i].outputs.outPublicIpId // Primary Public IP
              }
              subnet: {
                id: resGatewaySubnetRef.id
              }
            }
          }
        ],
        // Add second IP configuration if activeActive is true
        gateway.activeActive
          ? [
              {
                id: resHubVnet.id
                name: gateway.ipConfigurationActiveActiveName
                properties: {
                  publicIPAddress: {
                    id: modGatewayPublicIpActiveActive[i].outputs.outPublicIpId // Secondary Public IP
                  }
                  subnet: {
                    id: resGatewaySubnetRef.id
                  }
                }
              }
            ]
          : [],
        // Add third IP configuration only if VPN gateway and P2S config exists
        (toLower(gateway.gatewayType) == 'vpn') && !empty(gateway.vpnClientConfiguration)
          ? [
              {
                id: resHubVnet.id
                name: gateway.ipConfigurationPointToSiteName
                properties: {
                  publicIPAddress: {
                    id: modGatewayPublicIpPointToSite[i].outputs.outPublicIpId // Third Public IP
                  }
                  subnet: {
                    id: resGatewaySubnetRef.id
                  }
                }
              }
            ]
          : []
      )
    }
  }
]

// Create a Virtual Network Gateway resource lock if gateway.name is not equal to noconfigVpn or noconfigEr and parGlobalResourceLock.kind != 'None' or if parVirtualNetworkGatewayLock.kind != 'None'
resource resVirtualNetworkGatewayLock 'Microsoft.Authorization/locks@2020-05-01' = [
  for (gateway, i) in varGwConfig: if ((gateway.name != 'noconfigVpn') && (gateway.name != 'noconfigEr') && (parVirtualNetworkGatewayLock.kind != 'None' || parGlobalResourceLock.kind != 'None')) {
    scope: resGateway[i]
    name: parVirtualNetworkGatewayLock.?name ?? '${resGateway[i].name}-lock'
    properties: {
      level: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.kind : parVirtualNetworkGatewayLock.kind
      notes: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.?notes : parVirtualNetworkGatewayLock.?notes
    }
  }
]

resource resAzureFirewallSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = if (parAzFirewallEnabled) {
  parent: resHubVnet
  name: 'AzureFirewallSubnet'
}

resource resAzureFirewallMgmtSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = if (parAzFirewallEnabled && (contains(
  map(parSubnets, subnets => subnets.name),
  'AzureFirewallManagementSubnet'
))) {
  parent: resHubVnet
  name: 'AzureFirewallManagementSubnet'
}

module modAzureFirewallPublicIp '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/publicIp/publicIp.bicep' = if (parAzFirewallEnabled) {
  name: 'deploy-Firewall-Public-IP'
  params: {
    parLocation: parLocation
    parAvailabilityZones: parAzFirewallAvailabilityZones
    parPublicIpName: '${parPublicIpPrefix}${parAzFirewallName}${parPublicIpSuffix}'
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parPublicIpSku: {
      name: parPublicIpSku
    }
    parResourceLockConfig: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock : parAzureFirewallLock
    parTags: parTags
    parTelemetryOptOut: parTelemetryOptOut
  }
}

module modAzureFirewallMgmtPublicIp '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/modules/publicIp/publicIp.bicep' = if (parAzFirewallEnabled && (contains(
  map(parSubnets, subnets => subnets.name),
  'AzureFirewallManagementSubnet'
))) {
  name: 'deploy-Firewall-mgmt-Public-IP'
  params: {
    parLocation: parLocation
    parAvailabilityZones: parAzFirewallAvailabilityZones
    parPublicIpName: '${parPublicIpPrefix}${parAzFirewallName}-mgmt${parPublicIpSuffix}'
    parPublicIpProperties: {
      publicIpAddressVersion: 'IPv4'
      publicIpAllocationMethod: 'Static'
    }
    parPublicIpSku: {
      name: 'Standard'
    }
    parResourceLockConfig: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock : parAzureFirewallLock
    parTags: parTags
    parTelemetryOptOut: parTelemetryOptOut
  }
}

resource resFirewallPolicies 'Microsoft.Network/firewallPolicies@2024-05-01' = if (parAzFirewallEnabled && parAzFirewallPoliciesEnabled) {
  name: parAzFirewallPoliciesName
  location: parLocation
  tags: parTags
  properties: (parAzFirewallTier == 'Basic')
    ? {
        sku: {
          tier: parAzFirewallTier
        }
        snat: !empty(parAzFirewallPoliciesPrivateRanges)
          ? {
              autoLearnPrivateRanges: parAzFirewallPoliciesAutoLearn
              privateRanges: parAzFirewallPoliciesPrivateRanges
            }
          : null
        threatIntelMode: 'Alert'
      }
    : {
        dnsSettings: {
          enableProxy: parAzFirewallDnsProxyEnabled
          servers: parAzFirewallDnsServers
        }
        sku: {
          tier: parAzFirewallTier
        }
        threatIntelMode: parAzFirewallIntelMode
      }
}

// Create Azure Firewall Policy resource lock if parAzFirewallEnabled is true and parGlobalResourceLock.kind != 'None' or if parAzureFirewallLock.kind != 'None'
resource resFirewallPoliciesLock 'Microsoft.Authorization/locks@2020-05-01' = if (parAzFirewallEnabled && (parAzureFirewallLock.kind != 'None' || parGlobalResourceLock.kind != 'None')) {
  scope: resFirewallPolicies
  name: parAzureFirewallLock.?name ?? '${resFirewallPolicies.name}-lock'
  properties: {
    level: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.kind : parAzureFirewallLock.kind
    notes: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.?notes : parAzureFirewallLock.?notes
  }
}

// AzureFirewallSubnet is required to deploy Azure Firewall . This subnet must exist in the parsubnets array if you deploy.
// There is a minimum subnet requirement of /26 prefix.
resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2024-05-01' = if (parAzFirewallEnabled) {
  dependsOn: [
    resGateway
  ]
  name: parAzFirewallName
  location: parLocation
  tags: parTags
  zones: (!empty(parAzFirewallAvailabilityZones) ? parAzFirewallAvailabilityZones : [])
  properties: parAzFirewallTier == 'Basic'
    ? {
        ipConfigurations: varAzFirewallUseCustomPublicIps
          ? map(parAzFirewallCustomPublicIps, ip => {
              name: 'ipconfig${uniqueString(ip)}'
              properties: ip == parAzFirewallCustomPublicIps[0]
                ? {
                    subnet: {
                      id: resAzureFirewallSubnetRef.id
                    }
                    publicIPAddress: {
                      id: parAzFirewallEnabled ? ip : ''
                    }
                  }
                : {
                    publicIPAddress: {
                      id: parAzFirewallEnabled ? ip : ''
                    }
                  }
            })
          : [
              {
                name: 'ipconfig1'
                properties: {
                  subnet: {
                    id: resAzureFirewallSubnetRef.id
                  }
                  publicIPAddress: {
                    id: parAzFirewallEnabled ? modAzureFirewallPublicIp.outputs.outPublicIpId : ''
                  }
                }
              }
            ]
        managementIpConfiguration: {
          name: 'mgmtIpConfig'
          properties: {
            publicIPAddress: {
              id: parAzFirewallEnabled ? modAzureFirewallMgmtPublicIp.outputs.outPublicIpId : ''
            }
            subnet: {
              id: resAzureFirewallMgmtSubnetRef.id
            }
          }
        }
        sku: {
          name: 'AZFW_VNet'
          tier: parAzFirewallTier
        }
        firewallPolicy: {
          id: resFirewallPolicies.id
        }
      }
    : {
        ipConfigurations: varAzFirewallUseCustomPublicIps
          ? map(parAzFirewallCustomPublicIps, ip => {
              name: 'ipconfig${uniqueString(ip)}'
              properties: ip == parAzFirewallCustomPublicIps[0]
                ? {
                    subnet: {
                      id: resAzureFirewallSubnetRef.id
                    }
                    publicIPAddress: {
                      id: parAzFirewallEnabled ? ip : ''
                    }
                  }
                : {
                    publicIPAddress: {
                      id: parAzFirewallEnabled ? ip : ''
                    }
                  }
            })
          : [
              {
                name: 'ipconfig1'
                properties: {
                  subnet: {
                    id: resAzureFirewallSubnetRef.id
                  }
                  publicIPAddress: {
                    id: parAzFirewallEnabled ? modAzureFirewallPublicIp.outputs.outPublicIpId : ''
                  }
                }
              }
            ]
        sku: {
          name: 'AZFW_VNet'
          tier: parAzFirewallTier
        }
        firewallPolicy: {
          id: resFirewallPolicies.id
        }
      }
}

// Create Azure Firewall resource lock if parAzFirewallEnabled is true and parGlobalResourceLock.kind != 'None' or if parAzureFirewallLock.kind != 'None'
resource resAzureFirewallLock 'Microsoft.Authorization/locks@2020-05-01' = if (parAzFirewallEnabled && (parAzureFirewallLock.kind != 'None' || parGlobalResourceLock.kind != 'None')) {
  scope: resAzureFirewall
  name: parAzureFirewallLock.?name ?? '${resAzureFirewall.name}-lock'
  properties: {
    level: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.kind : parAzureFirewallLock.kind
    notes: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.?notes : parAzureFirewallLock.?notes
  }
}

// If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
resource resHubRouteTable 'Microsoft.Network/routeTables@2024-05-01' = if (parAzFirewallEnabled) {
  name: parHubRouteTableName
  location: parLocation
  tags: parTags
  properties: {
    routes: [
      {
        name: 'hub-udr-default-azfw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parAzFirewallEnabled
            ? resAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
            : ''
        }
      }
    ]
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
  }
}

// Create a Route Table if parAzFirewallEnabled is true and parGlobalResourceLock.kind != 'None' or if parHubRouteTableLock.kind != 'None'
resource resHubRouteTableLock 'Microsoft.Authorization/locks@2020-05-01' = if (parAzFirewallEnabled && (parHubRouteTableLock.kind != 'None' || parGlobalResourceLock.kind != 'None')) {
  scope: resHubRouteTable
  name: parHubRouteTableLock.?name ?? '${resHubRouteTable.name}-lock'
  properties: {
    level: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.kind : parHubRouteTableLock.kind
    notes: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.?notes : parHubRouteTableLock.?notes
  }
}

module modPrivateDnsZonesAVM 'br/public:avm/ptn/network/private-link-private-dns-zones:0.3.0' = if (parPrivateDnsZonesEnabled) {
  name: 'deploy-Private-DNS-Zones-AVM-Single'
  scope: resourceGroup(parPrivateDnsZonesResourceGroup)
  params: {
    location: parLocation
    privateLinkPrivateDnsZones: empty(parPrivateDnsZones) ? null : parPrivateDnsZones
    virtualNetworkResourceIdsToLinkTo: union(
      [resHubVnet.id],
      !empty(parVirtualNetworkIdToLinkFailover) ? [parVirtualNetworkIdToLinkFailover] : [],
      parVirtualNetworkResourceIdsToLinkTo
    )
    enableTelemetry: parTelemetryOptOut ? false : true
    tags: parTags
    lock: {
      name: parPrivateDNSZonesLock.?name ?? 'pl-pdns-zone-lock'
      kind: (parGlobalResourceLock.kind != 'None') ? parGlobalResourceLock.kind : parPrivateDNSZonesLock.kind
    }
  }
}

// Optional Deployments for Customer Usage Attribution
module modCustomerUsageAttribution '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varCuaid}-${uniqueString(resourceGroup().location)}'
  params: {}
}

module modCustomerUsageAttributionZtnP1 '../../../../upstream-releases/v0.22.0/infra-as-code/bicep/CRML/customerUsageAttribution/cuaIdResourceGroup.bicep' = if (!parTelemetryOptOut && varZtnP1Trigger) {
  #disable-next-line no-loc-expr-outside-params //Only to ensure telemetry data is stored in same location as deployment. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  name: 'pid-${varZtnP1CuaId}-${uniqueString(resourceGroup().location)}'
  params: {}
}

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzFirewallPrivateIp string = parAzFirewallEnabled
  ? resAzureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
  : ''

//If Azure Firewall is enabled we will deploy a RouteTable to redirect Traffic to the Firewall.
output outAzFirewallName string = parAzFirewallEnabled ? parAzFirewallName : ''

output outPrivateDnsZones array = (parPrivateDnsZonesEnabled
  ? modPrivateDnsZonesAVM.outputs.combinedPrivateLinkPrivateDnsZonesReplacedWithVnetsToLink
  : [])
output outPrivateDnsZonesNames array = (parPrivateDnsZonesEnabled
  ? map(
      modPrivateDnsZonesAVM.outputs.combinedPrivateLinkPrivateDnsZonesReplacedWithVnetsToLink,
      zone => zone.pdnsZoneName
    )
  : [])

output outDdosPlanResourceId string = parDdosEnabled ? resDdosProtectionPlan.id : ''
output outHubVirtualNetworkName string = resHubVnet.name
output outHubVirtualNetworkId string = resHubVnet.id
output outHubRouteTableId string = parAzFirewallEnabled ? resHubRouteTable.id : ''
output outHubRouteTableName string = parAzFirewallEnabled ? resHubRouteTable.name : ''
