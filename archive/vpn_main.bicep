param virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name string = 'AZNEU-SNK-HUB-VPNGW-01'
param publicIPAddresses_AZNEU_SNK_HUB_VPNGW_01_pip_01_externalid string = '/subscriptions/a9ae3abb-308c-4d3a-bc71-7810b7ae5913/resourceGroups/AZNEU-RG-VSDE-NET-01/providers/Microsoft.Network/publicIPAddresses/AZNEU-SNK-HUB-VPNGW-01-pip-01'
param virtualNetworks_AZNEU_VNET_VSDE_01_externalid string = '/subscriptions/a9ae3abb-308c-4d3a-bc71-7810b7ae5913/resourceGroups/AZNEU-RG-VSDE-NET-01/providers/Microsoft.Network/virtualNetworks/AZNEU-VNET-VSDE-01'
param publicIPAddresses_AZNEU_SNK_HUB_VPNGW_01_pip_02_externalid string = '/subscriptions/a9ae3abb-308c-4d3a-bc71-7810b7ae5913/resourceGroups/AZNEU-RG-VSDE-NET-01/providers/Microsoft.Network/publicIPAddresses/AZNEU-SNK-HUB-VPNGW-01-pip-02'
param publicIPAddresses_AZNEU_SNK_HUB_VPN_P2S_01_pip_externalid string = '/subscriptions/a9ae3abb-308c-4d3a-bc71-7810b7ae5913/resourceGroups/AZNEU-RG-VSDE-NET-01/providers/Microsoft.Network/publicIPAddresses/AZNEU-SNK-HUB-VPN-P2S-01-pip'

resource virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name_resource 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name
  location: 'northeurope'
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'default'
        id: '${virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name_resource.id}/ipConfigurations/default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_AZNEU_SNK_HUB_VPNGW_01_pip_01_externalid
          }
          subnet: {
            id: '${virtualNetworks_AZNEU_VNET_VSDE_01_externalid}/subnets/GatewaySubnet'
          }
        }
      }
      {
        name: 'activeActive'
        id: '${virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name_resource.id}/ipConfigurations/activeActive'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_AZNEU_SNK_HUB_VPNGW_01_pip_02_externalid
          }
          subnet: {
            id: '${virtualNetworks_AZNEU_VNET_VSDE_01_externalid}/subnets/GatewaySubnet'
          }
        }
      }
      {
        name: 'AZNEU-SNK-HUB-VPN-P2S-01-pip'
        id: '${virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name_resource.id}/ipConfigurations/AZNEU-SNK-HUB-VPN-P2S-01-pip'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_AZNEU_SNK_HUB_VPN_P2S_01_pip_externalid
          }
          subnet: {
            id: '${virtualNetworks_AZNEU_VNET_VSDE_01_externalid}/subnets/GatewaySubnet'
          }
        }
      }
    ]
    natRules: []
    virtualNetworkGatewayPolicyGroups: []
    enableBgpRouteTranslationForNat: false
    disableIPSecReplayProtection: false
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: true
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '172.16.1.0/24'
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
      aadTenant: 'https://login.microsoftonline.com/ec5f282f-1669-4a4b-b01f-120c7c8e8acf/'
      aadAudience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
      aadIssuer: 'https://sts.windows.net/ec5f282f-1669-4a4b-b01f-120c7c8e8acf/'
    }
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.200.12.5,10.200.12.4'
      peerWeight: 0
      bgpPeeringAddresses: [
        {
          ipconfigurationId: '${virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name_resource.id}/ipConfigurations/default'
          customBgpIpAddresses: []
        }
        {
          ipconfigurationId: '${virtualNetworkGateways_AZNEU_SNK_HUB_VPNGW_01_name_resource.id}/ipConfigurations/activeActive'
          customBgpIpAddresses: []
        }
      ]
    }
    customRoutes: {
      addressPrefixes: []
    }
    vpnGatewayGeneration: 'Generation2'
    allowRemoteVnetTraffic: false
    allowVirtualWanTraffic: false
  }
}
