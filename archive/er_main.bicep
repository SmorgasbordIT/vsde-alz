param virtualNetworkGateways_AZUKS_SNK_HIB_ERGW_01_name string = 'AZUKS-SNK-HIB-ERGW-01'
param virtualNetworks_AZUKS_SNK_HUB_VNET_01_externalid string = '/subscriptions/418b1b0c-5109-4c71-b3ec-bb2aede68fb5/resourceGroups/AZUKS-RG-CONN-NETWORK-01/providers/Microsoft.Network/virtualNetworks/AZUKS-SNK-HUB-VNET-01'

resource virtualNetworkGateways_AZUKS_SNK_HIB_ERGW_01_name_resource 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: virtualNetworkGateways_AZUKS_SNK_HIB_ERGW_01_name
  location: 'uksouth'
  tags: {
    Location: 'uksouth'
    Environment: 'Hub'
  }
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'default'
        id: '${virtualNetworkGateways_AZUKS_SNK_HUB_ERGW_01_name_resource.id}/ipConfigurations/default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetworks_AZUKS_SNK_HUB_VNET_01_externalid}/subnets/GatewaySubnet'
          }
        }
      }
    ]
    natRules: []
    virtualNetworkGatewayPolicyGroups: []
    enableBgpRouteTranslationForNat: false
    disableIPSecReplayProtection: false
    sku: {
      name: 'Standard'
      tier: 'Standard'
    }
    gatewayType: 'ExpressRoute'
    vpnType: 'PolicyBased'
    enableBgp: false
    activeActive: false
    vpnGatewayGeneration: 'None'
    allowRemoteVnetTraffic: true
    allowVirtualWanTraffic: false
    adminState: 'Enabled'
  }
}
