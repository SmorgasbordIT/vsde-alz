param vnetName = 'hub-vnet-uks'
param vnetResourceGroup = 'rg-networking-uks'
param location = 'uksouth'

param subnetConfig = [
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.0.0.0/26'
    delegation: []
  }
  {
    name: 'GatewaySubnet'
    addressPrefix: '10.0.0.64/27'
    delegation: []
  }
  {
    name: 'ExpressRouteGateway'
    addressPrefix: '10.0.0.96/27'
    delegation: []
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.0.0.128/27'
    delegation: []
  }
  {
    name: 'Buffer1-EdgeServices'
    addressPrefix: '10.0.0.160/28'
    delegation: []
  }
  {
    name: 'PrivateEndpoints'
    addressPrefix: '10.0.0.176/26'
    delegation: []
  }
  {
    name: 'DNSForwarders'
    addressPrefix: '10.0.0.240/28'
    delegation: []
  }
  {
    name: 'Mgmt-Jumpbox'
    addressPrefix: '10.0.1.0/28'
    delegation: []
  }
  {
    name: 'AppGateway-WAF'
    addressPrefix: '10.0.1.16/27'
    delegation: []
  }
  {
    name: 'AppGateway-PrivateLink'
    addressPrefix: '10.0.1.48/27'
    delegation: []
  }
  {
    name: 'Buffer2-WAFScaling'
    addressPrefix: '10.0.1.80/28'
    delegation: []
  }
  {
    name: 'NVA'
    addressPrefix: '10.0.1.96/27'
    delegation: []
  }
  {
    name: 'APIM'
    addressPrefix: '10.0.1.128/27'
    delegation: []
  }
  {
    name: 'ServiceBus-PE'
    addressPrefix: '10.0.1.160/26'
    delegation: []
  }
  {
    name: 'Buffer3-PaaS'
    addressPrefix: '10.0.1.224/27'
    delegation: []
  }
]
